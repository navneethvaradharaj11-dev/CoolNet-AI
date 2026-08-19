import { WardFeatureData, ForecastPoint } from '@/lib/types';
import { RiskBadge } from '@/components/ui/RiskBadge';

interface ForecastPanelProps {
  data: WardFeatureData;
}

function generateForecast(data: WardFeatureData): ForecastPoint[] {
  const baseRisk = data.risk.compoundRiskScore;
  const points = [
    { label: 'Now', risk: baseRisk },
    { label: '+1h', risk: baseRisk + Math.round(Math.sin(baseRisk) * 5) },
    { label: '+2h', risk: baseRisk + Math.round(Math.sin(baseRisk + 1) * 8) },
    { label: '+3h', risk: baseRisk + Math.round(Math.cos(baseRisk) * 12) },
    { label: '+4h', risk: baseRisk + Math.round(Math.cos(baseRisk + 1) * 6) },
    { label: '+5h', risk: baseRisk + Math.round(Math.sin(baseRisk + 2) * 2) },
    { label: '+6h', risk: baseRisk - Math.round(Math.cos(baseRisk + 2) * 4) },
  ];
  return points.map(p => ({
    ...p,
    risk: Math.max(0, Math.min(100, p.risk)),
    riskLevel: p.risk >= 70 ? 'CRITICAL' : p.risk >= 50 ? 'HIGH' : p.risk >= 30 ? 'MODERATE' : 'LOW'
  }));
}

export function ForecastPanel({ data }: ForecastPanelProps) {
  const forecast = generateForecast(data);
  const maxRisk = Math.max(...forecast.map(f => f.risk));

  return (
    <div className="card h-full flex flex-col">
      <div className="flex justify-between items-center mb-3">
        <span className="card-header !mb-0">6-Hour Risk Forecast</span>
        <RiskBadge level={data.risk.riskLevel} />
      </div>
      <div className="flex-1 flex items-end justify-between gap-2 pt-4">
        {forecast.map((point, i) => (
          <div key={i} className="flex-1 flex flex-col items-center gap-2 group">
            <span className="text-[10px] font-mono text-[#6e7a92] group-hover:text-[#d4d9e4] transition-colors">{point.risk}</span>
            <div className="w-full bg-[#1c2740] rounded-t-sm overflow-hidden flex flex-col-reverse" style={{ height: '120px' }}>
              <div 
                className="w-full transition-all duration-500 rounded-t-sm"
                style={{
                  height: `${(point.risk / 100) * 100}%`,
                  backgroundColor: point.riskLevel === 'CRITICAL' ? '#ef4444' : point.riskLevel === 'HIGH' ? '#f97316' : point.riskLevel === 'MODERATE' ? '#eab308' : '#22c55e',
                  opacity: point.risk === maxRisk ? 1 : 0.7
                }}
              />
            </div>
            <span className="text-[10px] text-[#6e7a92]">{point.label}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
