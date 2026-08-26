# 🌐 CoolNet AI

**Compound Heat–Grid Risk Intelligence Dashboard**

A climate-risk decision-support platform that identifies vulnerable electrical grid wards, quantifies risk exposure, forecasts escalation patterns, and recommends preventive interventions. Built with AI/ML explainability at its core.

> ⚠️ **Phase 1 Status**: Demo data only. All outputs are clearly labeled. No live feeds or real models in this build.

---

## 🎯 What It Does

CoolNet AI is a visual command center for grid operators and climate resilience teams:

- **Identify Risk**: Spot which wards face the highest compound heat-grid stress
- **Understand Why**: Get explainable AI insights into risk drivers (weather, infrastructure, demographics)
- **Forecast Impact**: See how risk evolves over the next 24–72 hours
- **Simulate Interventions**: Test "what-if" scenarios (load shifting, demand reduction, strategic outage)
- **Recommend Action**: Get prioritized, human-reviewed intervention recommendations
- **Visualize Geography**: Interactive GIS map with real-time ward health overlays

---

## 🏗️ Tech Stack

| Layer | Tech | Coverage |
|-------|------|----------|
| **Frontend** | Next.js 14, React 18, TypeScript | 77% Python / 23% TypeScript |
| **Mapping** | Leaflet + react-leaflet | Interactive GIS |
| **Charts** | Recharts | Risk trend visualization |
| **Styling** | Tailwind CSS + dark theme | Command-center UX |
| **Database** | Supabase (PostgreSQL) | Schema provided, Phase 2 activation |
| **ML Backend** | FastAPI + XGBoost + SHAP | Phase 2 (swap-in ready) |

---

## 🚀 Quick Start

### Prerequisites
- **Node.js** 18+ and npm/yarn
- *Optional*: `.env.local` for Supabase credentials (Phase 2)

### Development
```bash
cd coolnet-ai-phase1
npm install
npm run dev
```

Open **http://localhost:3000** in your browser.

### Production Build
```bash
npm run build && npm start
```

---

## 📁 Project Structure

```
coolnet-ai-phase1/
├── app/
│   ├── layout.tsx              # Root layout & global styles
│   ├── page.tsx                # Dashboard shell with tabs
│   └── globals.css             # Dark command-center theme
│
├── components/
│   ├── layout/TopNav.tsx       # Top navigation bar
│   ├── map/
│   │   ├── RiskMap.tsx         # Leaflet wrapper (public API)
│   │   └── LeafletRiskMap.tsx  # Implementation
│   ├── panels/
│   │   ├── WardDetailPanel.tsx     # Ward-level insights
│   │   ├── ExplainabilityPanel.tsx # AI/ML explanations
│   │   ├── ForecastPanel.tsx       # 24–72h predictions
│   │   ├── WhatIfSimulator.tsx     # Scenario testing
│   │   ├── RecommendationPanel.tsx # Intervention suggestions
│   │   └── ...                     # (plus DataHealth, WardList, Interventions)
│   └── ui/
│       └── Card, RiskBadge, Slider, StatCard, etc.
│
├── lib/
│   ├── types.ts                # TypeScript contracts (entire pipeline)
│   ├── dashboardTabs.ts        # Tab definitions & metadata
│   ├── data/
│   │   ├── mockWards.ts        # Demo ward polygons & metadata
│   │   └── mockDataService.ts  # Weather/grid/vulnerability APIs (swappable)
│   ├── services/
│   │   ├── mlService.ts        # ML interface + DemoMLService
│   │   └── simulationEngine.ts # Transparent demo formulas
│   ├── supabase/
│   │   ├── schema.sql          # Target PostgreSQL schema
│   │   └── client.ts           # Supabase client factory
│   └── hooks/
│       ├── useWardSummaries.ts # Load ward list + risk
│       └── useWardInsights.ts  # Load explanations & forecasts
│
├── package.json
├── next.config.js
├── tailwind.config.js
└── tsconfig.json
```

---

## 🔄 Data Pipeline

```
LIVE/AVAILABLE DATA
    ↓
DATA PROCESSING (normalization, aggregation)
    ↓
GRID-STRESS/OUTAGE-RISK ML (trained model)
    ↓
COMPOUND RISK ENGINE (weighted scoring)
    ↓
EXPLAINABLE AI (SHAP, feature attribution)
    ↓
FORECAST (24–72h projections)
    ↓
WHAT-IF SIMULATION (intervention testing)
    ↓
INTERVENTION RECOMMENDATION (ranked actions)
    ↓
LIVE GIS MAP (ward-level visualization)
    ↓
FEEDBACK LOOP (operator observations)
```

---

## 🔌 Phase 2: Wiring Real APIs & Models

### 1. Environment Setup
Create `.env.local` from `.env.example`:
```env
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_ML_API_BASE_URL=http://localhost:8000  # FastAPI backend
```

**⚠️ Never commit secret keys or use `NEXT_PUBLIC_` for sensitive credentials.**

### 2. Replace ML Service
Implement `RemoteMLService` in `lib/services/mlService.ts` to call your FastAPI backend:
```typescript
// Keep the same MLService interface; just swap the implementation
class RemoteMLService implements MLService {
  async predictGridStress(wardId: string, ...): Promise<RiskPrediction> {
    // Call FastAPI + XGBoost + SHAP
  }
}
```

### 3. Replace Data Service
Update `lib/data/mockDataService.ts` to query Supabase and real weather/grid APIs:
```typescript
// Weather data: swap mock for real provider (NOAA, ERA5, etc.)
// Grid stress: swap for utility SCADA/EMS feeds
// Vulnerability: pull from Supabase wards + demographics tables
// Return types stay the same from lib/types.ts
```

### 4. Load Real Ward Boundaries
Replace `lib/data/mockWards.ts` with Supabase geojson queries:
```typescript
// SELECT wards.id, wards.name, ST_AsGeoJSON(geometry) FROM wards
```

**Key Principle**: No component in `app/` or `components/` needs to change. They depend only on:
- **`lib/types.ts`** — shared TypeScript contracts
- **`mockDataService`** → `realDataService` (same signatures)
- **`mlService`** → `RemoteMLService` (same interface)

---

## 📊 Dashboard Features

### 1. **Ward Risk Overview**
- Sortable table of all wards with compound risk scores
- Color-coded risk badges (low → medium → high → critical)
- Drill-down to individual ward details

### 2. **Risk Map**
- Interactive Leaflet map with ward polygons
- Real-time risk overlays (heatmap, choropleth)
- Legend and zoom controls
- Click-to-select ward for detail panel

### 3. **Ward Detail Panel**
- Current compound risk score breakdown
- Key risk drivers (temperature, demand, capacity)
- Recent trend (24h sparkline)
- Affected population & infrastructure summary

### 4. **Explainability Panel** *(AI/ML Insights)*
- SHAP-style feature importance plot
- Top 5 risk drivers with impact quantification
- Model prediction confidence score
- Counterfactual "what-if single factor" views

### 5. **Forecast Panel**
- 24h / 48h / 72h risk trajectory
- Confidence intervals around predictions
- Inflection points & peak risk times
- Downloadable forecast data

### 6. **What-If Simulator**
- Adjust parameters (demand cut, load shift, outage duration)
- See real-time risk recalculation
- Compare baseline vs. intervention scenarios
- Save & label scenarios for team review

### 7. **Recommendation Engine**
- AI-ranked interventions by impact/cost ratio
- Implementation timeline & resource requirements
- Risk reduction estimate per intervention
- Approval workflow hooks for operators

### 8. **Data Health Panel**
- Feed status (weather, grid, vulnerability APIs)
- Last update timestamp for each data source
- Missing data alerts
- Data quality metrics

---

## 🛡️ What This System Does **NOT** Do

✋ We are explicit about limitations:

- **Does not claim real-time data** (Phase 1 has no live feeds)
- **Does not claim a trained model** (all outputs use transparent demo formulas)
- **Does not guarantee outage prevention**
- **Does not invent accuracy metrics** or cite government datasets falsely
- **Does not auto-control grid infrastructure** — all recommendations are human-reviewed

Every demo output is labeled `DEMO DATA`, `DEMO FORECAST`, etc. in the UI.

---

## 🧪 Testing & Validation

### Local Development
- All demo data is regenerated on page load
- Mock weather, grid stress, and forecasts are deterministic
- Safe to test interventions and scenarios without side effects

### Phase 2 Validation
- Unit tests for `simulationEngine` formulas
- Integration tests for Supabase schema
- Comparison tests: demo formula vs. real ML model on historical data

---

## 📚 Key Files & Concepts

| File | Purpose |
|------|---------|
| `lib/types.ts` | Single source of truth for all data contracts |
| `lib/services/mlService.ts` | Abstract ML interface; swap implementations here |
| `lib/data/mockDataService.ts` | Abstraction over data sources; real or mock |
| `lib/services/simulationEngine.ts` | Documented formulas for risk scoring & simulation |
| `components/map/RiskMap.tsx` | Public API for map component; hides Leaflet details |
| `lib/supabase/schema.sql` | Target database structure (not used in Phase 1) |

---

## 🤝 Contributing

1. **Understand the pipeline**: Read `lib/services/simulationEngine.ts` to learn formulas
2. **Add a new panel**: Create in `components/panels/`, connect in `page.tsx`
3. **Swap a service**: Implement the interface in `lib/services/`, no component changes needed
4. **Query new data**: Update `mockDataService.ts` signature + all callers, or add a Supabase table

---

## 📄 License

[Add your license here or link to LICENSE file]

---

## 🎓 Learn More

- **Next.js**: https://nextjs.org/docs
- **Leaflet & react-leaflet**: https://react-leaflet.js.org
- **Supabase**: https://supabase.com/docs
- **Recharts**: https://recharts.org
- **SHAP** (for Phase 2 ML explanations): https://shap.readthedocs.io

---

## ❓ FAQ

**Q: Can I use this in production?**  
A: Not yet. Phase 1 is a demo / proof-of-concept. Phase 2 will wire real APIs and trained models.

**Q: Where do I add real weather data?**  
A: Replace the mock in `lib/data/mockDataService.ts` with a real provider (NOAA, ERA5, etc.) and Supabase queries.

**Q: How do I swap in a real ML model?**  
A: Implement `RemoteMLService` in `lib/services/mlService.ts` to call your FastAPI backend. No component changes needed.

**Q: What's the Supabase schema?**  
A: See `lib/supabase/schema.sql`. It's ready for Phase 2 but unused in Phase 1.

---

**Built with ❤️ for climate resilience.**
