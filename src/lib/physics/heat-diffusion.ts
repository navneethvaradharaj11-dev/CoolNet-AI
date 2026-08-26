/**
 * Spatial Heat Diffusion Approximation
 * -------------------------------------------------------------------------
 * This is a discrete spatial approximation of heat spillover (representing
 * urban heat island bleed between adjacent dense wards).
 * 
 * NOTE: This is NOT a literal fluid dynamics (Navier-Stokes) or 3D airflow
 * Computational Fluid Dynamics (CFD) simulation. It is a mathematical
 * smoothing heuristic weighted by inverse distance and neighbor population density.
 */

/**
 * Simple distance calculation in kilometers between two lat/lng coordinates (Haversine approximation)
 */
export function calculateDistanceKm(c1: [number, number], c2: [number, number]): number {
  const [lat1, lon1] = c1;
  const [lat2, lon2] = c2;
  
  const R = 6371; // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
      
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

export interface WardDiffusionInput {
  id: string;
  centroid: [number, number];
  heatIndex: number;
  populationDensity: number;
}

/**
 * Calculates diffused heat values for a collection of wards.
 * Formula:
 *   effectiveHeat[i] = ownHeat[i] * (1 - k) + k * (sum(neighborHeat[j] * densityFactor[j] / dist_ij) / sum(1 / dist_ij))
 * 
 * k represents the diffusion rate (default: 0.20, range 0.15 - 0.25).
 */
export function applyHeatDiffusion(
  wards: WardDiffusionInput[],
  k = 0.20
): Record<string, number> {
  if (wards.length <= 1) {
    const fallback: Record<string, number> = {};
    wards.forEach(w => {
      fallback[w.id] = w.heatIndex;
    });
    return fallback;
  }

  // Calculate average population density as a baseline scaling factor
  const totalDensity = wards.reduce((sum, w) => sum + w.populationDensity, 0);
  const avgDensity = totalDensity / wards.length || 1;

  const result: Record<string, number> = {};

  for (let i = 0; i < wards.length; i++) {
    const current = wards[i];
    let totalWeight = 0;
    let weightedNeighborSum = 0;

    for (let j = 0; j < wards.length; j++) {
      if (i === j) continue;
      
      const neighbor = wards[j];
      
      // Calculate distance in km (floor at 0.05km to avoid divide by zero/infinite weight at exact overlap)
      const dist = Math.max(0.05, calculateDistanceKm(current.centroid, neighbor.centroid));
      
      // Inverse distance weight
      const weight = 1 / dist;
      
      // Scale heat contribution by relative population density (representing structural heat retention of built environments)
      const densityFactor = neighbor.populationDensity / avgDensity;
      
      weightedNeighborSum += (neighbor.heatIndex * densityFactor) * weight;
      totalWeight += weight;
    }

    const weightedAvgOfNeighbors = totalWeight > 0 ? weightedNeighborSum / totalWeight : current.heatIndex;
    
    // Effective heat is a blend of own heat and adjacent bleed
    const effective = current.heatIndex * (1 - k) + k * weightedAvgOfNeighbors;
    
    // Round to 1 decimal place
    result[current.id] = parseFloat(effective.toFixed(1));
  }

  return result;
}
