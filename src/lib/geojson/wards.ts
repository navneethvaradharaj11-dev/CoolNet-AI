<<<<<<< HEAD
import { Ward } from '@/lib/types';

const W: Ward[] = [
  { id: 'ward-01', name: 'Ward 1', population: 45200, areaSqKm: 4.2, center: [28.6315, 77.2220], geometry: { type: 'Polygon', coordinates: [[[28.634,77.214],[28.636,77.224],[28.633,77.230],[28.629,77.226],[28.628,77.218],[28.634,77.214]]] } },
  { id: 'ward-02', name: 'Ward 2', population: 38700, areaSqKm: 3.8, center: [28.6395, 77.2310], geometry: { type: 'Polygon', coordinates: [[[28.636,77.224],[28.642,77.226],[28.644,77.234],[28.640,77.238],[28.635,77.234],[28.636,77.224]]] } },
  { id: 'ward-03', name: 'Ward 3', population: 52100, areaSqKm: 5.1, center: [28.6275, 77.2400], geometry: { type: 'Polygon', coordinates: [[[28.631,77.234],[28.635,77.234],[28.633,77.246],[28.628,77.246],[28.625,77.240],[28.631,77.234]]] } },
  { id: 'ward-04', name: 'Ward 4', population: 29300, areaSqKm: 2.9, center: [28.6455, 77.2440], geometry: { type: 'Polygon', coordinates: [[[28.643,77.240],[28.649,77.240],[28.650,77.248],[28.646,77.252],[28.642,77.248],[28.643,77.240]]] } },
  { id: 'ward-05', name: 'Ward 5', population: 61400, areaSqKm: 6.2, center: [28.6215, 77.2170], geometry: { type: 'Polygon', coordinates: [[[28.625,77.210],[28.628,77.210],[28.628,77.218],[28.625,77.224],[28.619,77.222],[28.618,77.214],[28.625,77.210]]] } },
  { id: 'ward-06', name: 'Ward 6', population: 33800, areaSqKm: 3.3, center: [28.6335, 77.2520], geometry: { type: 'Polygon', coordinates: [[[28.631,77.248],[28.637,77.248],[28.638,77.256],[28.633,77.260],[28.629,77.256],[28.631,77.248]]] } },
  { id: 'ward-07', name: 'Ward 7', population: 47600, areaSqKm: 4.7, center: [28.6175, 77.2310], geometry: { type: 'Polygon', coordinates: [[[28.621,77.224],[28.625,77.224],[28.625,77.238],[28.621,77.242],[28.616,77.238],[28.615,77.228],[28.621,77.224]]] } },
  { id: 'ward-08', name: 'Ward 8', population: 41200, areaSqKm: 4.0, center: [28.6415, 77.2110], geometry: { type: 'Polygon', coordinates: [[[28.638,77.206],[28.645,77.206],[28.646,77.216],[28.642,77.220],[28.637,77.216],[28.638,77.206]]] } },
  { id: 'ward-09', name: 'Ward 9', population: 55800, areaSqKm: 5.5, center: [28.6135, 77.2480], geometry: { type: 'Polygon', coordinates: [[[28.617,77.242],[28.621,77.242],[28.620,77.254],[28.616,77.258],[28.611,77.254],[28.610,77.246],[28.617,77.242]]] } },
  { id: 'ward-10', name: 'Ward 10', population: 36900, areaSqKm: 3.6, center: [28.6475, 77.2260], geometry: { type: 'Polygon', coordinates: [[[28.645,77.220],[28.651,77.220],[28.652,77.232],[28.648,77.236],[28.644,77.232],[28.645,77.220]]] } },
  { id: 'ward-11', name: 'Ward 11', population: 43100, areaSqKm: 4.3, center: [28.6255, 77.2060], geometry: { type: 'Polygon', coordinates: [[[28.629,77.200],[28.634,77.200],[28.634,77.210],[28.628,77.214],[28.623,77.210],[28.622,77.204],[28.629,77.200]]] } },
  { id: 'ward-12', name: 'Ward 12', population: 48900, areaSqKm: 4.8, center: [28.6375, 77.2600], geometry: { type: 'Polygon', coordinates: [[[28.635,77.256],[28.641,77.256],[28.642,77.264],[28.638,77.268],[28.633,77.264],[28.635,77.256]]] } },
  { id: 'ward-13', name: 'Ward 13', population: 34600, areaSqKm: 3.4, center: [28.6095, 77.2220], geometry: { type: 'Polygon', coordinates: [[[28.613,77.216],[28.617,77.216],[28.616,77.228],[28.612,77.230],[28.607,77.226],[28.607,77.220],[28.613,77.216]]] } },
  { id: 'ward-14', name: 'Ward 14', population: 52300, areaSqKm: 5.2, center: [28.6495, 77.2520], geometry: { type: 'Polygon', coordinates: [[[28.647,77.246],[28.653,77.246],[28.654,77.258],[28.650,77.262],[28.646,77.258],[28.647,77.246]]] } },
  { id: 'ward-15', name: 'Ward 15', population: 39400, areaSqKm: 3.9, center: [28.6215, 77.2620], geometry: { type: 'Polygon', coordinates: [[[28.625,77.256],[28.629,77.256],[28.628,77.268],[28.624,77.272],[28.619,77.268],[28.618,77.260],[28.625,77.256]]] } },
  { id: 'ward-16', name: 'Ward 16', population: 44700, areaSqKm: 4.4, center: [28.6355, 77.1990], geometry: { type: 'Polygon', coordinates: [[[28.632,77.194],[28.639,77.194],[28.640,77.204],[28.636,77.208],[28.631,77.204],[28.632,77.194]]] } },
  { id: 'ward-17', name: 'Ward 17', population: 67800, areaSqKm: 6.8, center: [28.6175, 77.2080], geometry: { type: 'Polygon', coordinates: [[[28.621,77.200],[28.625,77.200],[28.623,77.214],[28.619,77.216],[28.614,77.214],[28.613,77.204],[28.621,77.200]]] } },
  { id: 'ward-18', name: 'Ward 18', population: 31500, areaSqKm: 3.1, center: [28.6435, 77.2680], geometry: { type: 'Polygon', coordinates: [[[28.641,77.264],[28.647,77.264],[28.648,77.274],[28.644,77.278],[28.639,77.274],[28.641,77.264]]] } },
  { id: 'ward-19', name: 'Ward 19', population: 58200, areaSqKm: 5.7, center: [28.6075, 77.2380], geometry: { type: 'Polygon', coordinates: [[[28.611,77.230],[28.616,77.230],[28.615,77.246],[28.611,77.250],[28.605,77.246],[28.604,77.236],[28.611,77.230]]] } },
  { id: 'ward-20', name: 'Ward 20', population: 40100, areaSqKm: 4.0, center: [28.6515, 77.2380], geometry: { type: 'Polygon', coordinates: [[[28.649,77.232],[28.655,77.232],[28.656,77.244],[28.652,77.248],[28.648,77.244],[28.649,77.232]]] } },
];

export const WARDS: Ward[] = W;
export const WARDS_GEOJSON: GeoJSON.FeatureCollection = {
  type: 'FeatureCollection',
  features: W.map(w => ({ type: 'Feature', properties: { wardId: w.id, name: w.name }, geometry: w.geometry })),
};

export function getWardById(id: string): (Ward & { baselineVulnerabilityIndex?: number; populationDensity?: number }) | undefined {
  const found = W.find(w => w.id === id);
  if (!found) return undefined;
  return {
    ...found,
    populationDensity: Math.round(found.population / found.areaSqKm),
    baselineVulnerabilityIndex: 0.65
  };
}

=======
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
>>>>>>> origin/main
