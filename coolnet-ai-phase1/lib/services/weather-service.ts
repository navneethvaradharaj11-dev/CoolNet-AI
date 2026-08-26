import { DEMO_WARD_META } from "@/lib/data/mockWards";
import { WeatherData } from "@/lib/types";

export interface LiveWeatherData {
  temperature: number;
  humidity: number;
  heatIndex: number;
  wbgt: number;
  timestamp: string;
  
  // Detailed metrics
  feelsLike: number;
  condition: string;
  windSpeed: number;
  windDirection: number;
  pressure: number;
  visibility: number;
  uvIndex: number;
  precipitation: number;
}

const CACHE_KEY = "coolnet_live_weather_cache";
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes cache TTL

/**
 * Maps WMO weather code to human-readable string
 */
export function getWeatherCodeDescription(code: number): string {
  const mapping: Record<number, string> = {
    0: "Clear Sky",
    1: "Mainly Clear",
    2: "Partly Cloudy",
    3: "Overcast",
    45: "Foggy",
    48: "Depositing Rime Fog",
    51: "Light Drizzle",
    53: "Moderate Drizzle",
    55: "Dense Drizzle",
    56: "Light Freezing Drizzle",
    57: "Dense Freezing Drizzle",
    61: "Slight Rain",
    63: "Moderate Rain",
    65: "Heavy Rain",
    66: "Light Freezing Rain",
    67: "Heavy Freezing Rain",
    71: "Slight Snow Fall",
    73: "Moderate Snow Fall",
    75: "Heavy Snow Fall",
    77: "Snow Grains",
    80: "Slight Rain Showers",
    81: "Moderate Rain Showers",
    82: "Violent Rain Showers",
    85: "Slight Snow Showers",
    86: "Heavy Snow Showers",
    95: "Thunderstorm",
    96: "Thunderstorm with Slight Hail",
    99: "Thunderstorm with Heavy Hail"
  };
  return mapping[code] || "Unknown Condition";
}

/**
 * Recalculate Heat Index in Celsius using standard NOAA formula
 */
export function calculateHeatIndex(tempC: number, humidity: number): number {
  const T = (tempC * 9 / 5) + 32;
  const R = humidity;

  if (T < 80) {
    const simpleHI = 0.5 * (T + 61.0 + ((T - 68.0) * 1.2) + (R * 0.094));
    return parseFloat(((simpleHI - 32) * 5 / 9).toFixed(1));
  }

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

  if (R < 13 && T >= 80 && T <= 112) {
    const adj = ((13 - R) / 4) * Math.sqrt((17 - Math.abs(T - 95)) / 17);
    hi -= adj;
  } else if (R > 85 && T >= 80 && T <= 87) {
    const adj = ((R - 85) / 10) * ((87 - T) / 5);
    hi += adj;
  }

  return parseFloat(((hi - 32) * 5 / 9).toFixed(1));
}

/**
 * Recalculate WBGT in Celsius based on temperature and relative humidity
 */
export function calculateWBGT(tempC: number, humidity: number): number {
  const e = (humidity / 100) * 6.105 * Math.exp((17.27 * tempC) / (237.7 + tempC));
  const wbgt = (0.567 * tempC) + (0.393 * e) + 3.94;
  return parseFloat(wbgt.toFixed(1));
}

/**
 * Fetches current weather for all wards in a single batch request
 */
export async function fetchBatchLiveWeather(): Promise<Record<string, LiveWeatherData> | null> {
  if (typeof window !== "undefined") {
    try {
      const cached = localStorage.getItem(CACHE_KEY);
      if (cached) {
        const parsed = JSON.parse(cached);
        if (Date.now() - parsed.timestamp < CACHE_TTL) {
          console.log("🌦 CoolNet Weather: Loading live weather batch from local storage cache");
          return parsed.data;
        }
      }
    } catch (e) {
      console.warn("🌦 CoolNet Weather: Cache read failed", e);
    }
  }

  try {
    const latitudes = DEMO_WARD_META.map(w => w.centroid[0]).join(",");
    const longitudes = DEMO_WARD_META.map(w => w.centroid[1]).join(",");
    
    // Request full variables
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${latitudes}&longitude=${longitudes}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,visibility,uv_index,precipitation`;

    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Open-Meteo API returned status ${response.status}`);
    }

    const data = await response.json();
    const results: Record<string, LiveWeatherData> = {};

    const dataArray = Array.isArray(data) ? data : [data];

    dataArray.forEach((loc, index) => {
      if (index < DEMO_WARD_META.length) {
        const wardId = DEMO_WARD_META[index].ward_id;
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
            
            feelsLike: loc.current.apparent_temperature ?? temp,
            condition: getWeatherCodeDescription(loc.current.weather_code ?? 0),
            windSpeed: loc.current.wind_speed_10m ?? 0,
            windDirection: loc.current.wind_direction_10m ?? 0,
            pressure: loc.current.surface_pressure ?? 1013,
            visibility: loc.current.visibility ?? 10000,
            uvIndex: loc.current.uv_index ?? 0,
            precipitation: loc.current.precipitation ?? 0,
          };
        }
      }
    });

    if (typeof window !== "undefined" && Object.keys(results).length > 0) {
      try {
        localStorage.setItem(CACHE_KEY, JSON.stringify({
          timestamp: Date.now(),
          data: results
        }));
      } catch (e) {
        console.warn("🌦 CoolNet Weather: Cache write failed", e);
      }
    }

    return results;
  } catch (error) {
    console.error("🌦 CoolNet Weather: Error fetching live coordinates", error);
    return null;
  }
}

/**
 * Fetch detailed weather for a specific single coordinate (used when clicking map or searching custom locations)
 */
export async function fetchLiveWeatherForCoords(lat: number, lng: number): Promise<WeatherData | null> {
  const cacheKey = `coolnet_coords_weather_${lat.toFixed(4)}_${lng.toFixed(4)}`;
  
  if (typeof window !== "undefined") {
    try {
      const cached = localStorage.getItem(cacheKey);
      if (cached) {
        const parsed = JSON.parse(cached);
        if (Date.now() - parsed.timestamp < CACHE_TTL) {
          return parsed.data;
        }
      }
    } catch (e) {
      console.warn("🌦 CoolNet Weather: Coords cache read failed", e);
    }
  }

  try {
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lng}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,visibility,uv_index,precipitation`;
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    
    const data = await response.json();
    if (!data.current) return null;
    
    const temp = data.current.temperature_2m;
    const humidity = data.current.relative_humidity_2m;
    const time = data.current.time || new Date().toISOString();
    
    const result: WeatherData = {
      temperature: temp,
      humidity,
      heatIndex: calculateHeatIndex(temp, humidity),
      wbgt: calculateWBGT(temp, humidity),
      timestamp: new Date(time).toISOString(),
      isReal: true,
      
      feelsLike: data.current.apparent_temperature ?? temp,
      condition: getWeatherCodeDescription(data.current.weather_code ?? 0),
      windSpeed: data.current.wind_speed_10m ?? 0,
      windDirection: data.current.wind_direction_10m ?? 0,
      pressure: data.current.surface_pressure ?? 1013,
      visibility: data.current.visibility ?? 10000,
      uvIndex: data.current.uv_index ?? 0,
      precipitation: data.current.precipitation ?? 0,
      source: "Open-Meteo API"
    };

    if (typeof window !== "undefined") {
      try {
        localStorage.setItem(cacheKey, JSON.stringify({
          timestamp: Date.now(),
          data: result
        }));
      } catch (e) {
        console.warn("🌦 CoolNet Weather: Coords cache write failed", e);
      }
    }

    return result;
  } catch (error) {
    console.error("🌦 CoolNet Weather: Coords weather fetch failed", error);
    return null;
  }
}
