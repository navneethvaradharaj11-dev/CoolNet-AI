# CoolNet AI: LLM Explanation Layer

The **CoolNet AI Explanation Layer** is an LLM-powered decision support explanation service. It translates upstream machine learning predictions (e.g. XGBoost / LightGBM + SHAP feature attributions) into concise, factual, structured risk explanations for disaster response and emergency coordinators.

---

## 🏛️ Core Architectural Principle

```
+-----------------------------+
| ML Model (XGBoost/LightGBM) |
+-----------------------------+
               | (Compound Risk Score)
               v
+-----------------------------+
|         SHAP Engine         |
+-----------------------------+
               | (Feature Contributions)
               v
+=============================+
| CoolNet LLM Explanation     |
| Service (Input Validation   |
|   -> Secure Prompt Builder  |
|   -> Async LLM Client       |
|   -> Schema & Sanity Check) |
+=============================+
               |
               v
+-----------------------------+
| Structured Decision Support |
| JSON Output for Authorities |
+-----------------------------+
```

> **Key Rule**: The LLM is **never** the predictor or source of truth for the risk score. It explains existing ML evidence without modifying, recalculating, or overriding the score.

---

## 📁 Project Structure

```
Coolnet/
├── .env.example              # Environment variables template
├── README.md                 # Architecture, configuration, and integration guide
└── llm/
    ├── __init__.py           # Package exports
    ├── config.py             # Configuration dataclass & env loader
    ├── schemas.py            # Pydantic v2 schemas (LLMInput, LLMOutput, etc.)
    ├── validators.py         # Range checks, prompt injection detection, output sanity
    ├── prompts.py            # Strict 15-rule system prompt & XML-delimited prompt builder
    ├── client.py             # Async OpenAI-compatible client & deterministic MockLLMClient
    ├── exceptions.py         # Domain-specific exception hierarchy
    ├── service.py            # LLMExplanationService orchestrator
    └── tests/
        ├── __init__.py
        ├── test_validation.py # Input boundary & prompt injection tests
        ├── test_prompt.py     # Prompt rule inclusion & formatting tests
        ├── test_output.py     # Output schema & anti-hallucination tests
        └── run_tests.py       # Standalone test runner
```

---

## ⚙️ Configuration

Copy `.env.example` to `.env` or set the environment variables:

```bash
# Provider API Key (never exposed to frontend)
export LLM_API_KEY="your-api-key-here"

# Model name (supports OpenAI, Groq, Ollama, OpenRouter, etc.)
export LLM_MODEL="gpt-4o-mini"

# Base URL for any OpenAI-compatible API
export LLM_BASE_URL="https://api.openai.com/v1"

# Request timeout in seconds
export LLM_TIMEOUT=30.0

# Temperature (low temperature ensures factual, deterministic responses)
export LLM_TEMPERATURE=0.1

# Maximum retries with exponential backoff
export LLM_MAX_RETRIES=3
```

---

## 🚀 Quick Start & Usage

### 1. Python Direct Usage

```python
import asyncio
from llm import LLMExplanationService, LLMConfig

# 1. Initialize service (reads from environment variables by default)
service = LLMExplanationService()

# 2. Supply structured ML prediction evidence
evidence = {
    "ward_id": "W023",
    "risk_score": 0.93,
    "risk_level": "CRITICAL",
    "data": {
        "temperature": 43.2,
        "humidity": 68.0,
        "heat_index": 51.4,
        "power_stress": 0.82,
        "vulnerability_score": 0.91
    },
    "shap_factors": [
        {"feature": "temperature", "contribution": 0.31},
        {"feature": "power_stress", "contribution": 0.27},
        {"feature": "vulnerability_score", "contribution": 0.19}
    ],
    "data_status": {
        "temperature": "real",
        "humidity": "real",
        "power_stress": "simulated",
        "vulnerability_score": "estimated"
    },
    "timestamp": "2026-08-19T11:30:00+05:30"
}

# 3. Generate explanation (Async)
async def main():
    explanation = await service.explain(evidence)
    print(explanation.model_dump_json(indent=2))

asyncio.run(main())
```

### 2. FastAPI Integration Example

```python
from fastapi import FastAPI, HTTPException
from llm import LLMExplanationService, LLMInput, LLMOutput, CoolNetLLMError

app = FastAPI(title="CoolNet AI Explanation API")
explanation_service = LLMExplanationService()

@app.post("/api/v1/explain-risk", response_model=LLMOutput)
async def explain_risk(evidence: LLMInput):
    try:
        return await explanation_service.explain(evidence)
    except CoolNetLLMError as e:
        raise HTTPException(status_code=400, detail=str(e))
```

---

## 🛡️ Operational Safeguards & Anti-Hallucination Controls

1. **Immutable Ground Truth**: Rejects inputs with invalid risk scores ($< 0.0$ or $> 1.0$) or out-of-range physical sensor readings.
2. **Prompt Injection Defense**: Text fields like `ward_id` and feature names are sanitized against adversarial command patterns (`"Ignore previous instructions"`, `"System:"`, etc.).
3. **Data Provenance Enforcement**: Data status (`real`, `simulated`, `estimated`, `unavailable`) is strictly preserved in `data_quality_note`. Simulated grid indicators will never be characterized as real-time measurements.
4. **No Unsupported Outage Claims**: If power outage data is absent from the input, the LLM is barred from claiming active blackouts.
5. **No Medical Diagnoses / Decrees**: Response suggestions are formatted as decision support recommendations for disaster coordinators, never individual medical advice or fabricated government decrees.

---

## 🧪 Running Tests

Execute the unit test suite:

```bash
python llm/tests/run_tests.py
```
or via unittest discovery:
```bash
python -m unittest discover -s llm/tests -p "test_*.py" -v
```
