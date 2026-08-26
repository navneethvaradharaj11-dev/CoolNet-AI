/**
 * Type definitions for CoolNet AI ML inference engine.
 */

export type RiskLevel = "LOW" | "MODERATE" | "HIGH" | "CRITICAL";

export interface WardInputFeatures {
  wardId: string;
  temperature: number; // in °C (e.g. 38.5)
  humidity: number; // in % (e.g. 65)
  heatIndex?: number; // in °C (calculated if omitted)
  electricityDemandPct: number; // 0 - 100% grid capacity load
  outageProbability: number; // 0.0 - 1.0
  populationDensity?: number; // people per sq km (defaults to ward baseline)
  vulnerabilityIndex?: number; // 0.0 - 1.0 (defaults to ward baseline)
}

export interface FeatureContribution {
  feature: string;
  displayName: string;
  value: number;
  unit: string;
  importanceWeight: number; // Global importance (0.0 - 1.0)
  contributionScore: number; // Local attribution to compound score
  description: string;
}

export interface WardRiskPrediction {
  wardId: string;
  riskScore: number; // 0 - 100 compound risk score
  riskLevel: RiskLevel;
  featureContributions: FeatureContribution[];
  metrics: {
    temperature: number;
    humidity: number;
    heatIndex: number;
    electricityDemandPct: number;
    outageProbability: number;
    populationDensity: number;
    vulnerabilityIndex: number;
  };
  inferenceSource: "onnx-runtime" | "onnx-tree-fallback" | "heuristic";
  timestamp: string;
}
