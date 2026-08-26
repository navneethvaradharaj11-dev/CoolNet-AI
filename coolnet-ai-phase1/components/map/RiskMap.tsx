"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import dynamic from "next/dynamic";
import type { WardSummary, AddressDetails, WeatherData } from "@/lib/types";
import { RISK_COLORS } from "@/lib/utils/risk";
import { DemoTag } from "@/components/ui/DemoTag";
import { reverseGeocode, searchLocation } from "@/lib/services/geocoding-service";
import { fetchLiveWeatherForCoords } from "@/lib/services/weather-service";
import { getGridCellForCoordinate } from "@/lib/services/grid-service";

const LeafletRiskMap = dynamic(
  () => import("@/components/map/LeafletRiskMap").then((m) => m.LeafletRiskMap),
  {
    ssr: false,
    loading: () => (
      <div className="flex h-full w-full items-center justify-center bg-base-900 text-sm text-ink-600">
        Loading GIS layer…
      </div>
    ),
  }
);

export function RiskMap({
  summaries,
  selectedWardId,
  onSelectWard,
  focusCenter,
  className,
}: {
  summaries: WardSummary[];
  selectedWardId: string | null;
  onSelectWard: (wardId: string) => void;
  focusCenter?: [number, number] | null;
  className?: string;
}) {
  // GPS/Coordinates telemetry states
  const [selectedCoords, setSelectedCoords] = useState<[number, number] | null>(null);
  const [selectedAddress, setSelectedAddress] = useState<AddressDetails | null>(null);
  const [selectedWeather, setSelectedWeather] = useState<WeatherData | null>(null);
  const [selectedGridId, setSelectedGridId] = useState<string | null>(null);

  // Search states
  const [searchQuery, setSearchQuery] = useState("");
  const [searchSuggestions, setSearchSuggestions] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [gpsError, setGpsError] = useState<string | null>(null);
  const [isLoadingLocation, setIsLoadingLocation] = useState(false);
  const searchDebounceTimer = useRef<NodeJS.Timeout | null>(null);

  // Location update callback passed to map clicks/cells
  const handleLocationUpdate = useCallback(
    async (
      coords: [number, number] | null,
      address: AddressDetails | null,
      weather: WeatherData | null,
      gridId: string | null
    ) => {
      setSelectedCoords(coords);
      setSelectedAddress(address);
      setSelectedWeather(weather);
      setSelectedGridId(gridId);
    },
    []
  );

  // Resolve weather and address details for a specific lat/lng coordinate
  const resolveLocation = async (lat: number, lng: number) => {
    setIsLoadingLocation(true);
    setGpsError(null);
    try {
      const gridId = getGridCellForCoordinate(lat, lng, 0.01).id;
      
      const [address, weather] = await Promise.all([
        reverseGeocode(lat, lng),
        fetchLiveWeatherForCoords(lat, lng),
      ]);

      handleLocationUpdate([lat, lng], address, weather, gridId);
    } catch (err) {
      console.error("GIS resolve error", err);
      setGpsError("Failed to fetch telemetry details for clicked coordinates.");
    } finally {
      setIsLoadingLocation(false);
    }
  };

  // Autodetect GPS Geolocation
  const handleLocateUser = () => {
    if (!navigator.geolocation) {
      setGpsError("Browser Geolocation is not supported on this device.");
      return;
    }

    setIsLoadingLocation(true);
    setGpsError(null);

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords;
        await resolveLocation(latitude, longitude);
      },
      (error) => {
        setIsLoadingLocation(false);
        switch (error.code) {
          case error.PERMISSION_DENIED:
            setGpsError("GPS permission denied. Please search or click manually.");
            break;
          case error.POSITION_UNAVAILABLE:
            setGpsError("Location information is unavailable.");
            break;
          case error.TIMEOUT:
            setGpsError("Location request timed out.");
            break;
          default:
            setGpsError("An unknown geolocation error occurred.");
            break;
        }
      },
      { timeout: 10000, enableHighAccuracy: true }
    );
  };

  // Run location detection once on map mount
  useEffect(() => {
    handleLocateUser();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Debounced search suggestion input
  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearchQuery(value);

    if (searchDebounceTimer.current) clearTimeout(searchDebounceTimer.current);

    if (value.trim().length >= 3) {
      setIsSearching(true);
      searchDebounceTimer.current = setTimeout(async () => {
        const results = await searchLocation(value);
        setSearchSuggestions(results);
        setIsSearching(false);
      }, 400);
    } else {
      setSearchSuggestions([]);
      setIsSearching(false);
    }
  };

  const handleSelectSuggestion = async (sug: any) => {
    setSearchQuery(sug.address.displayName || "");
    setSearchSuggestions([]);
    await resolveLocation(sug.lat, sug.lng);
  };

  return (
    <div className={className ?? "relative h-full w-full"}>
      {/* Nominatim Address Search Overlay */}
      <div className="absolute left-4 top-4 z-[2000] w-80 max-w-[calc(100vw-32px)]">
        <div className="flex gap-1.5">
          <div className="relative flex-1">
            <input
              type="text"
              placeholder="Search street, ward, or PIN..."
              value={searchQuery}
              onChange={handleSearchChange}
              className="w-full rounded-md border border-border bg-base-950/95 px-3.5 py-2 text-xs text-ink-100 placeholder-ink-600 focus:border-accent/40 focus:outline-none focus:ring-1 focus:ring-accent/40"
            />
            {isSearching && (
              <span className="absolute right-3 top-2.5 flex h-3.5 w-3.5 animate-spin rounded-full border-2 border-accent/20 border-t-accent" />
            )}
          </div>
          <button
            onClick={handleLocateUser}
            disabled={isLoadingLocation}
            className="flex h-[34px] w-[34px] items-center justify-center rounded-md border border-border bg-base-950/95 text-ink-300 hover:bg-base-900 hover:text-accent disabled:opacity-50 transition-colors"
            title="Locate via GPS"
          >
            {isLoadingLocation ? (
              <span className="h-3.5 w-3.5 animate-spin rounded-full border-2 border-ink-500/20 border-t-ink-400" />
            ) : (
              <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" />
                <path d="M12 2v4M12 18v4M4 12H2M22 12h-4" />
              </svg>
            )}
          </button>
        </div>

        {/* Suggestion Dropdown */}
        {searchSuggestions.length > 0 && (
          <div className="mt-1 max-h-60 overflow-y-auto rounded-md border border-border bg-base-950/95 shadow-2xl backdrop-blur-sm">
            {searchSuggestions.map((sug, i) => (
              <button
                key={i}
                onClick={() => handleSelectSuggestion(sug)}
                className="w-full text-left px-3 py-2 text-[11px] text-ink-200 hover:bg-base-900 border-b border-border/20 last:border-0 truncate block transition-colors"
              >
                {sug.address.displayName}
              </button>
            ))}
          </div>
        )}

        {/* Geolocation Geolocation Error alerts */}
        {gpsError && (
          <div className="mt-2 flex items-center justify-between rounded-md border border-red-500/20 bg-red-950/40 px-3 py-2 text-[10px] text-red-400">
            <span>{gpsError}</span>
            <button onClick={() => setGpsError(null)} className="font-bold hover:text-red-300 ml-2">×</button>
          </div>
        )}
      </div>

      {/* GPS Coordinate Telemetry Panel Overlay */}
      {selectedCoords && (
        <div className="absolute bottom-4 right-4 z-[2000] w-80 max-w-[calc(100vw-32px)] rounded-lg border border-border bg-base-950/95 p-4 text-xs text-ink-300 shadow-2xl backdrop-blur-sm">
          <div className="flex items-center justify-between border-b border-border pb-2 mb-2">
            <span className="font-bold tracking-wide uppercase text-accent">GPS Telemetry</span>
            <button 
              onClick={() => handleLocationUpdate(null, null, null, null)} 
              className="text-ink-600 hover:text-ink-300 font-bold text-sm"
            >
              ×
            </button>
          </div>
          <div className="space-y-1.5">
            <div className="flex justify-between">
              <span className="text-ink-600">Coordinates</span>
              <span className="font-mono text-ink-100">{selectedCoords[0].toFixed(5)}, {selectedCoords[1].toFixed(5)}</span>
            </div>
            {selectedGridId && (
              <div className="flex justify-between">
                <span className="text-ink-600">Grid Cell ID</span>
                <span className="font-mono font-bold text-accent">{selectedGridId}</span>
              </div>
            )}
            <div className="flex justify-between">
              <span className="text-ink-600">Location</span>
              <span className="text-right truncate max-w-[180px] text-ink-100" title={selectedAddress?.displayName}>
                {selectedAddress?.road || selectedAddress?.suburb || selectedAddress?.city || "Unknown Location"}
              </span>
            </div>
            <div className="flex justify-between border-t border-border/30 pt-1.5">
              <span className="text-ink-600">District/State</span>
              <span className="text-ink-200">{selectedAddress?.city_district || selectedAddress?.city || "Nagpur"}, {selectedAddress?.state || "MH"}</span>
            </div>
            {selectedWeather ? (
              <>
                <div className="flex justify-between border-t border-border/30 pt-1.5">
                  <span className="text-ink-600">Ambient Temp</span>
                  <span className="font-bold text-ink-100">{selectedWeather.temperature}°C</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-ink-600">Feels Like</span>
                  <span className="text-ink-200">{selectedWeather.feelsLike}°C</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-ink-600">Relative Humidity</span>
                  <span className="text-ink-200">{selectedWeather.humidity}%</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-ink-600">Heat Index</span>
                  <span className="font-semibold text-accent">{selectedWeather.heatIndex}°C</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-ink-600">WBGT Heat Index</span>
                  <span className="text-ink-200">{selectedWeather.wbgt ?? "N/A"}°C</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-ink-600">Condition</span>
                  <span className="text-ink-200">{selectedWeather.condition || "Unknown"}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-ink-600">Wind Telemetry</span>
                  <span className="text-ink-200">{selectedWeather.windSpeed} km/h @ {selectedWeather.windDirection}°</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-ink-600">UV Index</span>
                  <span className="text-ink-200">{selectedWeather.uvIndex ?? "N/A"}</span>
                </div>
                <div className="flex justify-between border-t border-border/30 pt-1.5">
                  <span className="text-[10px] text-ink-600">Last Observation</span>
                  <span className="text-[10px] text-ink-500">
                    {selectedWeather.timestamp ? new Date(selectedWeather.timestamp).toLocaleTimeString() : "N/A"}
                  </span>
                </div>
                <div className="text-[9px] text-ink-600 text-right mt-1 italic">
                  Source: {selectedWeather.source || "Open-Meteo"}
                </div>
              </>
            ) : (
              <div className="text-accent text-center pt-2 animate-pulse">Fetching coordinates telemetry…</div>
            )}
          </div>
        </div>
      )}

      {/* Leaflet map implementation */}
      <LeafletRiskMap
        summaries={summaries}
        selectedWardId={selectedWardId}
        onSelectWard={onSelectWard}
        focusCenter={selectedCoords ? selectedCoords : focusCenter}
        selectedCoords={selectedCoords}
        selectedGridId={selectedGridId}
        onLocationUpdate={resolveLocation}
      />

      <div className="pointer-events-none absolute left-3 top-16 z-[1000] flex flex-col gap-2">
        <div className="pointer-events-auto rounded-md border border-border bg-base-900/90 px-3 py-2 backdrop-blur-sm">
          <p className="mb-1.5 text-[10px] font-semibold uppercase tracking-wide text-ink-500">
            Compound Risk
          </p>
          <div className="flex flex-col gap-1">
            {(["CRITICAL", "HIGH", "MODERATE", "LOW"] as const).map((level) => (
              <div key={level} className="flex items-center gap-1.5">
                <span
                  className="h-2.5 w-2.5 rounded-sm"
                  style={{ backgroundColor: RISK_COLORS[level] }}
                />
                <span className="text-[11px] text-ink-300">{level}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="pointer-events-none absolute right-3 top-3 z-[1000]">
        <div className="pointer-events-auto">
          <DemoTag label="DEMO WARD GIS" />
        </div>
      </div>
    </div>
  );
}
