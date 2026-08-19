import { WardFeatureData } from '@/lib/types';
import { RiskBadge } from '@/components/ui/RiskBadge';
import { Metric } from '@/components/ui/Metric';
import { getInterventionsForLevel } from '@/lib/mock-data/demo-data';

interface WardDetailProps {
  data: WardFeatureData;
}

export function WardDetail({ data }: WardDetailProps) {
  const { ward, weather, grid, vulnerability, risk, explanation } = data;
  const interventions = getInterventionsForLevel(risk.riskLevel);

  return (
    <div className="h-full overflow-y-auto p-4 fade-in">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h2 className="text-xl font-bold text-[#d4d9e4]">{ward.name}</h2>
          <p className="text-xs text-[#6e7a92]">{ward.population.toLocaleString()} pop • {ward.areaSqKm} km²</p>
        </div>
        <RiskBadge level={risk.riskLevel} />
      </div>

      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="card"><Metric value={weather.heatIndex} label="Heat Index" unit="°C" /></div>
        <div className="card"><Metric value={grid.gridStress} label="Grid Stress Index" unit="/100" /></div>
        <div className="card"><Metric value={vulnerability.vulnerabilityScore} label="Vulnerability Score" unit="/100" /></div>
        <div className="card"><Metric value={vulnerability.coolingAccess} label="Cooling Access" unit="%" /></div>
      </div>

      <div className="card mb-6">
        <div className="card-header">Risk Decomposition</div>
        <div className="space-y-3">
          {[
            { label: 'Heat Stress', value: explanation.heatStress, color: '#f97316' },
            { label: 'Grid Stress', value: explanation.gridStress, color: '#eab308' },
            { label: 'Vulnerability', value: explanation.vulnerability, color: '#ef4444' },
            { label: 'Lack of Cooling', value: explanation.coolingAccess, color: '#38bdf8' },
          ].map(item => (
            <div key={item.label}>
              <div className="flex justify-between text-xs mb-1">
                <span className="text-[#d4d9e4]">{item.label}</span>
                <span className="text-[#6e7a92]">{item.value}%</span>
              </div>
              <div className="h-1.5 bg-[#1c2740] rounded-full overflow-hidden">
                <div className="h-full rounded-full transition-all duration-500" style={{ width: `${item.value}%`, backgroundColor: item.color }} />
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="card">
        <div className="card-header">Recommended Interventions</div>
        <div className="space-y-2">
          {interventions.map(int => (
            <div key={int.id} className="p-3 bg-[#070b14] rounded-md border border-[#1c2740]">
              <div className="flex items-center gap-2 mb-1">
                <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded ${
                  int.priority === 'CRITICAL' ? 'bg-red-500/20 text-red-400' : 
                  int.priority === 'HIGH' ? 'bg-orange-500/20 text-orange-400' : 
                  'bg-yellow-500/20 text-yellow-400'
                }`}>
                  {int.priority}
                </span>
                <span className="text-sm font-medium text-[#d4d9e4]">{int.title}</span>
              </div>
              <p className="text-xs text-[#6e7a92]">{int.description}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
