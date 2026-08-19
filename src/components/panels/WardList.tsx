import { WardFeatureData } from '@/lib/types';
import { RiskBadge } from '@/components/ui/RiskBadge';

interface WardListProps {
  wardsData: WardFeatureData[];
  selectedWardId: string | null;
  onSelectWard: (wardId: string) => void;
}

export function WardList({ wardsData, selectedWardId, onSelectWard }: WardListProps) {
  const sortedWards = [...wardsData].sort((a, b) => b.risk.compoundRiskScore - a.risk.compoundRiskScore);
  return (
    <div className="flex flex-col h-full">
      <div className="card-header px-4 pt-4">At-Risk Wards (Sorted)</div>
      <div className="flex-1 overflow-y-auto px-2 pb-2">
        {sortedWards.map(({ ward, risk, weather }) => (
          <button
            key={ward.id}
            onClick={() => onSelectWard(ward.id)}
            className={`w-full text-left p-3 rounded-md mb-1 transition-colors border ${
              selectedWardId === ward.id 
                ? 'bg-[#111827] border-[#38bdf8]' 
                : 'bg-transparent border-transparent hover:bg-[#0c1220] hover:border-[#1c2740]'
            }`}
          >
            <div className="flex justify-between items-center mb-1">
              <span className="text-sm font-medium text-[#d4d9e4]">{ward.name}</span>
              <RiskBadge level={risk.riskLevel} />
            </div>
            <div className="flex justify-between text-[11px] text-[#6e7a92]">
              <span>Pop: {(ward.population / 1000).toFixed(1)}k</span>
              <span>HI: {weather.heatIndex}°C</span>
              <span>Risk: {risk.compoundRiskScore}</span>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
