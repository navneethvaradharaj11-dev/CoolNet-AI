import { WARDS } from '@/lib/geojson/wards';

export interface LiveWeatherData {
  temperature: number;
  humidity: number;
  heatIndex: number;
  wbgt: number;
  timestamp: string;
}

const CACHE_KEY = 'coolnet_live_weather_cache';
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes cache TTL

/**
 * Recalculate Heat Index in Celsius using standard NOAA formula
 */
export function calculateHeatIndex(tempC: number, humidity: number): number {
  // Convert Celsius to Fahrenheit
  const T = (tempC * 9 / 5) + 32;
  const R = humidity;

  // Simple formula for low temperatures (below 80F / ~26.7C)
  if (T < 80) {
    const simpleHI = 0.5 * (T + 61.0 + ((T - 68.0) * 1.2) + (R * 0.094));
    return parseFloat(((simpleHI - 32) * 5 / 9).toFixed(1));
  }

  // Full NOAA regression
  const c1 = -42.379;
  const c2 = 2.04901523;
  const c3 = 10.14333127;
  const c4 = -0.22475541;
  const c5 = -0.00683783;
  const c6 = -0.05481717;
  const c7 = 0.00122874;
  const c8 = 0.00085282;
  const c9 = -0.00000199;

  let hi = c1 + (c2 * T) + (c3 * R) + (c4 * T * R) + (c5 * T * T) + (c6 * R * R) +
           (c7 * T * T * R) + (c8 * T * R * R) + (c9 * T * T * R * R);

  // Adjustments
  if (R < 13 && T >= 80 && T <= 112) {
    const adj = ((13 - R) / 4) * Math.sqrt((17 - Math.abs(T - 95)) / 17);
    hi -= adj;
  } else if (R > 85 && T >= 80 && T <= 87) {
    const adj = ((R - 85) / 10) * ((87 - T) / 5);
    hi += adj;
  }

  // Convert back to Celsius
  return parseFloat(((hi - 32) * 5 / 9).toFixed(1));
}

/**
 * Recalculate WBGT in Celsius based on temperature and relative humidity
 */
export function calculateWBGT(tempC: number, humidity: number): number {
  // e = water vapor pressure (hPa)
  const e = (humidity / 100) * 6.105 * Math.exp((17.27 * tempC) / (237.7 + tempC));
  // WBGT approximation
  const wbgt = (0.567 * tempC) + (0.393 * e) + 3.94;
  return parseFloat(wbgt.toFixed(1));
}

/**
 * Fetches current weather for all 20 wards in a single batch request
 */
export async function fetchBatchLiveWeather(): Promise<Record<string, LiveWeatherData> | null> {
  // Check local cache if in browser context
  if (typeof window !== 'undefined') {
    try {
      const cached = localStorage.getItem(CACHE_KEY);
      if (cached) {
        const parsed = JSON.parse(cached);
        if (Date.now() - parsed.timestamp < CACHE_TTL) {
          console.log('⚡ CoolNet Weather: Loading live weather from local storage cache');
          return parsed.data;
        }
      }
    } catch (e) {
      console.warn('⚡ CoolNet Weather: Cache read failed', e);
    }
  }

  try {
    const latitudes = WARDS.map(w => w.center[0]).join(',');
    const longitudes = WARDS.map(w => w.center[1]).join(',');
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${latitudes}&longitude=${longitudes}&current=temperature_2m,relative_humidity_2m`;

    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Open-Meteo API returned status ${response.status}`);
    }

    const data = await response.json();
    const results: Record<string, LiveWeatherData> = {};

    const dataArray = Array.isArray(data) ? data : [data];

    dataArray.forEach((loc, index) => {
      if (index < WARDS.length) {
        const wardId = WARDS[index].id;
        if (loc.current) {
          const temp = loc.current.temperature_2m;
          const humidity = loc.current.relative_humidity_2m;
          const time = loc.current.time || new Date().toISOString();
          
          results[wardId] = {
            temperature: temp,
            humidity,
            heatIndex: calculateHeatIndex(temp, humidity),
            wbgt: calculateWBGT(temp, humidity),
            timestamp: new Date(time).toISOString(),
          };
        }
      }
    });

    // Write to cache if in browser context
    if (typeof window !== 'undefined' && Object.keys(results).length > 0) {
      try {
        localStorage.setItem(CACHE_KEY, JSON.stringify({
          timestamp: Date.now(),
          data: results
        }));
      } catch (e) {
        console.warn('⚡ CoolNet Weather: Cache write failed', e);
      }
    }

    console.log('⚡ CoolNet Weather: Live weather data loaded successfully');
    return results;
  } catch (error) {
    console.error('⚡ CoolNet Weather: Error fetching live coordinates', error);
    return null;
  }
}
