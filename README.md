# 🌐 CoolNet AI (Dart & Flutter)

**Compound Heat–Grid Risk Intelligence Dashboard & ML System**

A climate-risk decision-support platform that identifies vulnerable electrical grid wards, quantifies risk exposure, forecasts escalation patterns, and recommends preventive interventions. Built with Dart programming language, Flutter Web/Desktop, AI/ML explainability, and thermodynamic calculation engines.

🚀 **Live Vercel Demo**: [https://coolnet-ai-phase1-theta.vercel.app](https://coolnet-ai-phase1-theta.vercel.app)

---

## 🎯 What It Does

CoolNet AI is a visual command center for grid operators and climate resilience teams:

- **Identify Risk**: Spot which wards face the highest compound heat-grid stress
- **Understand Why**: Get explainable AI insights into risk drivers (weather, infrastructure, demographics) via SHAP feature attributions
- **Native Dart Physics & ML Engine**: NWS Rothfusz heat index regression & spatial heat diffusion in Dart
- **Flutter GIS Mapping**: Leaflet-compatible vector map layers built natively using `flutter_map`
- **Simulate Interventions**: Test "what-if" scenarios (load shifting, demand reduction, strategic outage)
- **Multi-Platform**: Runs on Flutter Web, Windows Desktop, Linux, macOS, iOS, and Android

---

## 🏗️ Architecture & Tech Stack (Dart / Flutter)

| Layer | Tech | Description |
|-------|------|-------------|
| **Frontend Framework** | Flutter 3.44+ (Dart 3.12+) | Multi-platform command-center UI |
| **GIS & Mapping** | `flutter_map` + `latlong2` | Interactive vector ward map & markers |
| **Typography & Theme** | Google Fonts (Inter) | Dark command-center aesthetic |
| **Thermodynamics & Physics** | Native Dart Math Engine | NWS Rothfusz Heat Index & spatial heat diffusion |
| **Python LLM Layer** | Python 3.10+, Pydantic v2 | Safety-checked AI explanation service |

---

## 📁 Project Structure (Dart / Flutter)

```
├── lib/
│   ├── main.dart               # Main Flutter app entry point & dark theme setup
│   ├── models/
│   │   ├── ward.dart           # Ward & GeoJSON polygon contracts in Dart
│   │   └── risk_data.dart      # Weather, Grid, Vulnerability, and Risk prediction models
│   ├── physics/
│   │   ├── heat_index.dart     # NWS Rothfusz heat index calculator (Dart)
│   │   └── heat_diffusion.dart # Spatial heat diffusion smoothing algorithm (Dart)
│   ├── services/
│   │   ├── geocoding_service.dart # Nominatim OpenStreetMap search & reverse geocoding
│   │   ├── grid_service.dart     # Geospatial grid indexing & bounding cell service
│   │   ├── mock_data_service.dart # Full catalog for 20 Delhi wards & 12 Chennai wards
│   │   └── ml_service.dart        # Risk scoring & What-If scenario simulation engine
│   ├── views/
│   │   └── dashboard_view.dart # Command-center dashboard view
│   └── widgets/
│       ├── header_widget.dart     # Live telemetry status bar
│       ├── ward_list_widget.dart  # Searchable ward sidebar with risk badges
│       ├── ward_detail_widget.dart# Comprehensive heat & grid metric breakdown
│       ├── risk_map_widget.dart   # Interactive GIS map widget (flutter_map)
│       └── simulation_widget.dart # What-If heatwave slider panel
├── web/                        # Flutter Web entry point & assets
├── windows/                    # Windows Native Runner
├── pubspec.yaml                # Dart / Flutter dependencies & asset configuration
└── README.md
```

---

## 🚀 Quick Start (Flutter / Dart)

### 1. Run Flutter Web App
```bash
flutter pub get
flutter run -d chrome
```

### 2. Build Production Web Bundle
```bash
flutter build web
```

---

**Built with Dart & Flutter for climate resilience.**
