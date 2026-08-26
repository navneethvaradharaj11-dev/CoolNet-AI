import { GeospatialGridCell } from "@/lib/types";

/**
 * Calculates a unique, mathematically stable Grid ID based on coordinates
 */
export function getGridId(lat: number, lng: number, spacing = 0.01): string {
  const south = Math.floor(lat / spacing) * spacing;
  const west = Math.floor(lng / spacing) * spacing;
  
  const centerLat = south + spacing / 2;
  const centerLng = west + spacing / 2;
  
  const latInt = Math.floor(Math.abs(centerLat));
  const lngInt = Math.floor(Math.abs(centerLng));
  
  // Calculate fractional suffix (e.g. lat fractional part up to 3 digits)
  const latFrac = Math.floor(Math.round((Math.abs(centerLat) - latInt) * 1000));
  
  return `GRID-${latInt.toString().padStart(2, "0")}-${lngInt.toString().padStart(2, "0")}-${latFrac.toString().padStart(3, "0")}`;
}

/**
 * Calculates a single geospatial grid cell for a given coordinate
 */
export function getGridCellForCoordinate(lat: number, lng: number, spacing = 0.01): GeospatialGridCell {
  const south = Math.floor(lat / spacing) * spacing;
  const west = Math.floor(lng / spacing) * spacing;
  const north = south + spacing;
  const east = west + spacing;
  
  const centerLat = south + spacing / 2;
  const centerLng = west + spacing / 2;
  
  // Area calculation using spherical surface approximation
  // Lat distance = spacing * 111.32 km
  // Lng distance = spacing * 111.32 * cos(lat) km
  const latDist = spacing * 111.32;
  const lngDist = spacing * 111.32 * Math.cos((centerLat * Math.PI) / 180);
  const areaSqKm = parseFloat((latDist * lngDist).toFixed(4));
  
  return {
    id: getGridId(lat, lng, spacing),
    center: [parseFloat(centerLat.toFixed(6)), parseFloat(centerLng.toFixed(6))],
    bounds: [
      [parseFloat(south.toFixed(6)), parseFloat(west.toFixed(6))],
      [parseFloat(north.toFixed(6)), parseFloat(east.toFixed(6))]
    ],
    north: parseFloat(north.toFixed(6)),
    south: parseFloat(south.toFixed(6)),
    east: parseFloat(east.toFixed(6)),
    west: parseFloat(west.toFixed(6)),
    areaSqKm,
    incidentCount: 0
  };
}

/**
 * Generates all mathematical grid cells within the specified viewport bounds
 */
export function getGridCellsInViewport(
  south: number,
  west: number,
  north: number,
  east: number,
  spacing = 0.01
): GeospatialGridCell[] {
  // Performance safeguard: do not draw grid if zoomed out too far (wider than 0.25 degrees)
  if (Math.abs(north - south) > 0.25 || Math.abs(east - west) > 0.25) {
    return [];
  }

  const cells: GeospatialGridCell[] = [];
  
  const startLat = Math.floor(south / spacing) * spacing;
  const endLat = Math.ceil(north / spacing) * spacing;
  const startLng = Math.floor(west / spacing) * spacing;
  const endLng = Math.ceil(east / spacing) * spacing;
  
  // Limit total iterations to prevent browser lag in worst-case zoom pans
  let cellCount = 0;
  const maxCells = 800;

  for (let lat = startLat; lat < endLat; lat += spacing) {
    for (let lng = startLng; lng < endLng; lng += spacing) {
      if (cellCount >= maxCells) break;
      
      cells.push(getGridCellForCoordinate(lat, lng, spacing));
      cellCount++;
    }
    if (cellCount >= maxCells) break;
  }
  
  return cells;
}
