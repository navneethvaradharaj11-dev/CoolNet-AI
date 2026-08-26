/**
 * Thermodynamic Heat Index calculation using the NWS Rothfusz regression.
 * Grounded in physics-based regression from relative humidity and temperature.
 *
 * Formula sources:
 * - NOAA/National Weather Service: https://www.weather.gov/ama/heatindex
 */

/**
 * Calculates Heat Index in Celsius given temperature in Celsius and relative humidity in %.
 * Correctly handles fallback simple heat index and low/high humidity adjustments.
 */
export function calculateHeatIndex(tempC: number, humidityPct: number): number {
  // Convert Celsius to Fahrenheit for the NWS regression
  const T = (tempC * 9 / 5) + 32;
  const RH = humidityPct;

  // Simple Heat Index formula fallback for cool/moderate conditions
  const simpleHI = 0.5 * (T + 61.0 + ((T - 68.0) * 1.2) + (RH * 0.094));
  
  if (simpleHI < 80) {
    return parseFloat(((simpleHI - 32) * 5 / 9).toFixed(1));
  }

  // Full NWS Rothfusz regression coefficients
  const c1 = -42.379;
  const c2 = 2.04901523;
  const c3 = 10.14333127;
  const c4 = -0.22475541;
  const c5 = -0.00683783;
  const c6 = -0.05481717;
  const c7 = 0.00122874;
  const c8 = 0.00085282;
  const c9 = -0.00000199; // Standard NWS value (T^2 * RH^2 coefficient)

  let hi = c1 + (c2 * T) + (c3 * RH) + (c4 * T * RH) + (c5 * T * T) + (c6 * RH * RH) +
           (c7 * T * T * RH) + (c8 * T * RH * RH) + (c9 * T * T * RH * RH);

  // Apply NWS adjustments for boundary cases
  if (RH < 13 && T >= 80 && T <= 112) {
    // Low humidity adjustment
    const adj = ((13 - RH) / 4) * Math.sqrt((17 - Math.abs(T - 95)) / 17);
    hi -= adj;
  } else if (RH > 85 && T >= 80 && T <= 87) {
    // High humidity adjustment
    const adj = ((RH - 85) / 10) * ((87 - T) / 5);
    hi += adj;
  }

  // Convert back to Celsius and round to 1 decimal place
  return parseFloat(((hi - 32) * 5 / 9).toFixed(1));
}
