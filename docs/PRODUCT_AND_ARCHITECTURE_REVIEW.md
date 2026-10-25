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

### Important integration gaps

- MLService.predictWardRisk currently returns the local MockDataService prediction. The ONNX artifact is not loaded by the Flutter app; the Python inference script is the code path that uses onnxruntime.
- The ward weather, demand, outage, and vulnerability values used by Flutter are sample values. The current UI should not label those values as live telemetry.
- The displayed heat-index value in MockDataService is currently approximated as temperature plus 10% of relative humidity; it does not call HeatIndexCalculator.
- The predicted 30- and 60-minute values in MockDataService are simple score offsets, not a trained time-series forecast.
- The Python LLM package provides an explanation service, but the repository does not currently contain an HTTP API entry point that connects it to Flutter.
- The SQL schema contains broadly permissive public policies, including a FOR ALL USING (true) policy for grid telemetry. Before connecting a client to this database, replace these with role-specific least-privilege policies and validate who may write simulation or telemetry records.
- The root vercel.json invokes npm run build, npm run dev, and npm install, while the repository root currently has no package.json. Confirm the deployment build configuration rather than assuming the Flutter web build is covered by it.
- AGENTS.md contains generated Next.js instructions that do not match the Flutter application as it currently exists. Reconcile project-level development instructions before using automated coding tools.

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
