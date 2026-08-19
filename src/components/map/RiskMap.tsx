'use client';
import { MapContainer, TileLayer, GeoJSON, Tooltip, CircleMarker } from 'react-leaflet';
import L from 'leaflet';
import { WardFeatureData, RiskLevel } from '@/lib/types';
import { WARDS_GEOJSON } from '@/lib/geojson/wards';

const riskColors: Record<RiskLevel, string> = {
  LOW: '#22c55e', MODERATE: '#eab308', HIGH: '#f97316', CRITICAL: '#ef4444',
};

interface RiskMapProps {
  wardsData: WardFeatureData[];
  selectedWardId: string | null;
  onSelectWard: (wardId: string) => void;
}

export default function RiskMap({ wardsData, selectedWardId, onSelectWard }: RiskMapProps) {
  const dataMap = new Map(wardsData.map(d => [d.ward.id, d]));

  const style = (feature: any) => {
    const wardId = feature.properties.wardId;
    const data = dataMap.get(wardId);
    const isSelected = wardId === selectedWardId;
    return {
      fillColor: data ? riskColors[data.risk.riskLevel] : '#1c2740',
      weight: isSelected ? 3 : 1,
      opacity: 1,
      color: isSelected ? '#38bdf8' : '#263354',
      fillOpacity: data ? 0.6 : 0.1,
    };
  };

  const onEachFeature = (feature: any, layer: L.Layer) => {
    const wardId = feature.properties.wardId;
    const data = dataMap.get(wardId);
    layer.on({
      click: () => onSelectWard(wardId),
      mouseover: (e: L.LeafletMouseEvent) => e.target.setStyle({ weight: 2, color: '#38bdf8' }),
      mouseout: (e: L.LeafletMouseEvent) => e.target.setStyle(style(feature))
    });
    if (data) {
      layer.bindTooltip(`
        <div style="font-weight: 700; margin-bottom: 4px;">${data.ward.name}</div>
        <div>Risk Level: <span style="color: ${riskColors[data.risk.riskLevel]}; font-weight: 700;">${data.risk.riskLevel}</span></div>
        <div>Compound Score: ${data.risk.compoundRiskScore}/100</div>
        <div>Heat Index: ${data.weather.heatIndex}°C</div>
      `, { sticky: true });
    }
  };

  return (
    <MapContainer center={[28.6315, 77.2220]} zoom={12} zoomControl={true} className="h-full w-full">
      <TileLayer
        url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>'
      />
      <GeoJSON data={WARDS_GEOJSON} style={style} onEachFeature={onEachFeature} />
      {wardsData.filter(w => w.risk.riskLevel === 'CRITICAL').map(w => (
        <CircleMarker
          key={w.ward.id}
          center={w.ward.center}
          radius={6}
          pathOptions={{ color: '#ef4444', fillColor: '#ef4444', fillOpacity: 0.8 }}
        >
          <Tooltip>
            <div className="font-bold">{w.ward.name}</div>
            <div>Critical Risk Zone</div>
          </Tooltip>
        </CircleMarker>
      ))}
    </MapContainer>
  );
}
