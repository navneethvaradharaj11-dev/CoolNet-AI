# 🌐 CoolNet AI

**Compound Heat–Grid Risk Intelligence Dashboard & ML System**

A climate-risk decision-support platform that identifies vulnerable electrical grid wards, quantifies risk exposure, forecasts escalation patterns, and recommends preventive interventions. Built with AI/ML explainability, real ONNX client-side inference, and an LLM decision-support layer at its core.

🚀 **Live Vercel Demo**: [https://coolnet-ai-phase1-theta.vercel.app](https://coolnet-ai-phase1-theta.vercel.app)

---


## 🎯 What It Does

CoolNet AI is a visual command center for grid operators and climate resilience teams:

- **Identify Risk**: Spot which wards face the highest compound heat-grid stress
- **Understand Why**: Get explainable AI insights into risk drivers (weather, infrastructure, demographics) via SHAP feature attributions
- **Real-Time ONNX Inference**: Client-side WASM neural/tree model inference for zero-latency ward risk calculation
- **LLM Explanation Layer**: Structured, multi-rule safe AI alerts for emergency coordinators
- **Simulate Interventions**: Test "what-if" scenarios (load shifting, demand reduction, strategic outage)
- **Supabase Integration**: Live database telemetry and simulation audit logging

---

## 🏗️ Architecture & Tech Stack

| Layer | Tech | Description |
|-------|------|-------------|
| **Frontend** | Next.js 14, React 19, TypeScript | Command-center dashboard |
| **ONNX Runtime** | `onnxruntime-web` (WASM) | Client-side ML model inference |
| **Python LLM Layer** | Python 3.10+, Pydantic v2, OpenAI API | Safety-checked AI explanation service |
| **Mapping** | Leaflet + `react-leaflet` | Interactive GIS ward visualization |
| **Database** | Supabase (PostgreSQL) | Live telemetry & audit logging |

---

## 📁 Project Structure

```
├── app/                        # Next.js App Router pages
├── components/                 # UI components, Leaflet map, simulation panels
├── lib/
│   ├── ml/                     # ONNX inference layer & ML services
│   ├── physics/                # Thermodynamic heat index & spatial heat diffusion
│   ├── services/               # Geocoding (Nominatim) & grid cell services
│   ├── supabase/               # Supabase database client & schema
│   └── types/                  # Single source of truth TypeScript contracts
├── llm/                        # Python LLM explanation service & safety validators
│   ├── config.py
│   ├── schemas.py              # Pydantic input/output schemas
│   ├── validators.py           # Anti-hallucination & injection guards
│   └── service.py              # Explanation orchestrator
├── public/models/              # Trained ONNX risk model & feature importance metadata
├── scripts/                    # ML training & Python test scripts
├── supabase/schema.sql         # PostgreSQL database schema
└── vercel.json                 # Vercel deployment configuration
```

---

## 🚀 Quick Start

### 1. Web Dashboard (Next.js)
```bash
npm install
npm run dev
```
Open **http://localhost:3000** in your browser.

### 2. Python ML & LLM Engine
```bash
# Train model & export ONNX
python scripts/train_model.py

# Verify model inference
python scripts/test_inference.py

# Run LLM layer unit tests
python llm/tests/run_tests.py
```

---

## 🛡️ Key Features & Calibration

- **Thermodynamic Heat Index**: Calculated using the NOAA National Weather Service (NWS) Rothfusz regression model.
- **Spatial Heat Diffusion Engine**: Mathematical discrete grid smoothing weighted by spatial distance and relative ward population density.
- **Data Provenance**: All metrics bounded to verified IMD/MoHFW heatwave statistics.

---

**Built with ❤️ for climate resilience.**

