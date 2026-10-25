# 🌐 CoolNet AI

**Compound Heat–Grid Risk Intelligence**

CoolNet AI is a climate-resilience decision-support prototype for exploring how extreme heat, electricity demand, and social vulnerability can combine to increase risk at ward level. The intended workflow is to identify priority areas, inspect contributing signals, and compare possible interventions.

> **Prototype status:** the Flutter application currently uses sample ward, weather, grid, and vulnerability inputs. Its risk scores and scenario results are generated locally. Do not interpret them as live utility telemetry, validated outage forecasts, or emergency alerts.

**Prototype URL:** [https://coolnet-ai-phase1-theta.vercel.app](https://coolnet-ai-phase1-theta.vercel.app) — verify the deployment/build configuration before relying on this URL.

---

## 🎯 Product direction

- **Find priority wards:** compare estimated compound risk across the available sample ward catalog.
- **Inspect risk drivers:** view heat, grid-stress, and vulnerability signals for a selected ward.
- **Explore scenarios:** adjust temperature, demand, and cooling-access assumptions to see how the local prototype score changes.
- **Move toward explainability:** connect validated model evidence to concise, evidence-bound recommendations.
- **Support resilience planning:** eventually integrate trustworthy geographic and environmental data, with each metric showing its source and quality status.

The score is intended to be a prioritization aid. It is not a guarantee of a power outage and does not replace domain-expert or emergency-management judgment.

## 🧪 Implementation status

| Capability | Current state |
|---|---|
| Flutter dashboard, ward list, map, ward profile | Implemented with dark command-center aesthetic on `redesign/command-center-v2` |
| Ward catalog and weather/grid/vulnerability values | Calibrated data for 20 illustrative Delhi-area ward records with provenance tags |
| Heat index | Verified NOAA NWS Rothfusz-based calculator implemented in Dart and Python |
| Risk scoring and what-if simulation | Deterministic risk engine with synchronized rounding and physical bounds validation |
| ONNX artifact | `coolnet_risk_model.onnx` & feature importance metadata verified with onnxruntime |
| Real ML inference backend | FastAPI service (`backend/server.py`) serving ONNX Runtime predictions with exact 7-feature ordering |
| Explainable AI layer | Structured Pydantic LLM service (`llm/`) connected to backend `/api/explain` with anti-hallucination checks & deterministic fallback |
| Supabase database & RLS | Hardened with least-privilege role policies, server-side CHECK constraints, and audit logging |
| Web build & deployment | Reconciled via `package.json` and `vercel.json` (`flutter build web --release`) |

See [docs/PRODUCT_AND_ARCHITECTURE_REVIEW.md](docs/PRODUCT_AND_ARCHITECTURE_REVIEW.md) for the detailed findings, target architecture, security notes, roadmap, and release acceptance criteria.

---

## 🏗️ Stack

| Layer | Technology | Current purpose |
|---|---|---|
| User interface | Flutter / Dart | Cross-platform command center dashboard |
| GIS | `flutter_map`, `latlong2` | Spatial ward overlays, bounding polygons, and interactive selection |
| Heat calculations | Native Dart / Python | NOAA NWS Rothfusz heat-index and spatial diffusion calculations |
| Real ML inference | Python, ONNX Runtime, FastAPI | High-performance inference server executing trained ensemble regressor |
| Explanation layer | Python, Pydantic, OpenAI-compatible client | Validated structured risk driver explanations and decision-support actions |
| Persistence & Security | Supabase SQL schema | Hardened telemetry, vulnerability, simulation logs, and security audit tables |


## 📁 Repository structure

```
├── lib/
│   ├── main.dart
│   ├── models/                  # Ward and risk data contracts
│   ├── physics/                 # Heat-index and heat-diffusion utilities
│   ├── services/                # Sample data, scoring, geocoding, grid helpers
│   ├── views/                   # Dashboard layout
│   └── widgets/                 # Header, metrics, map, ward list, profile, scenario lab
├── llm/                         # Validated Python LLM explanation package
├── public/models/               # Exported ONNX model and feature metadata
├── scripts/                     # Model training and ONNX inference checks
├── supabase/schema.sql          # Initial database schema and seed data
├── docs/PRODUCT_AND_ARCHITECTURE_REVIEW.md
├── test/                        # Flutter widget and risk-engine tests
├── web/                         # Flutter web entry point and assets
└── pubspec.yaml
```

## 🚀 Run locally

Prerequisites: install a Flutter SDK compatible with the constraint in `pubspec.yaml`, and configure Chrome or another supported Flutter target.

```bash
flutter pub get
flutter run -d chrome
```

Build a Flutter web bundle:

```bash
flutter build web
```

Run Flutter analysis and tests before submitting changes:

```bash
flutter analyze
flutter test
```

The Python training/inference scripts have separate dependencies. Use an isolated Python environment and install the required ML packages before running them. The LLM package also has its own tests and environment configuration.

---

**Built as a prototype for climate resilience. The next milestone is trustworthy data provenance and tested model integration—not presenting demo values as live intelligence.**
