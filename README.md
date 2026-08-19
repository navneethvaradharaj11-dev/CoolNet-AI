# CoolNet AI: Real ML + ONNX Inference & LLM Explanation Architecture

**CoolNet AI** is a compound climate disaster decision-support system analyzing heatwave hazards, power grid stress, and human vulnerability for urban wards.

It features:
1. **Real ML Predictive Model**: A trained Gradient Boosting Regressor exported to open **ONNX binary format** (`public/models/coolnet_risk_model.onnx`) running client-side/edge in Next.js 14.
2. **LLM Explanation Layer**: A secure, factual LLM explanation service translating ML outputs and SHAP factor contributions into disaster coordinator alerts.

---

## 🏛️ End-to-End System Architecture

```
+-------------------------------------------------------------------------------+
| 1. Real ML Training Pipeline (Python)                                         |
|    - Calibrated meteorological & grid dataset (5,000 samples)                 |
|    - Non-linear AC demand surges (>35°C) & transformer outage probabilities   |
|    - GradientBoostingRegressor (R² = 0.996, MAE = 1.24 points)                |
|    - Exports: coolnet_risk_model.onnx & feature_importances.json              |
+-------------------------------------------------------------------------------+
                                      |
                                      v
+-------------------------------------------------------------------------------+
| 2. Next.js 14 Browser Inference Engine (TypeScript)                           |
|    - src/lib/ml/onnx-inference.ts using onnxruntime-web                       |
|    - Predicts 0-100 Compound Risk Score in browser memory (< 5ms)             |
|    - Computes feature contribution breakdown for Ward Detail UI               |
+-------------------------------------------------------------------------------+
                                      |
                                      v
+-------------------------------------------------------------------------------+
| 3. LLM Explanation Layer (Python / FastAPI)                                   |
|    - Ingests immutable risk score + SHAP feature attributions                 |
|    - Evaluates 15 safety & anti-hallucination constraints                     |
|    - Outputs structured decision-support alert for disaster coordinators      |
+-------------------------------------------------------------------------------+
```

---

## 📁 Repository Structure

```
Coolnet/
├── public/models/
│   ├── coolnet_risk_model.onnx       # Trained ML model in open ONNX binary format
│   └── feature_importances.json      # Model metadata and calibrated feature weights
├── scripts/
│   ├── train_model.py                # Dataset generator, model trainer & ONNX exporter
│   └── test_inference.py             # Scenario benchmark verification tests
├── src/lib/
│   ├── geojson/
│   │   └── wards.ts                  # Chennai municipal ward catalog & spatial metadata
│   └── ml/
│       ├── types.ts                  # WardInputFeatures, WardRiskPrediction, RiskLevel
│       ├── mock-ml-service.ts        # Baseline heuristic engine
│       └── onnx-inference.ts         # Real ONNX WebAssembly inference service
└── llm/
    ├── config.py                     # Environment variables loader
    ├── schemas.py                    # Pydantic v2 schemas (LLMInput, LLMOutput, etc.)
    ├── validators.py                 # Anti-injection & anti-hallucination validators
    ├── prompts.py                    # 15-rule system prompt & XML prompt builder
    ├── client.py                     # Async OpenAI-compatible client + MockLLMClient
    ├── service.py                    # LLMExplanationService orchestrator
    └── tests/                        # Full automated test suite (19 tests)
```

---

## 🚀 How to Run & Verify

### 1. Run ML Training & ONNX Model Export (Python)

```powershell
python scripts/train_model.py
```
Outputs:
- Model R² Score: `0.9960`
- MAE: `1.24` points
- Exported ONNX model to `public/models/coolnet_risk_model.onnx`

### 2. Verify ONNX Inference Benchmarks

```powershell
python scripts/test_inference.py
```

### 3. Run LLM Explanation Layer Unit Tests

```powershell
python llm/tests/run_tests.py
```

---

## 💻 Next.js Browser Inference Usage Example

```typescript
import { predictWardRisk } from "@/lib/ml/onnx-inference";

const wardPrediction = await predictWardRisk({
  wardId: "W001",
  temperature: 42.5,
  humidity: 68.0,
  electricityDemandPct: 92.0,
  outageProbability: 0.65,
});

console.log(`Ward ${wardPrediction.wardId} Risk: ${wardPrediction.riskScore}/100 (${wardPrediction.riskLevel})`);
console.log("Top Risk Drivers:", wardPrediction.featureContributions);
```
