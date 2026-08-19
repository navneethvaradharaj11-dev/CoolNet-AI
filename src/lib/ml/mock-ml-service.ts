/**
 * Legacy heuristic mock engine for CoolNet AI.
 * Calculates compound risk score using deterministic weighted formulas.
 */

import { getWardById } from "../geojson/wards";
import { FeatureContribution, RiskLevel, WardInputFeatures, WardRiskPrediction } from "./types";

/**
 * Calculates Heat Index using the standard Rothfusz regression equation.
 */
export function calculateHeatIndex(tempC: number, humidityPct: number): number {
  // Convert Celsius to Fahrenheit
  const T = (tempC * 9) / 5 + 32;
  const R = humidityPct;

  let HI_F =
    0.5 * (T + 61.0 + (T - 68.0) * 1.2 + R * 0.094);

  if (HI_F >= 80) {
    HI_F =
      -42.379 +
      2.04901523 * T +
      10.14333127 * R -
      0.22475541 * T * R -
      0.00683783 * T * T -
      0.05481717 * R * R +
      0.00122874 * T * T * R +
      0.00085282 * T * R * R -
      0.00000199 * T * T * R * R;
  }

  // Convert back to Celsius
  return ((HI_F - 32) * 5) / 9;
}

export function classifyRiskLevel(score: number): RiskLevel {
  if (score >= 80) return "CRITICAL";
  if (score >= 60) return "HIGH";
  if (score >= 35) return "MODERATE";
  return "LOW";
}

/**
 * Baseline mock heuristic risk predictor.
 */
export async function predictWardRiskHeuristic(input: WardInputFeatures): Promise<WardRiskPrediction> {
  const wardMeta = getWardById(input.wardId);
  const popDensity = input.populationDensity ?? wardMeta?.populationDensity ?? 20000;
  const vulnIndex = input.vulnerabilityIndex ?? wardMeta?.baselineVulnerabilityIndex ?? 0.7;

  const heatIndex = input.heatIndex ?? calculateHeatIndex(input.temperature, input.humidity);

  // Heuristic normalization (0.0 - 1.0)
  const normTemp = Math.min(Math.max((input.temperature - 28) / (48 - 28), 0), 1);
  const normHeatIndex = Math.min(Math.max((heatIndex - 30) / (55 - 30), 0), 1);
  const normGridDemand = Math.min(Math.max(input.electricityDemandPct / 100, 0), 1);
  const normOutage = Math.min(Math.max(input.outageProbability, 0), 1);
  const normDensity = Math.min(Math.max(popDensity / 35000, 0), 1);
  const normVuln = Math.min(Math.max(vulnIndex, 0), 1);

  // Non-linear amplification above 38°C
  const heatStressMultiplier = input.temperature > 38 ? 1.25 : 1.0;

  const rawScore =
    (normTemp * 0.22 +
      normHeatIndex * 0.25 +
      normGridDemand * 0.20 * heatStressMultiplier +
      normOutage * 0.15 +
      normDensity * 0.08 +
      normVuln * 0.10) *
    100;

  const riskScore = Math.round(Math.min(Math.max(rawScore, 0), 100) * 10) / 10;
  const riskLevel = classifyRiskLevel(riskScore);

  const featureContributions: FeatureContribution[] = [
    {
      feature: "temperature",
      displayName: "Ambient Temperature",
      value: input.temperature,
      unit: "°C",
      importanceWeight: 0.22,
      contributionScore: Math.round(normTemp * 22 * 10) / 10,
      description: input.temperature > 40 ? "Extreme ambient heatwave" : "Elevated ambient temperature",
    },
    {
      feature: "heat_index",
      displayName: "Heat Index (Apparent Temp)",
      value: Math.round(heatIndex * 10) / 10,
      unit: "°C",
      importanceWeight: 0.25,
      contributionScore: Math.round(normHeatIndex * 25 * 10) / 10,
      description: heatIndex > 45 ? "Dangerous physiological heat stress" : "Moderate apparent heat index",
    },
    {
      feature: "electricity_demand",
      displayName: "Grid Demand Load",
      value: input.electricityDemandPct,
      unit: "%",
      importanceWeight: 0.20,
      contributionScore: Math.round(normGridDemand * 20 * heatStressMultiplier * 10) / 10,
      description: input.electricityDemandPct > 85 ? "Peak electrical transformer strain" : "Moderate grid loading",
    },
    {
      feature: "outage_probability",
      displayName: "Grid Outage Probability",
      value: Math.round(input.outageProbability * 100),
      unit: "%",
      importanceWeight: 0.15,
      contributionScore: Math.round(normOutage * 15 * 10) / 10,
      description: input.outageProbability > 0.4 ? "High likelihood of feeder trip/outage" : "Stable grid feeder line",
    },
    {
      feature: "vulnerability_index",
      displayName: "Human Vulnerability",
      value: Math.round(vulnIndex * 100) / 100,
      unit: "idx",
      importanceWeight: 0.10,
      contributionScore: Math.round(normVuln * 10 * 10) / 10,
      description: vulnIndex > 0.75 ? "High elderly and dense informal housing" : "Moderate social vulnerability",
    },
    {
      feature: "population_density",
      displayName: "Population Density",
      value: popDensity,
      unit: "ppl/km²",
      importanceWeight: 0.08,
      contributionScore: Math.round(normDensity * 8 * 10) / 10,
      description: `${popDensity.toLocaleString()} residents per km²`,
    },
  ];

  return {
    wardId: input.wardId,
    riskScore,
    riskLevel,
    featureContributions,
    metrics: {
      temperature: input.temperature,
      humidity: input.humidity,
      heatIndex: Math.round(heatIndex * 10) / 10,
      electricityDemandPct: input.electricityDemandPct,
      outageProbability: input.outageProbability,
      populationDensity: popDensity,
      vulnerabilityIndex: vulnIndex,
    },
    inferenceSource: "heuristic",
    timestamp: new Date().toISOString(),
  };
}

export async function predictAllWardsHeuristic(inputs: WardInputFeatures[]): Promise<WardRiskPrediction[]> {
  return Promise.all(inputs.map(predictWardRiskHeuristic));
}
