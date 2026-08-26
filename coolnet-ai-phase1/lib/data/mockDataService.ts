import type {
  DataFeedHealth,
  Intervention,
  RiskLevel,
  WardFeatureSnapshot,
  WardMeta,
  WardSummary,
} from "@/lib/types";
import { DEMO_WARD_META } from "@/lib/data/mockWards";
import { mlService } from "@/lib/services/mlService";
import { fetchBatchLiveWeather } from "@/lib/services/weather-service";
import { supabase, isSupabaseConfigured } from "@/lib/supabase/client";

/**
 * Mock Data Service
 * -----------------------------------------------------------------------
 * DEMO DATA — not live, not real-time.
 *
 * This module fakes the "LIVE/AVAILABLE DATA → DATA PROCESSING" stages
 * of the pipeline. In Phase 2, these functions are replaced by:
 *   - Supabase queries against `weather_data`, `grid_data`,
 *     `vulnerability_data` (see lib/supabase/schema.sql)
 *   - Real weather/grid provider API calls, normalized into
 *     `WardFeatureSnapshot`
 *
 * The function signatures are designed to stay the same so the frontend
 * does not need to change when the real data layer is connected.
 */

function seededRandom(seed: number) {
  let t = seed + 0x6d2b79f5;
  return function () {
    t += 0x6d2b79f5;
    let r = Math.imul(t ^ (t >>> 15), 1 | t);
    r = (r + Math.imul(r ^ (r >>> 7), 61 | r)) ^ r;
    return ((r ^ (r >>> 14)) >>> 0) / 4294967296;
  };
}

function generateSnapshot(ward: WardMeta, seedOffset: number): WardFeatureSnapshot {
  const rand = seededRandom(ward.ward_id.charCodeAt(2) * 97 + seedOffset);

  const temperature = 33 + rand() * 12; // 33-45 C demo range
  const humidity = 25 + rand() * 45; // 25-70%
  // simplified demo heat index approximation (not the NOAA formula)
  const heat_index = temperature + humidity * 0.12;

  const electricity_demand = 55 + rand() * 40; // % of local capacity
  const grid_stress = Math.min(100, electricity_demand * 0.7 + rand() * 25);
  const historical_outage_frequency = Math.round(rand() * 6);

  const population_density = Math.round(2000 + rand() * 9000);
  const vulnerability_score = Math.round(20 + rand() * 75);
  const cooling_access = Math.round(15 + rand() * 75);

  return {
    ward_id: ward.ward_id,
    timestamp: new Date().toISOString(),
    temperature: Math.round(temperature * 10) / 10,
    humidity: Math.round(humidity),
    heat_index: Math.round(heat_index * 10) / 10,
    electricity_demand: Math.round(electricity_demand),
    grid_stress: Math.round(grid_stress),
    historical_outage_frequency,
    population_density,
    vulnerability_score,
    cooling_access,
  };
}

// Generated once per server/client lifecycle so numbers stay stable
// during a session, but with dynamic Live API overrides.
let snapshotCache: Map<string, WardFeatureSnapshot> | null = null;
let lastFetchTime = 0;
const CACHE_TTL = 30 * 1000; // Refetch live data every 30 seconds

async function loadSnapshots(): Promise<Map<string, WardFeatureSnapshot>> {
  const now = Date.now();
  if (snapshotCache && (now - lastFetchTime < CACHE_TTL)) {
    return snapshotCache;
  }

  const cache = new Map<string, WardFeatureSnapshot>();
  
  // 1. Generate baselines using the mock generator
  DEMO_WARD_META.forEach((ward, i) => {
    cache.set(ward.ward_id, generateSnapshot(ward, i * 13));
  });

  // 2. Fetch live Open-Meteo weather
  try {
    const liveWeatherMap = await fetchBatchLiveWeather();
    if (liveWeatherMap) {
      for (const [wardId, weather] of Object.entries(liveWeatherMap)) {
        const snap = cache.get(wardId);
        if (snap) {
          snap.temperature = weather.temperature;
          snap.humidity = weather.humidity;
          snap.heat_index = weather.heatIndex;
          snap.timestamp = weather.timestamp;
        }
      }
    }
  } catch (err) {
    console.warn("🌦 CoolNet Weather: Live weather fetch failed, falling back to mock", err);
  }

  // 3. Fetch database telemetry if Supabase is configured
  if (isSupabaseConfigured() && supabase) {
    try {
      console.log("⚡ CoolNet DB: Connecting to Supabase server...");
      const { data: gridData, error: gridError } = await supabase
        .from("grid_telemetry")
        .select("*");

      const { data: vulData, error: vulError } = await supabase
        .from("vulnerability_index")
        .select("*");

      if (gridError) throw gridError;
      if (vulError) throw vulError;

      if (gridData && gridData.length > 0) {
        gridData.forEach((item: any) => {
          const snap = cache.get(item.ward_id);
          if (snap) {
            snap.electricity_demand = Number(item.electricity_demand);
            snap.grid_stress = Number(item.grid_stress);
            snap.historical_outage_frequency = Number(item.historical_outage_freq);
          }
        });
      }

      if (vulData && vulData.length > 0) {
        vulData.forEach((item: any) => {
          const snap = cache.get(item.ward_id);
          if (snap) {
            snap.vulnerability_score = Number(item.vulnerability_score);
            snap.cooling_access = Number(item.cooling_access);
            if (item.population_density) {
              snap.population_density = Number(item.population_density);
            }
          }
        });
      }
      console.log("⚡ CoolNet DB: Successfully integrated live DB telemetry.");
    } catch (dbErr) {
      console.warn("⚡ CoolNet DB: Failed to fetch live DB telemetry", dbErr);
    }
  }

  snapshotCache = cache;
  lastFetchTime = now;
  return cache;
}

export async function getWardMeta(): Promise<WardMeta[]> {
  return DEMO_WARD_META;
}

export async function getWardFeatureSnapshot(
  wardId: string
): Promise<WardFeatureSnapshot | null> {
  const snapshots = await loadSnapshots();
  return snapshots.get(wardId) ?? null;
}

export async function getAllWardFeatureSnapshots(): Promise<WardFeatureSnapshot[]> {
  const snapshots = await loadSnapshots();
  return Array.from(snapshots.values());
}

export async function getWardSummaries(): Promise<WardSummary[]> {
  const snapshots = await loadSnapshots();
  const summaries = await Promise.all(
    DEMO_WARD_META.map(async (meta) => {
      const snapshot = snapshots.get(meta.ward_id)!;
      const compoundRisk = await mlService.calculateCompoundRisk(snapshot);
      return { meta, snapshot, compoundRisk };
    })
  );
  return summaries;
}

export async function getWardSummary(wardId: string): Promise<WardSummary | null> {
  const meta = DEMO_WARD_META.find((w) => w.ward_id === wardId);
  const snapshot = await getWardFeatureSnapshot(wardId);
  if (!meta || !snapshot) return null;
  const compoundRisk = await mlService.calculateCompoundRisk(snapshot);
  return { meta, snapshot, compoundRisk };
}

const INTERVENTIONS_BY_LEVEL: Record<RiskLevel, Omit<Intervention, "id" | "ward_id">[]> = {
  CRITICAL: [
    { risk_level: "CRITICAL", priority: 1, action: "Prepare cooling-centre activation", category: "cooling" },
    { risk_level: "CRITICAL", priority: 2, action: "Issue targeted local heat/grid alert", category: "communication" },
    { risk_level: "CRITICAL", priority: 3, action: "Notify electrical response team", category: "grid-ops" },
    { risk_level: "CRITICAL", priority: 4, action: "Prioritize restoration planning if an outage occurs", category: "restoration-planning" },
  ],
  HIGH: [
    { risk_level: "HIGH", priority: 1, action: "Pre-stage cooling-centre supplies", category: "cooling" },
    { risk_level: "HIGH", priority: 2, action: "Notify community outreach contacts", category: "communication" },
    { risk_level: "HIGH", priority: 3, action: "Flag ward for grid-ops monitoring", category: "grid-ops" },
  ],
  MODERATE: [
    { risk_level: "MODERATE", priority: 1, action: "Monitor ward for escalating heat/grid conditions", category: "grid-ops" },
    { risk_level: "MODERATE", priority: 2, action: "Share general cooling-access guidance", category: "communication" },
  ],
  LOW: [
    { risk_level: "LOW", priority: 1, action: "No preventive action required — continue routine monitoring", category: "grid-ops" },
  ],
};

export async function getInterventions(
  wardId: string,
  riskLevel: RiskLevel
): Promise<Intervention[]> {
  return INTERVENTIONS_BY_LEVEL[riskLevel].map((item, i) => ({
    ...item,
    id: `${wardId}-int-${i + 1}`,
    ward_id: wardId,
  }));
}

export async function getDataFeedHealth(): Promise<DataFeedHealth[]> {
  const now = new Date().toISOString();
  const dbActive = isSupabaseConfigured();
  return [
    {
      feed: "Weather Feed",
      status: "ONLINE",
      last_updated: now,
      detail: "Live Open-Meteo weather API connected and cached.",
    },
    {
      feed: "Grid Feed",
      status: dbActive ? "ONLINE" : "DEMO",
      last_updated: now,
      detail: dbActive ? "Live Supabase grid telemetry active." : "Demo grid-stress values. Connect Supabase in Phase 2.",
    },
    {
      feed: "Vulnerability Data",
      status: dbActive ? "ONLINE" : "DEMO",
      last_updated: now,
      detail: dbActive ? "Live Supabase vulnerability data active." : "Demo vulnerability index. Connect Supabase in Phase 2.",
    },
    {
      feed: "Ward GIS",
      status: "ONLINE",
      last_updated: now,
      detail: "Generated demo ward boundaries.",
    },
  ];
}
