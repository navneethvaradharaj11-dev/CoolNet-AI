"use client";

import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import { GeoJSON, MapContainer, TileLayer, useMap, useMapEvents, LayersControl, Rectangle, Tooltip, Marker } from "react-leaflet";
import type { Layer, LeafletMouseEvent } from "leaflet";
import L from "leaflet";
import type { WardSummary, GeospatialGridCell } from "@/lib/types";
import { CITY_META, DEMO_WARD_GEOMETRY } from "@/lib/data/mockWards";
import { RISK_COLORS } from "@/lib/utils/risk";
import { getGridCellsInViewport } from "@/lib/services/grid-service";

// Color mappings for risk cells based on temperature
function getTempColor(temp: number): string {
  if (temp >= 40) return "#ef4444"; // critical red
  if (temp >= 35) return "#f97316"; // orange
  if (temp >= 30) return "#eab308"; // yellow/amber
  return "#22c55e"; // green
}

const gpsIconRef = { current: null as any };
function getGpsIcon() {
  if (typeof window === "undefined" || !L.divIcon) return undefined;
  if (!gpsIconRef.current) {
    gpsIconRef.current = L.divIcon({
      className: "custom-gps-marker",
      html: `
        <style>
          .gps-pin-container { position: relative; width: 22px; height: 22px; display: flex; align-items: center; justify-content: center; }
          .gps-pin-dot { width: 10px; height: 10px; border-radius: 50%; background-color: #38bdf8; border: 2px solid #ffffff; box-shadow: 0 0 6px rgba(0,0,0,0.5); z-index: 10; }
          .gps-pin-pulse { position: absolute; width: 22px; height: 22px; border-radius: 50%; border: 2px solid #38bdf8; animation: gpsPulseAnim 2s infinite ease-out; opacity: 0; z-index: 5; }
          @keyframes gpsPulseAnim {
            0% { transform: scale(0.4); opacity: 0.9; }
            100% { transform: scale(2.0); opacity: 0; }
          }
        </style>
        <div class="gps-pin-container">
          <div class="gps-pin-dot"></div>
          <div class="gps-pin-pulse"></div>
        </div>
      `,
      iconSize: [22, 22],
      iconAnchor: [11, 11]
    });
  }
  return gpsIconRef.current;
}

// Sub-component to pan the map programmatically when coords change
function FlyToWard({ center }: { center: [number, number] | null }) {
  const map = useMap();
  useEffect(() => {
    if (center) {
      map.flyTo(center, Math.max(map.getZoom(), 13), { duration: 0.6 });
    }
  }, [center, map]);
  return null;
}

// Sub-component to track map bounds and viewport changes dynamically for the grid
function ViewportTracker({ onBoundsChange }: { onBoundsChange: (bounds: L.LatLngBounds) => void }) {
  const map = useMapEvents({
    moveend: () => onBoundsChange(map.getBounds()),
    zoomend: () => onBoundsChange(map.getBounds())
  });
  
  useEffect(() => {
    // Initial bounds load
    onBoundsChange(map.getBounds());
  }, [map, onBoundsChange]);

  return null;
}

// Sub-component to track click events on the map itself
function MapClickHandler({ onClick }: { onClick: (lat: number, lng: number) => void }) {
  useMapEvents({
    click: (e) => {
      onClick(e.latlng.lat, e.latlng.lng);
    }
  });
  return null;
}

export function LeafletRiskMap({
  summaries,
  selectedWardId,
  onSelectWard,
  focusCenter,
  selectedCoords,
  selectedGridId,
  onLocationUpdate,
}: {
  summaries: WardSummary[];
  selectedWardId: string | null;
  onSelectWard: (wardId: string) => void;
  focusCenter?: [number, number] | null;
  selectedCoords: [number, number] | null;
  selectedGridId: string | null;
  onLocationUpdate: (lat: number, lng: number) => Promise<void>;
}) {
  const [gridCells, setGridCells] = useState<GeospatialGridCell[]>([]);

  const summaryByWard = useMemo(() => {
    const map = new Map<string, WardSummary>();
    summaries.forEach((s) => map.set(s.meta.ward_id, s));
    return map;
  }, [summaries]);

  const featureCollection = useMemo(() => {
    return {
      type: "FeatureCollection" as const,
      features: DEMO_WARD_GEOMETRY.map((g) => ({
        type: "Feature" as const,
        properties: { ward_id: g.ward_id },
        geometry: g.geojson,
      })),
    };
  }, []);

  const geoJsonRef = useRef<any>(null);

  const styleFeature = (feature: any) => {
    const wardId = feature?.properties?.ward_id;
    const summary = summaryByWard.get(wardId);
    const level = summary?.compoundRisk.risk_level ?? "LOW";
    const isSelected = wardId === selectedWardId;
    return {
      color: isSelected ? "#38bdf8" : "#05070a",
      weight: isSelected ? 2.5 : 1,
      fillColor: RISK_COLORS[level],
      fillOpacity: isSelected ? 0.75 : 0.55,
    };
  };

  const onEachFeature = (feature: any, layer: Layer) => {
    const wardId = feature?.properties?.ward_id;
    const summary = summaryByWard.get(wardId);

    if (summary) {
      layer.bindTooltip(
        `<div style="font-family:inherit">
          <div style="font-weight:600;margin-bottom:2px">${summary.meta.name}</div>
          <div style="font-size:11px;opacity:0.8">Risk ${summary.compoundRisk.compound_risk_score}/100 · ${summary.compoundRisk.risk_level}</div>
        </div>`,
        { sticky: true, className: "coolnet-tooltip" }
      );
    }

    layer.on({
      click: (e: LeafletMouseEvent) => {
        L.DomEvent.stopPropagation(e);
        onSelectWard(wardId);
      },
      mouseover: (e: LeafletMouseEvent) => {
        (e.target as any).setStyle({ weight: 2.5, fillOpacity: 0.75 });
      },
      mouseout: (e: LeafletMouseEvent) => {
        if (wardId !== selectedWardId) {
          (e.target as any).setStyle(styleFeature(feature));
        }
      },
    });
  };

  useEffect(() => {
    if (geoJsonRef.current) {
      geoJsonRef.current.setStyle(styleFeature);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedWardId, summaryByWard]);

  // Recalculate mathematical grid cells on bounds change
  const handleBoundsChange = useCallback((bounds: L.LatLngBounds) => {
    const south = bounds.getSouth();
    const west = bounds.getWest();
    const north = bounds.getNorth();
    const east = bounds.getEast();
    
    const cells = getGridCellsInViewport(south, west, north, east, 0.01);
    
    const hydratedCells = cells.map(cell => {
      const matchedSummary = summaries.find((s) => {
        const [lat, lng] = s.meta.centroid;
        return lat >= cell.south && lat <= cell.north && lng >= cell.west && lng <= cell.east;
      });

      return {
        ...cell,
        weather: matchedSummary 
          ? {
              temperature: matchedSummary.snapshot.temperature,
              humidity: matchedSummary.snapshot.humidity,
              heatIndex: matchedSummary.snapshot.heat_index,
              timestamp: matchedSummary.snapshot.timestamp,
            }
          : {
              temperature: 30 + Math.sin(cell.center[0] * 5) * 5,
              humidity: 60,
              heatIndex: 32,
              timestamp: new Date().toISOString()
            },
        incidentCount: matchedSummary && matchedSummary.compoundRisk.risk_level === "CRITICAL" ? 1 : 0
      };
    });

    setGridCells(hydratedCells);
  }, [summaries]);

  const handleMapClick = (lat: number, lng: number) => {
    onLocationUpdate(lat, lng);
  };

  const gpsIcon = getGpsIcon();

  return (
    <MapContainer
      center={CITY_META.center}
      zoom={CITY_META.defaultZoom}
      zoomControl={true}
      className="h-full w-full"
      preferCanvas
    >
      <LayersControl position="topright">
        {/* Base Map Options */}
        <LayersControl.BaseLayer checked name="Base Map (Dark)">
          <TileLayer
            attribution="Demo basemap &copy; OpenStreetMap contributors"
            url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
          />
        </LayersControl.BaseLayer>
        
        <LayersControl.BaseLayer name="Base Map (Standard)">
          <TileLayer
            attribution="&copy; OpenStreetMap contributors"
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
        </LayersControl.BaseLayer>

        {/* Wards Boundary Overlay Layer */}
        <LayersControl.Overlay checked name="Ward Heatmap Layer">
          <GeoJSON
            ref={geoJsonRef}
            data={featureCollection as any}
            style={styleFeature}
            onEachFeature={onEachFeature}
          />
        </LayersControl.Overlay>

        {/* Mathematical Viewport Grid Cells Overlay */}
        <LayersControl.Overlay checked name="Geospatial Grid Cells">
          <LayersControl.Overlay name="Grid Overlay">
            <>
              {gridCells.map((cell) => {
                const temp = cell.weather?.temperature ?? 30;
                const color = getTempColor(temp);
                const isCellSelected = cell.id === selectedGridId;

                return (
                  <Rectangle
                    key={cell.id}
                    bounds={cell.bounds}
                    pathOptions={{
                      fillColor: color,
                      fillOpacity: isCellSelected ? 0.35 : 0.12,
                      color: isCellSelected ? "#38bdf8" : "#263354",
                      weight: isCellSelected ? 1.5 : 0.4
                    }}
                    eventHandlers={{
                      click: (e) => {
                        L.DomEvent.stopPropagation(e);
                        handleMapClick(cell.center[0], cell.center[1]);
                      }
                    }}
                  >
                    <Tooltip sticky>
                      <div className="text-[11px] font-sans leading-tight">
                        <strong>Grid Cell ID:</strong> {cell.id}<br/>
                        <strong>Center:</strong> {cell.center[0].toFixed(5)}, {cell.center[1].toFixed(5)}<br/>
                        <strong>Area:</strong> {cell.areaSqKm} km²<br/>
                        <strong>Temp:</strong> {temp.toFixed(1)}°C<br/>
                        {cell.incidentCount > 0 && <span className="font-semibold text-red-400 mt-1 block">Critical Risk Ward Incident</span>}
                      </div>
                    </Tooltip>
                  </Rectangle>
                );
              })}
            </>
          </LayersControl.Overlay>
        </LayersControl.Overlay>
      </LayersControl>

      {/* Pulsing GPS location marker on map */}
      {selectedCoords && gpsIcon && (
        <Marker position={selectedCoords} icon={gpsIcon} />
      )}

      {/* Fly map programmatically */}
      <FlyToWard center={focusCenter ?? null} />

      {/* Viewport Bounds Tracker */}
      <ViewportTracker onBoundsChange={handleBoundsChange} />

      {/* Map Click Listener */}
      <MapClickHandler onClick={handleMapClick} />
    </MapContainer>
  );
}
