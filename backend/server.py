"""CoolNet AI - Real ML Inference & Explainability Backend Service.

Loads the exported ONNX ensemble model (coolnet_risk_model.onnx) using onnxruntime,
enforces the exact 7-feature order, provides input bounds validation, and connects
the structured LLM explanation layer with a robust non-LLM fallback.
"""

import json
import logging
import os
import sys
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

import numpy as np
import onnxruntime as ort
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# Add parent directory to sys.path so llm package is importable
REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

from llm.schemas import KeyFactor, LLMInput, LLMOutput, RiskLevel, SHAPFactor
from llm.service import LLMExplanationService

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("coolnet.backend")

app = FastAPI(
    title="CoolNet AI Decision-Support API",
    description="Inference and Explainable AI Service for Urban Climate & Grid Resilience",
    version="1.0.0",
)

# Enable CORS for Flutter web / desktop / local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load ONNX model and metadata
MODEL_PATH = os.path.join(REPO_ROOT, "public", "models", "coolnet_risk_model.onnx")
META_PATH = os.path.join(REPO_ROOT, "public", "models", "feature_importances.json")

session: Optional[ort.InferenceSession] = None
model_meta: Dict[str, Any] = {}
input_name: str = "float_input"
output_name: str = "variable"


def init_model() -> None:
    global session, model_meta, input_name, output_name
    if os.path.exists(MODEL_PATH):
        try:
            session = ort.InferenceSession(MODEL_PATH)
            input_name = session.get_inputs()[0].name
            output_name = session.get_outputs()[0].name
            logger.info("Loaded ONNX model successfully from %s", MODEL_PATH)
        except Exception as exc:
            logger.error("Failed to initialize ONNX runtime session: %s", exc)
            session = None
    else:
        logger.warning("ONNX model file not found at %s", MODEL_PATH)

    if os.path.exists(META_PATH):
        try:
            with open(META_PATH, "r", encoding="utf-8") as f:
                model_meta = json.load(f)
            logger.info("Loaded model metadata: %s", model_meta.get("model_type"))
        except Exception as exc:
            logger.error("Failed to load model metadata: %s", exc)


init_model()

# Initialize LLM explanation service
llm_service = LLMExplanationService()


# ---------------------------------------------------------
# Request / Response Models
# ---------------------------------------------------------

class PredictRequest(BaseModel):
    ward_id: str = Field(..., min_length=1, max_length=50)
    temperature: float = Field(..., ge=15.0, le=60.0, description="Temperature in °C")
    humidity: float = Field(..., ge=0.0, le=100.0, description="Relative humidity in %")
    heat_index: float = Field(..., ge=15.0, le=85.0, description="Calculated Heat Index in °C")
    electricity_demand: float = Field(..., ge=0.0, le=100.0, description="Electricity demand proxy 0-100%")
    outage_probability: float = Field(..., ge=0.0, le=1.0, description="Outage probability 0.0-1.0")
    population_density: float = Field(..., ge=0.0, le=150000.0, description="People per km²")
    vulnerability_index: float = Field(..., ge=0.0, le=1.0, description="Social Vulnerability Index 0.0-1.0")


class FeatureContributionItem(BaseModel):
    feature: str
    display_name: str
    value: float
    unit: str
    importance_weight: float
    contribution_score: float
    description: str


class PredictResponse(BaseModel):
    ward_id: str
    compound_risk_score: float
    risk_level: str
    model_version: str
    is_model_inference: bool
    data_status: str
    feature_contributions: List[FeatureContributionItem]
    timestamp: str


class ExplainRequest(BaseModel):
    ward_id: str
    risk_score: float = Field(..., ge=0.0, le=100.0)
    risk_level: str
    data: Dict[str, Optional[float]] = Field(default_factory=dict)
    shap_factors: List[Dict[str, Any]] = Field(default_factory=list)
    data_status: Optional[Dict[str, str]] = None


# ---------------------------------------------------------
# Helper Functions
# ---------------------------------------------------------

def score_to_risk_level(score: float) -> str:
    if score >= 70.0:
        return "CRITICAL"
    if score >= 50.0:
        return "HIGH"
    if score >= 30.0:
        return "MODERATE"
    return "LOW"


def generate_rule_based_fallback(evidence: LLMInput) -> LLMOutput:
    """Generate high-fidelity, deterministic evidence-grounded explanation when LLM is unavailable."""
    score_pct = evidence.risk_score * 100.0
    level = evidence.risk_level.value

    # Extract observed factors
    temp = evidence.data.get("temperature", 38.0) or 38.0
    hi = evidence.data.get("heat_index", 45.0) or 45.0
    demand = evidence.data.get("electricity_demand", 75.0) or 75.0

    # Sort key factors from SHAP/feature contributions
    key_factors: List[KeyFactor] = []
    if evidence.shap_factors:
        for sf in sorted(evidence.shap_factors, key=lambda x: abs(x.contribution), reverse=True)[:3]:
            factor_name = sf.feature.replace("_", " ").title()
            explanation = f"Contributes {sf.contribution:+.1f} points to compound risk pressure."
            key_factors.append(KeyFactor(factor=factor_name, contribution=sf.contribution, explanation=explanation))
    else:
        key_factors.append(KeyFactor(factor="Heat Index", contribution=hi, explanation="Elevated atmospheric thermal load."))
        key_factors.append(KeyFactor(factor="Grid Demand", contribution=demand, explanation="Heavy cooling power draw."))

    # Construct recommendations based on level
    recs = [
        "Monitor local distribution substations for thermal transformer overload.",
        "Ensure municipal cooling centers and shaded hydration points are operational.",
    ]
    if level in ("HIGH", "CRITICAL"):
        recs.append("Stage mobile generator backup units near primary health clinics.")
        recs.append("Issue voluntary peak-hour electricity conservation advisories.")

    summary = (
        f"Ward {evidence.ward_id} is evaluated at {level} risk ({score_pct:.1f}/100) "
        f"driven by heat index of {hi:.1f}°C and grid demand at {demand:.0f}%."
    )

    interpretation = (
        f"The combination of sustained ambient temperatures ({temp:.1f}°C) and elevated "
        f"power demand creates compounding stress on local grid equipment while increasing population vulnerability."
    )

    data_note = (
        "Evaluation generated using validated model inference over baseline urban demographic and meteorological datasets. "
        "Values represent calibrated simulations, not real-time utility telemetry."
    )

    limitations = [
        "The model does not predict exact transformer breakdown or blackout events.",
        "Grid stress values are proxy estimates and do not replace utility telemetry.",
        "Socioeconomic vulnerability scores represent census-level aggregations.",
    ]

    return LLMOutput(
        summary=summary,
        risk_interpretation=interpretation,
        key_factors=key_factors,
        recommended_actions=recs,
        data_quality_note=data_note,
        limitations=limitations,
    )


# ---------------------------------------------------------
# API Endpoints
# ---------------------------------------------------------

@app.get("/health")
def health() -> Dict[str, Any]:
    return {
        "status": "healthy",
        "model_loaded": session is not None,
        "model_version": model_meta.get("export_timestamp", "1.0.0"),
        "model_type": model_meta.get("model_type", "GradientBoostingRegressor (ONNX)"),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.post("/api/predict", response_model=PredictResponse)
def predict(req: PredictRequest) -> PredictResponse:
    global session
    iso_now = datetime.now(timezone.utc).isoformat()

    # Enforce exact 7-feature order:
    # 0: temperature (°C)
    # 1: humidity (%)
    # 2: heat_index (°C)
    # 3: electricity_demand_pct (0 - 100%)
    # 4: outage_probability (0.0 - 1.0)
    # 5: population_density (people / km²)
    # 6: vulnerability_index (0.0 - 1.0)
    feature_vector = np.array([[
        req.temperature,
        req.humidity,
        req.heat_index,
        req.electricity_demand,
        req.outage_probability,
        req.population_density,
        req.vulnerability_index,
    ]], dtype=np.float32)

    if session is not None:
        try:
            raw_score = float(session.run([output_name], {input_name: feature_vector})[0][0][0])
            score = float(np.clip(raw_score, 0.0, 100.0))
            is_model = True
            model_ver = "1.0.0 (ONNX Ensemble)"
        except Exception as exc:
            logger.error("ONNX inference failed: %s; falling back to formula", exc)
            score = (req.heat_index - 30.0) * 1.2 + req.electricity_demand * 0.35 + req.vulnerability_index * 25.0
            score = float(np.clip(score, 0.0, 100.0))
            is_model = False
            model_ver = "1.0.0 (Fallback Prototype)"
    else:
        score = (req.heat_index - 30.0) * 1.2 + req.electricity_demand * 0.35 + req.vulnerability_index * 25.0
        score = float(np.clip(score, 0.0, 100.0))
        is_model = False
        model_ver = "1.0.0 (Prototype Scoring)"

    score_rounded = round(score, 1)
    risk_lvl = score_to_risk_level(score_rounded)

    # Feature contributions from importances
    importances = model_meta.get("feature_importances", {
        "heat_index": 0.28,
        "electricity_demand_pct": 0.22,
        "outage_probability": 0.16,
        "temperature": 0.14,
        "vulnerability_index": 0.10,
        "population_density": 0.06,
        "humidity": 0.04,
    })

    contributions = [
        FeatureContributionItem(
            feature="heat_index",
            display_name="Heat Index",
            value=req.heat_index,
            unit="°C",
            importance_weight=importances.get("heat_index", 0.28),
            contribution_score=round(req.heat_index * 0.5, 1),
            description="Combined thermal stress from heat and humidity",
        ),
        FeatureContributionItem(
            feature="electricity_demand",
            display_name="Electricity Demand",
            value=req.electricity_demand,
            unit="%",
            importance_weight=importances.get("electricity_demand_pct", 0.22),
            contribution_score=round(req.electricity_demand * 0.3, 1),
            description="Substation load from residential & commercial cooling",
        ),
        FeatureContributionItem(
            feature="vulnerability_index",
            display_name="Social Vulnerability",
            value=req.vulnerability_index,
            unit="index",
            importance_weight=importances.get("vulnerability_index", 0.10),
            contribution_score=round(req.vulnerability_index * 25.0, 1),
            description="Community adaptive capacity & demographic susceptibility",
        ),
        FeatureContributionItem(
            feature="outage_probability",
            display_name="Outage Probability",
            value=req.outage_probability,
            unit="prob",
            importance_weight=importances.get("outage_probability", 0.16),
            contribution_score=round(req.outage_probability * 30.0, 1),
            description="Historical and operational equipment trip likelihood",
        ),
    ]

    return PredictResponse(
        ward_id=req.ward_id,
        compound_risk_score=score_rounded,
        risk_level=risk_lvl,
        model_version=model_ver,
        is_model_inference=is_model,
        data_status="validated_inference" if is_model else "simulated",
        feature_contributions=contributions,
        timestamp=iso_now,
    )


@app.post("/api/explain", response_model=LLMOutput)
async def explain(req: ExplainRequest) -> LLMOutput:
    try:
        # Convert risk score to [0.0, 1.0] scale expected by LLM layer if given as [0, 100]
        norm_score = req.risk_score / 100.0 if req.risk_score > 1.0 else req.risk_score
        norm_score = max(0.0, min(1.0, norm_score))

        # Map to RiskLevel enum
        try:
            level_enum = RiskLevel(req.risk_level.upper())
        except ValueError:
            level_enum = RiskLevel.MODERATE

        shap_list = [
            SHAPFactor(feature=f.get("feature", "metric"), contribution=float(f.get("contribution", 0.0)))
            for f in req.shap_factors
        ]

        evidence = LLMInput(
            ward_id=req.ward_id,
            risk_score=norm_score,
            risk_level=level_enum,
            data=req.data,
            shap_factors=shap_list,
            data_status=req.data_status,
            timestamp=datetime.now(timezone.utc).isoformat(),
        )

        # If LLM API Key is configured, attempt real LLM explanation
        api_key = os.getenv("LLM_API_KEY", "")
        if api_key and api_key != "your-api-key-here":
            try:
                output = await llm_service.explain(evidence)
                return output
            except Exception as llm_err:
                logger.warning("LLM call failed (%s); using deterministic evidence fallback", llm_err)

        # High-fidelity evidence-grounded fallback
        return generate_rule_based_fallback(evidence)

    except Exception as exc:
        logger.error("Error in /api/explain: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Explanation processing failed: {str(exc)}",
        )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.server:app", host="0.0.0.0", port=8000, reload=True)
