# CoolNet AI — Product and Architecture Review

## Product intent

CoolNet AI is a climate-resilience decision-support prototype for identifying city wards where extreme heat, electricity-grid stress, and social vulnerability may combine into elevated risk.

The intended operator workflow is:

1. Find the wards with the highest estimated compound risk.
2. Inspect the weather, grid, and vulnerability signals behind each score.
3. Explore how risk could change under alternate conditions.
4. Use evidence-backed explanations to prioritize follow-up or resilience interventions.

The score is a prioritization signal, not a guarantee of outage or a substitute for an emergency-management decision.

## What the repository currently contains

### Implemented in the Flutter application

- A Flutter dashboard with a ward watchlist, map, selected-ward metrics, and what-if sliders.
- A MockDataService with 20 hard-coded ward records located around Delhi coordinates.
- Local risk-score and scenario calculations in lib/services/ml_service.dart.
- A dedicated heat-index calculation implementation in lib/physics/heat_index.dart.
- A Python model-training script and an exported ONNX model under public/models/.
- A Python LLM explanation package with typed Pydantic input/output models and validation/tests under llm/.

### Completed Architecture & Integration Milestone (Phase 2)

- **ML Inference Backend:** `backend/server.py` implements FastAPI endpoints serving the trained ONNX ensemble model (`public/models/coolnet_risk_model.onnx`) with exact 7-feature ordering and feature attribution scores.
- **Explainable AI Pipeline:** `backend/server.py` exposes `/api/explain` wired directly into `llm/service.py` with Pydantic output validation, anti-hallucination checks, and a deterministic non-LLM fallback.
- **Flutter Integration:** `MLService` connects to the inference and explanation backend with timeouts and fallback to deterministic local calibrated scoring.
- **Deterministic Risk Engine:** Synchronization between rounded score and categorical risk level ensures deterministic test and runtime behavior.
- **Security Hardening:** Supabase schema RLS updated to least-privilege role separation (removal of public telemetry writes, server-side simulation bounds validation, audit logging).
- **Tooling & Build Alignment:** Added `package.json` and updated `vercel.json` for proper Flutter web release build compilation (`flutter build web --release`).

## UI direction

The redesign branch (redesign/command-center-v2) establishes a responsive, dark command-center layout:

- An explicit simulated-input status instead of a false live-data indicator.
- A concise overview row derived from the current sample catalog.
- A searchable ward watchlist with risk-level color coding.
- A selected-ward profile with clearer metric groups and a sample-data note.
- A responsive scenario panel with baseline, scenario, and risk-change values.
- Different desktop, tablet, and narrow-screen arrangements.

The revised interface remains a prototype until the data and model integration gaps below are addressed.

## Recommended development roadmap

### Phase 1 — Make the prototype honest and stable

- Keep sample/demo and real/estimated/unavailable provenance visible at the metric level.
- Use the dedicated heat-index calculator wherever a heat-index value is produced.
- Clearly distinguish an explanatory formula from model inference and from an actual forecast.
- Add unit tests for score bounds, risk-level thresholds, temperature/humidity edge cases, and scenario deltas.

### Phase 2 — Establish a trustworthy data contract

- Define typed, versioned contracts for weather, ward geography, grid telemetry, vulnerability data, model input, prediction, and source provenance.
- Preserve source timestamp, retrieval timestamp, units, source, and quality status.
- Replace placeholder polygons with verified administrative boundaries and show the boundary/data source.
- Integrate a weather provider behind a service interface. Until a real grid-data provider is available, label grid metrics as estimated or simulated rather than presenting them as utility telemetry.

### Phase 3 — Connect inference deliberately

- Choose one supported inference route: a documented backend endpoint using the existing ONNX artifact, or a deliberately tested Flutter-compatible inference runtime.
- Enforce the exact seven-feature order expected by the training script: temperature, humidity, heat index, electricity demand, outage probability, population density, and vulnerability index.
- Return model version, score scale, uncertainty/quality metadata, and timestamp with every prediction.
- Compare predictions against held-out test data and test edge cases before calling the result operationally meaningful.

### Phase 4 — Connect explainability

- Expose the Python LLM explanation package through an authenticated, rate-limited API.
- Send only validated structured evidence and model attribution values; never rely on generated text as the source of a risk score.
- Return key factors, evidence, recommended follow-up actions, limitations, and a data-quality note.
- Keep provider credentials server-side and provide a non-LLM fallback when the explanation provider is unavailable.

### Phase 5 — Secure persistence and deployment

- Replace broad Supabase policies with least-privilege read/write rules and authenticated access as appropriate.
- Add server-side validation and audit logging for scenario records and any imported telemetry.
- Align the Vercel/build pipeline with the actual Flutter web artifact or deploy a separate backend service with its own build configuration.
- Add CI jobs for Flutter analysis/tests, Python LLM tests, and ONNX inference tests.

## Release acceptance criteria

- The interface never labels sample data as live.
- Every important metric has units and a visible source/quality status.
- Risk calculations are reproducible and covered by tests.
- The deployed build can be produced from a documented, repeatable command.
- No public client policy can arbitrarily overwrite trusted telemetry.
- Explanations describe model evidence and limitations instead of inventing confidence or causal certainty.
