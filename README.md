## What this is
A compact end-to-end decision-support project that (1) trains a Gradient Boosting regressor in Python, exports it to ONNX for client-side browser inference, and (2) provides a Python LLM explanation service that turns model outputs + SHAP-like feature contributions into structured alerts for disaster coordinators (heatwave / grid stress / human vulnerability for urban wards).

### Stack
- **Language(s):** Python (primary), TypeScript (browser/Next.js)
- **Framework / runtime:** Python (scripts + LLM service, FastAPI-style architecture) and Next.js 14 + Node.js for browser inference
- **Notable libraries:** scikit-learn (GradientBoostingRegressor), skl2onnx / onnxruntime (model export + verification), onnxruntime-web (browser WASM inference), Pydantic v2 (schemas/validation)

## How it's organized
```
.env.example             # example env vars for LLM/service
README.md
llm/                    # LLM explanation layer (Python)
  config.py             # env loader
  schemas.py            # Pydantic schemas (LLMInput/LLMOutput)
  validators.py         # anti-injection / anti-hallucination checks
  prompts.py            # system prompt + XML prompt builder (15-rule safety system)
  client.py             # async OpenAI-compatible client + mock client
  service.py            # LLMExplanationService orchestrator
  tests/                # unit tests for the LLM layer
public/
  models/
    coolnet_risk_model.onnx   # exported ONNX model (binary)
    feature_importances.json  # model metadata & feature ordering
scripts/
  train_model.py         # synthetic dataset generator, trainer, ONNX export + verification
  test_inference.py      # inference verification / benchmark script
src/
  lib/
    ml/
      onnx-inference.ts  # onnxruntime-web browser inference service
      mock-ml-service.ts # baseline heuristic/mock service
      types.ts           # TS types for WardInputFeatures/WardRiskPrediction
    geojson/
      wards.ts           # ward catalog / spatial metadata (Chennai)
pull_from_github.py
push_to_github.py
push_via_api.py
```

How it fits together:
- scripts/train_model.py generates a calibrated synthetic dataset, trains a GradientBoostingRegressor, exports an ONNX model and a feature_importances.json file to public/models/, and verifies parity with onnxruntime.
- The Next.js/browser side (src/lib/ml/onnx-inference.ts) loads the ONNX binary via onnxruntime-web to run very fast client-side predictions and compute feature contribution breakdowns for the UI.
- The Python LLM layer (llm/) ingests the immutable risk score + feature attributions, runs safety/anti-hallucination validators, and uses an OpenAI-compatible client to produce structured, human-readable decision-support alerts.

## How to run it
1) Train model & export ONNX:
```bash
python scripts/train_model.py
# produces: public/models/coolnet_risk_model.onnx and public/models/feature_importances.json
```

2) Run inference verification:
```bash
python scripts/test_inference.py
```

3) Run LLM unit tests (may require env vars / API key):
```bash
python llm/tests/run_tests.py
```

Notes:
- Fill environment variables from .env.example before running the LLM service/tests (the README and llm/config.py indicate env-based configuration — the LLM client likely needs an API key).
- The browser usage example is in the README; client-side inference uses src/lib/ml/onnx-inference.ts and onnxruntime-web inside a Next.js app.

## Try asking
- How do the SHAP-style feature contributions get computed and passed from the browser into llm/service.py — is there a canonical JSON shape (see public/models/feature_importances.json and src/lib/ml/types.ts)?
- Are the LLM safety/anti-hallucination rules in llm/validators.py and prompts.py sufficient for production, or are there known gaps in the test suite under llm/tests/?
- Can the onnx-inference.ts worker be reused server-side (Node) or only in the browser; what ops/onnx opset constraints are assumed by skl2onnx/convert_sklearn (see scripts/train_model.py target_opset=12)?
