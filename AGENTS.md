# CoolNet AI — Repository Instructions

## Primary application

- The primary user-facing application is Flutter/Dart. Use `pubspec.yaml`, `lib/`, `test/`, and the existing Flutter platform runners as the source of truth.
- Read the relevant model, service, widget, and view before changing behavior. Keep business logic out of presentation widgets where practical.
- Preserve desktop, tablet, and narrow-screen behavior. Avoid fixed-width layouts unless the parent explicitly selects a desktop breakpoint.
- Do not describe sample values as live data. Preserve source, timestamp, units, and quality/provenance metadata when adding real data sources.
- Distinguish formula-based prototype scores, trained-model inference, forecasts, and LLM-generated explanations in both naming and UI copy.

## Supporting Python components

- The `llm/` package contains the structured explanation layer. Keep its Pydantic validation and output safeguards intact.
- `scripts/` contains model-training and ONNX inference verification scripts. Keep the seven-feature order consistent with the training/export pipeline.
- Use an isolated Python environment for Python tests and ML dependencies. Do not put provider credentials into Flutter assets or public client code.

## Validation before completion

Run and report the relevant commands when Flutter/Dart is available:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
```

For the Python explanation package, run its test runner from the repository root. Run ONNX inference verification separately when the relevant Python ML dependencies are installed.

If a toolchain is unavailable, state which checks could not be run rather than claiming they passed.

## Security and data integrity

- Do not add credentials, API keys, access tokens, or real private telemetry to the repository.
- Treat public Supabase policies as untrusted until verified. Use least-privilege policies for reads, writes, updates, and deletes; do not leave arbitrary public writes enabled for trusted telemetry.
- Validate units, physical bounds, feature ordering, and data provenance at service boundaries.
- Treat model explanations as supporting evidence, not as the authority for calculating the risk score.
- Avoid changing generated native-platform files unless the feature requires it.
