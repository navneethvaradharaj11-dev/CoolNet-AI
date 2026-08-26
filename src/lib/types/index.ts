export type RiskLevel = 'LOW' | 'MODERATE' | 'HIGH' | 'CRITICAL';

export interface Ward {
  id: string;
  name: string;
  population: number;
  areaSqKm: number;
  center: [number, number];
  geometry: GeoJSON.Polygon;
}

export interface WeatherData {
  wardId?: string;
  temperature: number;
  humidity: number;
  heatIndex: number;
  wbgt?: number;
  timestamp: string;
  isReal?: boolean;
  
  // Real-time detailed weather metrics
  feelsLike?: number;
  condition?: string;
  windSpeed?: number;
  windDirection?: number;
  pressure?: number;
  visibility?: number;
  uvIndex?: number;
  precipitation?: number;
  source?: string;
}

export interface AddressDetails {
  road?: string;
  neighbourhood?: string;
  suburb?: string;
  city_district?: string;
  city?: string;
  town?: string;
  village?: string;
  county?: string;
  state?: string;
  postcode?: string;
  country?: string;
  country_code?: string;
  displayName?: string;
}

export interface GeospatialGridCell {
  id: string;
  center: [number, number]; // [lat, lng]
  bounds: [[number, number], [number, number]]; // [[south, west], [north, east]]
  north: number;
  south: number;
  east: number;
  west: number;
  areaSqKm: number;
  weather?: WeatherData;
  incidentCount: number;
}

export interface GridData { wardId: string; electricityDemand: number; gridStress: number; historicalOutageFreq: number; timestamp: string; }
export interface VulnerabilityData { wardId: string; vulnerabilityScore: number; coolingAccess: number; elderlyRatio: number; incomeIndex: number; }
export interface RiskPrediction { wardId: string; compoundRiskScore: number; riskLevel: RiskLevel; predicted30min: number; predicted60min: number; timestamp: string; }
export interface RiskExplanation { heatStress: number; gridStress: number; vulnerability: number; coolingAccess: number; }
export interface ForecastPoint { label: string; risk: number; riskLevel: RiskLevel; }
export interface SimulationInput { temperatureChange: number; demandChange: number; coolingAccessChange: number; wardId: string; }
export interface SimulationResult { originalRisk: number; newRisk: number; riskDelta: number; newRiskLevel: RiskLevel; explanation: RiskExplanation; }
export interface Intervention { id: string; title: string; description: string; priority: 'CRITICAL' | 'HIGH' | 'MODERATE' | 'LOW'; category: 'cooling' | 'alert' | 'grid' | 'planning' | 'medical'; applicableLevels: RiskLevel[]; }
export interface DataHealthStatus { source: string; status: 'demo' | 'live' | 'stale' | 'error'; lastUpdate: string; label: string; }
export interface WardFeatureData { ward: Ward; weather: WeatherData; grid: GridData; vulnerability: VulnerabilityData; risk: RiskPrediction; explanation: RiskExplanation; }

export interface MLFeatures {
  temperature: number; humidity: number; heatIndex: number; electricityDemand: number; gridStress: number;
  historicalOutageFreq: number; populationDensity: number; vulnerabilityScore: number; coolingAccess: number; timestamp: string; wardId: string;
}

export interface MLService {
  predictGridRisk(features: MLFeatures): Promise<number>;
  calculateCompoundRisk(features: MLFeatures): Promise<{ score: number; level: RiskLevel }>;
  getRiskExplanation(features: MLFeatures): Promise<RiskExplanation>;
  runScenarioSimulation(features: MLFeatures, scenario: SimulationInput): Promise<SimulationResult>;
}
