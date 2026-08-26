import { MLService, MLFeatures, RiskLevel, SimulationInput, SimulationResult, RiskExplanation } from '@/lib/types';

export const MODEL_VERSION = 'heuristic-v0';

export class MockMLService implements MLService {
  async predictGridRisk(features: MLFeatures): Promise<number> {
    const stressFromHeat = Math.max(0, (features.heatIndex - 35) * 4);
    const stressFromDemand = features.electricityDemand * 0.5;
    const stressFromHistory = features.historicalOutageFreq * 50;
    return Math.min(100, Math.max(0, stressFromHeat + stressFromDemand + stressFromHistory));
  }

  async calculateCompoundRisk(features: MLFeatures): Promise<{ score: number; level: RiskLevel }> {
    const heatScore = Math.min(100, Math.max(0, (features.heatIndex - 30) * 3));
    const gridScore = features.gridStress;
    const vulScore = features.vulnerabilityScore;
    const score = Math.round(heatScore * 0.4 + gridScore * 0.3 + vulScore * 0.3);
    const level: RiskLevel = score >= 70 ? 'CRITICAL' : score >= 50 ? 'HIGH' : score >= 30 ? 'MODERATE' : 'LOW';
    return { score, level };
  }

  async getRiskExplanation(features: MLFeatures): Promise<RiskExplanation> {
    return {
      heatStress: Math.min(100, Math.max(0, Math.round((features.heatIndex - 30) * 3))),
      gridStress: features.gridStress,
      vulnerability: features.vulnerabilityScore,
      coolingAccess: 100 - features.coolingAccess,
    };
  }

  async runScenarioSimulation(features: MLFeatures, scenario: SimulationInput): Promise<SimulationResult> {
    const originalResult = await this.calculateCompoundRisk(features);
    const modifiedFeatures: MLFeatures = {
      ...features,
      temperature: features.temperature + scenario.temperatureChange,
      heatIndex: features.heatIndex + scenario.temperatureChange * 1.2,
      electricityDemand: features.electricityDemand + scenario.demandChange,
      coolingAccess: Math.max(0, Math.min(100, features.coolingAccess + scenario.coolingAccessChange)),
    };
    modifiedFeatures.vulnerabilityScore = Math.max(0, Math.min(100, modifiedFeatures.vulnerabilityScore - scenario.coolingAccessChange * 0.5));
    const newResult = await this.calculateCompoundRisk(modifiedFeatures);
    return {
      originalRisk: originalResult.score,
      newRisk: newResult.score,
      riskDelta: newResult.score - originalResult.score,
      newRiskLevel: newResult.level,
      explanation: await this.getRiskExplanation(modifiedFeatures),
    };
  }
}

export function calculateHeatIndex(tempC: number, humidityPct: number): number {
  return Math.round((tempC + (humidityPct * 0.1)) * 10) / 10;
}

export function classifyRiskLevel(score: number): RiskLevel {
  return score >= 70 ? 'CRITICAL' : score >= 50 ? 'HIGH' : score >= 30 ? 'MODERATE' : 'LOW';
}

export const mockMLService = new MockMLService();

