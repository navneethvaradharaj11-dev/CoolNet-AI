/**
 * CoolNet AI - Ward Catalog & Spatial GeoJSON Metadata
 * Defines urban wards with demographic baseline, density, and vulnerability indices.
 */

export interface WardDefinition {
  wardId: string;
  wardName: string;
  zone: string;
  population: number;
  areaSqKm: number;
  populationDensity: number; // people per sq km
  baselineVulnerabilityIndex: number; // 0.0 - 1.0
  coordinates: [number, number]; // [longitude, latitude]
  criticalFacilities: {
    hospitals: number;
    coolingCenters: number;
    elderlyCareCenters: number;
  };
}

export const WARDS_DATA: WardDefinition[] = [
  {
    wardId: "W001",
    wardName: "Royapuram",
    zone: "Zone 5 (North)",
    population: 48500,
    areaSqKm: 1.8,
    populationDensity: 26944,
    baselineVulnerabilityIndex: 0.88,
    coordinates: [80.2941, 13.1147],
    criticalFacilities: { hospitals: 3, coolingCenters: 2, elderlyCareCenters: 4 },
  },
  {
    wardId: "W002",
    wardName: "George Town",
    zone: "Zone 5 (North)",
    population: 52100,
    areaSqKm: 1.6,
    populationDensity: 32562,
    baselineVulnerabilityIndex: 0.92,
    coordinates: [80.2858, 13.0905],
    criticalFacilities: { hospitals: 4, coolingCenters: 1, elderlyCareCenters: 5 },
  },
  {
    wardId: "W003",
    wardName: "T. Nagar",
    zone: "Zone 10 (Central)",
    population: 61200,
    areaSqKm: 2.4,
    populationDensity: 25500,
    baselineVulnerabilityIndex: 0.74,
    coordinates: [80.2337, 13.0418],
    criticalFacilities: { hospitals: 8, coolingCenters: 4, elderlyCareCenters: 3 },
  },
  {
    wardId: "W004",
    wardName: "Mylapore",
    zone: "Zone 9 (Central)",
    population: 43800,
    areaSqKm: 2.1,
    populationDensity: 20857,
    baselineVulnerabilityIndex: 0.68,
    coordinates: [80.2676, 13.0368],
    criticalFacilities: { hospitals: 6, coolingCenters: 3, elderlyCareCenters: 4 },
  },
  {
    wardId: "W005",
    wardName: "Anna Nagar",
    zone: "Zone 8 (West)",
    population: 58900,
    areaSqKm: 3.2,
    populationDensity: 18406,
    baselineVulnerabilityIndex: 0.52,
    coordinates: [80.2184, 13.0850],
    criticalFacilities: { hospitals: 7, coolingCenters: 5, elderlyCareCenters: 2 },
  },
  {
    wardId: "W006",
    wardName: "Kodambakkam",
    zone: "Zone 10 (Central)",
    population: 54300,
    areaSqKm: 2.3,
    populationDensity: 23608,
    baselineVulnerabilityIndex: 0.71,
    coordinates: [80.2230, 13.0524],
    criticalFacilities: { hospitals: 5, coolingCenters: 3, elderlyCareCenters: 3 },
  },
  {
    wardId: "W007",
    wardName: "Adyar",
    zone: "Zone 13 (South)",
    population: 39700,
    areaSqKm: 2.8,
    populationDensity: 14178,
    baselineVulnerabilityIndex: 0.49,
    coordinates: [80.2565, 13.0012],
    criticalFacilities: { hospitals: 6, coolingCenters: 4, elderlyCareCenters: 2 },
  },
  {
    wardId: "W008",
    wardName: "Velachery",
    zone: "Zone 13 (South)",
    population: 67400,
    areaSqKm: 3.6,
    populationDensity: 18722,
    baselineVulnerabilityIndex: 0.65,
    coordinates: [80.2173, 12.9815],
    criticalFacilities: { hospitals: 4, coolingCenters: 3, elderlyCareCenters: 3 },
  },
  {
    wardId: "W009",
    wardName: "Ambattur",
    zone: "Zone 7 (West)",
    population: 78200,
    areaSqKm: 4.5,
    populationDensity: 17377,
    baselineVulnerabilityIndex: 0.81,
    coordinates: [80.1548, 13.1143],
    criticalFacilities: { hospitals: 5, coolingCenters: 2, elderlyCareCenters: 4 },
  },
  {
    wardId: "W010",
    wardName: "Thiruvanmiyur",
    zone: "Zone 13 (South)",
    population: 36100,
    areaSqKm: 2.2,
    populationDensity: 16409,
    baselineVulnerabilityIndex: 0.55,
    coordinates: [80.2592, 12.9830],
    criticalFacilities: { hospitals: 3, coolingCenters: 3, elderlyCareCenters: 2 },
  },
  {
    wardId: "W011",
    wardName: "Guindy",
    zone: "Zone 9 (Central)",
    population: 47900,
    areaSqKm: 2.9,
    populationDensity: 16517,
    baselineVulnerabilityIndex: 0.77,
    coordinates: [80.2120, 13.0067],
    criticalFacilities: { hospitals: 5, coolingCenters: 2, elderlyCareCenters: 3 },
  },
  {
    wardId: "W012",
    wardName: "Perambur",
    zone: "Zone 6 (North)",
    population: 59300,
    areaSqKm: 2.5,
    populationDensity: 23720,
    baselineVulnerabilityIndex: 0.84,
    coordinates: [80.2330, 13.1090],
    criticalFacilities: { hospitals: 4, coolingCenters: 2, elderlyCareCenters: 4 },
  },
];

export const getWardById = (wardId: string): WardDefinition | undefined => {
  return WARDS_DATA.find((w) => w.wardId.toUpperCase() === wardId.toUpperCase());
};
