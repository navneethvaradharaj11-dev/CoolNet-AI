import { WeatherData, GridData, VulnerabilityData, RiskPrediction, RiskExplanation, WardFeatureData, Intervention, DataHealthStatus, RiskLevel, MLFeatures } from '@/lib/types';
import { WARDS } from '@/lib/geojson/wards';
import { calculateHeatIndex } from '@/lib/physics/heat-index';
import { applyHeatDiffusion } from '@/lib/physics/heat-diffusion';

// Base temperature and humidity data for 20 wards in Delhi (MoES/IMD anchored range 35.9-43.0 C)
const rawWeather: Record<string, { temp: number; hum: number; timestamp: string }> = {
  'ward-01': { temp: 38.2, hum: 62, timestamp: '2025-07-15T14:30:00Z' },
  'ward-02': { temp: 39.5, hum: 58, timestamp: '2025-07-15T14:30:00Z' },
  'ward-03': { temp: 37.8, hum: 65, timestamp: '2025-07-15T14:30:00Z' },
  'ward-04': { temp: 36.5, hum: 55, timestamp: '2025-07-15T14:30:00Z' },
  'ward-05': { temp: 40.1, hum: 68, timestamp: '2025-07-15T14:30:00Z' },
  'ward-06': { temp: 37.2, hum: 60, timestamp: '2025-07-15T14:30:00Z' },
  'ward-07': { temp: 41.3, hum: 72, timestamp: '2025-07-15T14:30:00Z' },
  'ward-08': { temp: 38.8, hum: 56, timestamp: '2025-07-15T14:30:00Z' },
  'ward-09': { temp: 42.5, hum: 75, timestamp: '2025-07-15T14:30:00Z' },
  'ward-10': { temp: 36.8, hum: 52, timestamp: '2025-07-15T14:30:00Z' },
  'ward-11': { temp: 39.2, hum: 64, timestamp: '2025-07-15T14:30:00Z' },
  'ward-12': { temp: 37.5, hum: 58, timestamp: '2025-07-15T14:30:00Z' },
  'ward-13': { temp: 40.8, hum: 70, timestamp: '2025-07-15T14:30:00Z' },
  'ward-14': { temp: 35.9, hum: 50, timestamp: '2025-07-15T14:30:00Z' },
  'ward-15': { temp: 38.5, hum: 63, timestamp: '2025-07-15T14:30:00Z' },
  'ward-16': { temp: 37.0, hum: 57, timestamp: '2025-07-15T14:30:00Z' },
  'ward-17': { temp: 43.0, hum: 78, timestamp: '2025-07-15T14:30:00Z' },
  'ward-18': { temp: 36.2, hum: 53, timestamp: '2025-07-15T14:30:00Z' },
  'ward-19': { temp: 41.8, hum: 73, timestamp: '2025-07-15T14:30:00Z' },
  'ward-20': { temp: 37.8, hum: 59, timestamp: '2025-07-15T14:30:00Z' },
};

// Dynamically generate weatherMap by calculating NWS thermodynamic Heat Index
export const weatherMap: Record<string, WeatherData> = {};
Object.entries(rawWeather).forEach(([wardId, item]) => {
  weatherMap[wardId] = {
    wardId,
    temperature: item.temp,
    humidity: item.hum,
    heatIndex: calculateHeatIndex(item.temp, item.hum),
    timestamp: item.timestamp,
  };
});

// Dynamic gridMap generation. Correlates electricity demand to rise sharply above 35-38°C
export const gridMap: Record<string, GridData> = {};
WARDS.forEach(w => {
  const weather = weatherMap[w.id];
  const temp = weather ? weather.temperature : 35;
  
  // Base demand: 55%. If temp rises above 35°C, demand increases sharply (calibrated demand rise)
  const baseDemand = 55;
  const demandOver35 = Math.max(0, temp - 35);
  const electricityDemand = Math.round(Math.min(99, baseDemand + demandOver35 * 5.5));
  
  // Grid stress scaled to demand and historical outage frequencies
  const baseOutageFreq = w.id.charCodeAt(w.id.length - 1) % 2 === 0 ? 0.25 : 0.10;
  const gridStress = Math.round(Math.min(99, electricityDemand * 0.8 + baseOutageFreq * 40));
  
  gridMap[w.id] = {
    wardId: w.id,
    electricityDemand,
    gridStress,
    historicalOutageFreq: baseOutageFreq,
    timestamp: '2025-07-15T14:30:00Z'
  };
});

// Differentiated vulnerabilityMap
export const vulnerabilityMap: Record<string, VulnerabilityData> = {
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

// Spatial Heat Diffusion calculation
const diffusionInputs = WARDS.map(w => ({
  id: w.id,
  centroid: w.center,
  heatIndex: weatherMap[w.id].heatIndex,
  populationDensity: w.population / w.areaSqKm,
}));

const diffusedHeatMap = applyHeatDiffusion(diffusionInputs, 0.20);

// Dynamically generate riskMap using diffused heat + grid stress + vulnerability
export const riskMap: Record<string, RiskPrediction> = {};
export const explanationMap: Record<string, RiskExplanation> = {};

WARDS.forEach(w => {
  const diffusedHeat = diffusedHeatMap[w.id];
  const grid = gridMap[w.id];
  const vulnerability = vulnerabilityMap[w.id];
  
  // Calculate relative heat score scaled above 30°C
  const heatScore = Math.min(100, Math.max(0, Math.round((diffusedHeat - 30) * 3)));
  const gridScore = grid.gridStress;
  const vulScore = vulnerability.vulnerabilityScore;
  
  // Compute compound score using weights
  const compoundRiskScore = Math.round(heatScore * 0.4 + gridScore * 0.3 + vulScore * 0.3);
  
  const riskLevel: RiskLevel = 
    compoundRiskScore >= 70 ? 'CRITICAL' : 
    compoundRiskScore >= 50 ? 'HIGH' : 
    compoundRiskScore >= 30 ? 'MODERATE' : 'LOW';

  riskMap[w.id] = {
    wardId: w.id,
    compoundRiskScore,
    riskLevel,
    predicted30min: Math.min(100, compoundRiskScore + 3),
    predicted60min: Math.min(100, compoundRiskScore + 6),
    timestamp: '2025-07-15T14:30:00Z',
  };

  explanationMap[w.id] = {
    heatStress: heatScore,
    gridStress: gridScore,
    vulnerability: vulScore,
    coolingAccess: 100 - vulnerability.coolingAccess,
  };
});

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
  { source: 'Heat Index Formula', status: 'live', lastUpdate: '2025-07-15T14:30:00Z', label: 'Real formula (NWS Rothfusz)' },
  { source: 'ML Model', status: 'demo', lastUpdate: '2025-07-15T14:30:00Z', label: 'Heuristic v0' },
];

export function getWardFeatureData(wardId: string): WardFeatureData | null {
  const ward = WARDS.find(w => w.id === wardId);
  if (!ward) return null;
  const weather = weatherMap[wardId];
  const grid = gridMap[wardId];
  const vulnerability = vulnerabilityMap[wardId];
  const risk = riskMap[wardId];
  const explanation = explanationMap[wardId];
  if (!weather || !grid || !vulnerability || !risk || !explanation) return null;

  return { ward, weather, grid, vulnerability, risk, explanation };
}

export function getAllWardsFeatureData(): WardFeatureData[] {
  return WARDS.map(w => getWardFeatureData(w.id)).filter((w): w is WardFeatureData => w !== null);
}

export function getInterventionsForLevel(level: RiskLevel): Intervention[] {
  return INTERVENTIONS.filter(i => i.applicableLevels?.includes(level));
}

export function getWardFeaturesForML(wardId: string): MLFeatures | null {
  const data = getWardFeatureData(wardId);
  if (!data) return null;
  return {
    temperature: data.weather.temperature,
    humidity: data.weather.humidity,
    heatIndex: data.weather.heatIndex,
    electricityDemand: data.grid.electricityDemand,
    gridStress: data.grid.gridStress,
    historicalOutageFreq: data.grid.historicalOutageFreq,
    populationDensity: data.ward.population / data.ward.areaSqKm,
    vulnerabilityScore: data.vulnerability.vulnerabilityScore,
    coolingAccess: data.vulnerability.coolingAccess,
    timestamp: data.weather.timestamp,
    wardId,
  };
}
