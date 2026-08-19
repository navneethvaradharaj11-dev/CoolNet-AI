import { WeatherData, GridData, VulnerabilityData, RiskPrediction, RiskExplanation, WardFeatureData, Intervention, DataHealthStatus, RiskLevel, MLFeatures } from '@/lib/types';
import { WARDS } from '@/lib/geojson/wards';

const weatherMap: Record<string, WeatherData> = {
  'ward-01': { wardId: 'ward-01', temperature: 38.2, humidity: 62, heatIndex: 42.1, timestamp: '2025-07-15T14:30:00Z' },
  'ward-02': { wardId: 'ward-02', temperature: 39.5, humidity: 58, heatIndex: 43.4, timestamp: '2025-07-15T14:30:00Z' },
  'ward-03': { wardId: 'ward-03', temperature: 37.8, humidity: 65, heatIndex: 41.8, timestamp: '2025-07-15T14:30:00Z' },
  'ward-04': { wardId: 'ward-04', temperature: 36.5, humidity: 55, heatIndex: 39.8, timestamp: '2025-07-15T14:30:00Z' },
  'ward-05': { wardId: 'ward-05', temperature: 40.1, humidity: 68, heatIndex: 45.2, timestamp: '2025-07-15T14:30:00Z' },
  'ward-06': { wardId: 'ward-06', temperature: 37.2, humidity: 60, heatIndex: 41.0, timestamp: '2025-07-15T14:30:00Z' },
  'ward-07': { wardId: 'ward-07', temperature: 41.3, humidity: 72, heatIndex: 47.1, timestamp: '2025-07-15T14:30:00Z' },
  'ward-08': { wardId: 'ward-08', temperature: 38.8, humidity: 56, heatIndex: 42.6, timestamp: '2025-07-15T14:30:00Z' },
  'ward-09': { wardId: 'ward-09', temperature: 42.5, humidity: 75, heatIndex: 49.2, timestamp: '2025-07-15T14:30:00Z' },
  'ward-10': { wardId: 'ward-10', temperature: 36.8, humidity: 52, heatIndex: 39.5, timestamp: '2025-07-15T14:30:00Z' },
  'ward-11': { wardId: 'ward-11', temperature: 39.2, humidity: 64, heatIndex: 43.8, timestamp: '2025-07-15T14:30:00Z' },
  'ward-12': { wardId: 'ward-12', temperature: 37.5, humidity: 58, heatIndex: 40.8, timestamp: '2025-07-15T14:30:00Z' },
  'ward-13': { wardId: 'ward-13', temperature: 40.8, humidity: 70, heatIndex: 46.5, timestamp: '2025-07-15T14:30:00Z' },
  'ward-14': { wardId: 'ward-14', temperature: 35.9, humidity: 50, heatIndex: 38.2, timestamp: '2025-07-15T14:30:00Z' },
  'ward-15': { wardId: 'ward-15', temperature: 38.5, humidity: 63, heatIndex: 42.4, timestamp: '2025-07-15T14:30:00Z' },
  'ward-16': { wardId: 'ward-16', temperature: 37.0, humidity: 57, heatIndex: 40.5, timestamp: '2025-07-15T14:30:00Z' },
  'ward-17': { wardId: 'ward-17', temperature: 43.0, humidity: 78, heatIndex: 51.8, timestamp: '2025-07-15T14:30:00Z' },
  'ward-18': { wardId: 'ward-18', temperature: 36.2, humidity: 53, heatIndex: 38.8, timestamp: '2025-07-15T14:30:00Z' },
  'ward-19': { wardId: 'ward-19', temperature: 41.8, humidity: 73, heatIndex: 48.4, timestamp: '2025-07-15T14:30:00Z' },
  'ward-20': { wardId: 'ward-20', temperature: 37.8, humidity: 59, heatIndex: 41.5, timestamp: '2025-07-15T14:30:00Z' },
};

const gridMap: Record<string, GridData> = {
  'ward-01': { wardId: 'ward-01', electricityDemand: 78, gridStress: 62, historicalOutageFreq: 0.12, timestamp: '2025-07-15T14:30:00Z' },
  'ward-02': { wardId: 'ward-02', electricityDemand: 82, gridStress: 68, historicalOutageFreq: 0.18, timestamp: '2025-07-15T14:30:00Z' },
  'ward-03': { wardId: 'ward-03', electricityDemand: 85, gridStress: 72, historicalOutageFreq: 0.22, timestamp: '2025-07-15T14:30:00Z' },
  'ward-04': { wardId: 'ward-04', electricityDemand: 65, gridStress: 48, historicalOutageFreq: 0.06, timestamp: '2025-07-15T14:30:00Z' },
  'ward-05': { wardId: 'ward-05', electricityDemand: 88, gridStress: 74, historicalOutageFreq: 0.25, timestamp: '2025-07-15T14:30:00Z' },
  'ward-06': { wardId: 'ward-06', electricityDemand: 72, gridStress: 58, historicalOutageFreq: 0.10, timestamp: '2025-07-15T14:30:00Z' },
  'ward-07': { wardId: 'ward-07', electricityDemand: 91, gridStress: 78, historicalOutageFreq: 0.30, timestamp: '2025-07-15T14:30:00Z' },
  'ward-08': { wardId: 'ward-08', electricityDemand: 76, gridStress: 60, historicalOutageFreq: 0.14, timestamp: '2025-07-15T14:30:00Z' },
  'ward-09': { wardId: 'ward-09', electricityDemand: 94, gridStress: 85, historicalOutageFreq: 0.35, timestamp: '2025-07-15T14:30:00Z' },
  'ward-10': { wardId: 'ward-10', electricityDemand: 68, gridStress: 52, historicalOutageFreq: 0.08, timestamp: '2025-07-15T14:30:00Z' },
  'ward-11': { wardId: 'ward-11', electricityDemand: 80, gridStress: 65, historicalOutageFreq: 0.16, timestamp: '2025-07-15T14:30:00Z' },
  'ward-12': { wardId: 'ward-12', electricityDemand: 74, gridStress: 59, historicalOutageFreq: 0.11, timestamp: '2025-07-15T14:30:00Z' },
  'ward-13': { wardId: 'ward-13', electricityDemand: 89, gridStress: 75, historicalOutageFreq: 0.28, timestamp: '2025-07-15T14:30:00Z' },
  'ward-14': { wardId: 'ward-14', electricityDemand: 62, gridStress: 45, historicalOutageFreq: 0.05, timestamp: '2025-07-15T14:30:00Z' },
  'ward-15': { wardId: 'ward-15', electricityDemand: 83, gridStress: 69, historicalOutageFreq: 0.20, timestamp: '2025-07-15T14:30:00Z' },
  'ward-16': { wardId: 'ward-16', electricityDemand: 71, gridStress: 55, historicalOutageFreq: 0.09, timestamp: '2025-07-15T14:30:00Z' },
  'ward-17': { wardId: 'ward-17', electricityDemand: 96, gridStress: 88, historicalOutageFreq: 0.40, timestamp: '2025-07-15T14:30:00Z' },
  'ward-18': { wardId: 'ward-18', electricityDemand: 66, gridStress: 50, historicalOutageFreq: 0.07, timestamp: '2025-07-15T14:30:00Z' },
  'ward-19': { wardId: 'ward-19', electricityDemand: 92, gridStress: 82, historicalOutageFreq: 0.32, timestamp: '2025-07-15T14:30:00Z' },
  'ward-20': { wardId: 'ward-20', electricityDemand: 79, gridStress: 63, historicalOutageFreq: 0.15, timestamp: '2025-07-15T14:30:00Z' },
};

const vulnerabilityMap: Record<string, VulnerabilityData> = {
  'ward-01': { wardId: 'ward-01', vulnerabilityScore: 45, coolingAccess: 62, elderlyRatio: 12, incomeIndex: 55 },
  'ward-02': { wardId: 'ward-02', vulnerabilityScore: 58, coolingAccess: 48, elderlyRatio: 15, incomeIndex: 42 },
  'ward-03': { wardId: 'ward-03', vulnerabilityScore: 62, coolingAccess: 45, elderlyRatio: 18, incomeIndex: 38 },
  'ward-04': { wardId: 'ward-04', vulnerabilityScore: 30, coolingAccess: 78, elderlyRatio: 8, incomeIndex: 72 },
  'ward-05': { wardId: 'ward-05', vulnerabilityScore: 68, coolingAccess: 40, elderlyRatio: 20, incomeIndex: 35 },
  'ward-06': { wardId: 'ward-06', vulnerabilityScore: 42, coolingAccess: 65, elderlyRatio: 11, incomeIndex: 58 },
  'ward-07': { wardId: 'ward-07', vulnerabilityScore: 75, coolingAccess: 35, elderlyRatio: 22, incomeIndex: 28 },
  'ward-08': { wardId: 'ward-08', vulnerabilityScore: 50, coolingAccess: 55, elderlyRatio: 14, incomeIndex: 50 },
  'ward-09': { wardId: 'ward-09', vulnerabilityScore: 82, coolingAccess: 28, elderlyRatio: 25, incomeIndex: 22 },
  'ward-10': { wardId: 'ward-10', vulnerabilityScore: 35, coolingAccess: 72, elderlyRatio: 9, incomeIndex: 68 },
  'ward-11': { wardId: 'ward-11', vulnerabilityScore: 55, coolingAccess: 50, elderlyRatio: 16, incomeIndex: 45 },
  'ward-12': { wardId: 'ward-12', vulnerabilityScore: 48, coolingAccess: 60, elderlyRatio: 13, incomeIndex: 52 },
  'ward-13': { wardId: 'ward-13', vulnerabilityScore: 72, coolingAccess: 38, elderlyRatio: 21, incomeIndex: 30 },
  'ward-14': { wardId: 'ward-14', vulnerabilityScore: 28, coolingAccess: 80, elderlyRatio: 7, incomeIndex: 75 },
  'ward-15': { wardId: 'ward-15', vulnerabilityScore: 60, coolingAccess: 46, elderlyRatio: 17, incomeIndex: 40 },
  'ward-16': { wardId: 'ward-16', vulnerabilityScore: 40, coolingAccess: 68, elderlyRatio: 10, incomeIndex: 60 },
  'ward-17': { wardId: 'ward-17', vulnerabilityScore: 85, coolingAccess: 25, elderlyRatio: 26, incomeIndex: 20 },
  'ward-18': { wardId: 'ward-18', vulnerabilityScore: 32, coolingAccess: 75, elderlyRatio: 8, incomeIndex: 70 },
  'ward-19': { wardId: 'ward-19', vulnerabilityScore: 78, coolingAccess: 32, elderlyRatio: 24, incomeIndex: 25 },
  'ward-20': { wardId: 'ward-20', vulnerabilityScore: 52, coolingAccess: 52, elderlyRatio: 15, incomeIndex: 48 },
};

const riskMap: Record<string, RiskPrediction> = {
  'ward-01': { wardId: 'ward-01', compoundRiskScore: 45, riskLevel: 'MODERATE', predicted30min: 48, predicted60min: 52, timestamp: '2025-07-15T14:30:00Z' },
  'ward-02': { wardId: 'ward-02', compoundRiskScore: 58, riskLevel: 'HIGH', predicted30min: 61, predicted60min: 65, timestamp: '2025-07-15T14:30:00Z' },
  'ward-03': { wardId: 'ward-03', compoundRiskScore: 62, riskLevel: 'HIGH', predicted30min: 64, predicted60min: 68, timestamp: '2025-07-15T14:30:00Z' },
  'ward-04': { wardId: 'ward-04', compoundRiskScore: 28, riskLevel: 'LOW', predicted30min: 30, predicted60min: 33, timestamp: '2025-07-15T14:30:00Z' },
  'ward-05': { wardId: 'ward-05', compoundRiskScore: 68, riskLevel: 'HIGH', predicted30min: 71, predicted60min: 75, timestamp: '2025-07-15T14:30:00Z' },
  'ward-06': { wardId: 'ward-06', compoundRiskScore: 42, riskLevel: 'MODERATE', predicted30min: 45, predicted60min: 49, timestamp: '2025-07-15T14:30:00Z' },
  'ward-07': { wardId: 'ward-07', compoundRiskScore: 75, riskLevel: 'CRITICAL', predicted30min: 78, predicted60min: 82, timestamp: '2025-07-15T14:30:00Z' },
  'ward-08': { wardId: 'ward-08', compoundRiskScore: 50, riskLevel: 'MODERATE', predicted30min: 52, predicted60min: 55, timestamp: '2025-07-15T14:30:00Z' },
  'ward-09': { wardId: 'ward-09', compoundRiskScore: 82, riskLevel: 'CRITICAL', predicted30min: 85, predicted60min: 89, timestamp: '2025-07-15T14:30:00Z' },
  'ward-10': { wardId: 'ward-10', compoundRiskScore: 35, riskLevel: 'LOW', predicted30min: 37, predicted60min: 40, timestamp: '2025-07-15T14:30:00Z' },
  'ward-11': { wardId: 'ward-11', compoundRiskScore: 55, riskLevel: 'MODERATE', predicted30min: 58, predicted60min: 62, timestamp: '2025-07-15T14:30:00Z' },
  'ward-12': { wardId: 'ward-12', compoundRiskScore: 48, riskLevel: 'MODERATE', predicted30min: 50, predicted60min: 53, timestamp: '2025-07-15T14:30:00Z' },
  'ward-13': { wardId: 'ward-13', compoundRiskScore: 72, riskLevel: 'CRITICAL', predicted30min: 75, predicted60min: 79, timestamp: '2025-07-15T14:30:00Z' },
  'ward-14': { wardId: 'ward-14', compoundRiskScore: 25, riskLevel: 'LOW', predicted30min: 26, predicted60min: 28, timestamp: '2025-07-15T14:30:00Z' },
  'ward-15': { wardId: 'ward-15', compoundRiskScore: 60, riskLevel: 'HIGH', predicted30min: 63, predicted60min: 66, timestamp: '2025-07-15T14:30:00Z' },
  'ward-16': { wardId: 'ward-16', compoundRiskScore: 40, riskLevel: 'MODERATE', predicted30min: 42, predicted60min: 45, timestamp: '2025-07-15T14:30:00Z' },
  'ward-17': { wardId: 'ward-17', compoundRiskScore: 88, riskLevel: 'CRITICAL', predicted30min: 91, predicted60min: 95, timestamp: '2025-07-15T14:30:00Z' },
  'ward-18': { wardId: 'ward-18', compoundRiskScore: 32, riskLevel: 'LOW', predicted30min: 34, predicted60min: 36, timestamp: '2025-07-15T14:30:00Z' },
  'ward-19': { wardId: 'ward-19', compoundRiskScore: 78, riskLevel: 'CRITICAL', predicted30min: 81, predicted60min: 85, timestamp: '2025-07-15T14:30:00Z' },
  'ward-20': { wardId: 'ward-20', compoundRiskScore: 52, riskLevel: 'MODERATE', predicted30min: 55, predicted60min: 58, timestamp: '2025-07-15T14:30:00Z' },
};

export const INTERVENTIONS: Intervention[] = [
  { id: 'int-01', title: 'Deploy Mobile Cooling Stations', description: 'Deploy AC buses and tents in high-density, low-cooling-access areas.', priority: 'CRITICAL', category: 'cooling', applicableLevels: ['CRITICAL', 'HIGH'] },
  { id: 'int-02', title: 'Issue Public Heat Advisory', description: 'Broadcast SMS and radio alerts for vulnerable populations.', priority: 'HIGH', category: 'alert', applicableLevels: ['CRITICAL', 'HIGH', 'MODERATE'] },
  { id: 'int-03', title: 'Preemptive Grid Load Shedding', description: 'Rotate outages in low-vulnerability zones to protect critical infrastructure.', priority: 'CRITICAL', category: 'grid', applicableLevels: ['CRITICAL'] },
  { id: 'int-04', title: 'Distribute ORS Packets', description: 'Medical teams to distribute Oral Rehydration Salts in elderly-heavy wards.', priority: 'HIGH', category: 'medical', applicableLevels: ['CRITICAL', 'HIGH'] },
  { id: 'int-05', title: 'Suspend Non-Essential Construction', description: 'Enforce midday work bans for outdoor laborers.', priority: 'MODERATE', category: 'planning', applicableLevels: ['CRITICAL', 'HIGH', 'MODERATE'] },
];

export const DATA_HEALTH: DataHealthStatus[] = [
  { source: 'Weather API', status: 'demo', lastUpdate: '2025-07-15T14:30:00Z', label: 'Mock Weather Data' },
  { source: 'Grid Telemetry', status: 'demo', lastUpdate: '2025-07-15T14:30:00Z', label: 'Mock Grid Data' },
  { source: 'Vulnerability Index', status: 'demo', lastUpdate: '2025-07-15T14:30:00Z', label: 'Mock SVI Data' },
  { source: 'ML Model', status: 'demo', lastUpdate: '2025-07-15T14:30:00Z', label: 'Heuristic v0' },
];

export function getWardFeatureData(wardId: string): WardFeatureData | null {
  const ward = WARDS.find(w => w.id === wardId);
  if (!ward) return null;
  const weather = weatherMap[wardId];
  const grid = gridMap[wardId];
  const vulnerability = vulnerabilityMap[wardId];
  const risk = riskMap[wardId];
  if (!weather || !grid || !vulnerability || !risk) return null;

  const explanation: RiskExplanation = {
    heatStress: Math.min(100, Math.round((weather.heatIndex - 30) * 3)),
    gridStress: grid.gridStress,
    vulnerability: vulnerability.vulnerabilityScore,
    coolingAccess: 100 - vulnerability.coolingAccess,
  };
  return { ward, weather, grid, vulnerability, risk, explanation };
}

export function getAllWardsFeatureData(): WardFeatureData[] {
  return WARDS.map(w => getWardFeatureData(w.id)).filter((w): w is WardFeatureData => w !== null);
}

export function getInterventionsForLevel(level: RiskLevel): Intervention[] {
  return INTERVENTIONS.filter(i => i.applicableLevels.includes(level));
}

export function getWardFeaturesForML(wardId: string): MLFeatures | null {
  const data = getWardFeatureData(wardId);
  if (!data) return null;
  return {
    temperature: data.weather.temperature, humidity: data.weather.humidity, heatIndex: data.weather.heatIndex,
    electricityDemand: data.grid.electricityDemand, gridStress: data.grid.gridStress, historicalOutageFreq: data.grid.historicalOutageFreq,
    populationDensity: data.ward.population / data.ward.areaSqKm, vulnerabilityScore: data.vulnerability.vulnerabilityScore,
    coolingAccess: data.vulnerability.coolingAccess, timestamp: data.weather.timestamp, wardId,
  };
}
