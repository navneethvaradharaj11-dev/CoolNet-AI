'use client';
import { useState } from 'react';
import { WardFeatureData, SimulationResult, SimulationInput } from '@/lib/types';
import { mockMLService } from '@/lib/ml/mock-ml-service';
import { getWardFeaturesForML } from '@/lib/mock-data/demo-data';
import { RiskBadge } from '@/components/ui/RiskBadge';
import { supabase, isSupabaseConfigured } from '@/lib/supabase/supabase-client';

interface SimulationPanelProps {
  data: WardFeatureData;
}

export function SimulationPanel({ data }: SimulationPanelProps) {
  const [tempChange, setTempChange] = useState(0);
  const [demandChange, setDemandChange] = useState(0);
  const [coolingChange, setCoolingChange] = useState(0);
  const [result, setResult] = useState<SimulationResult | null>(null);
  const [loading, setLoading] = useState(false);

  const runSimulation = async () => {
    setLoading(true);
    const features = getWardFeaturesForML(data.ward.id);
    if (!features) return;
    const input: SimulationInput = {
      temperatureChange: tempChange,
      demandChange: demandChange,
      coolingAccessChange: coolingChange,
      wardId: data.ward.id,
    };
    
    setTimeout(async () => {
      const res = await mockMLService.runScenarioSimulation(features, input);
      setResult(res);
      setLoading(false);

      // Auditing simulation log record to Supabase
      if (isSupabaseConfigured() && supabase) {
        try {
          const { error } = await supabase
            .from('simulation_logs')
            .insert({
              ward_id: data.ward.id,
              temperature_change: tempChange,
              demand_change: demandChange,
              cooling_access_change: coolingChange,
              original_risk: res.originalRisk,
              new_risk: res.newRisk,
              risk_delta: res.riskDelta,
              new_risk_level: res.newRiskLevel
            });
          if (error) throw error;
          console.log('⚡ CoolNet DB: Logged simulation audit record to Supabase');
        } catch (dbErr) {
          console.warn('⚡ CoolNet DB: Failed to audit log simulation', dbErr);
        }
      }
    }, 600);
  };

  return (
    <div className="card h-full flex flex-col">
      <div className="card-header">Scenario Simulator</div>
      <div className="space-y-4 mb-4">
        <div>
          <div className="flex justify-between text-xs mb-1.5">
            <span className="text-[#d4d9e4]">Temperature Shift</span>
            <span className="font-mono text-[#38bdf8]">{tempChange > 0 ? '+' : ''}{tempChange}°C</span>
          </div>
          <input type="range" min="-5" max="10" value={tempChange} onChange={(e) => setTempChange(Number(e.target.value))} className="slider-track" />
        </div>
        <div>
          <div className="flex justify-between text-xs mb-1.5">
            <span className="text-[#d4d9e4]">Grid Demand Shift</span>
            <span className="font-mono text-[#38bdf8]">{demandChange > 0 ? '+' : ''}{demandChange} MW</span>
          </div>
          <input type="range" min="-30" max="30" value={demandChange} onChange={(e) => setDemandChange(Number(e.target.value))} className="slider-track" />
        </div>
        <div>
          <div className="flex justify-between text-xs mb-1.5">
            <span className="text-[#d4d9e4]">Cooling Access Improvement</span>
            <span className="font-mono text-[#38bdf8]">{coolingChange > 0 ? '+' : ''}{coolingChange}%</span>
          </div>
          <input type="range" min="0" max="50" value={coolingChange} onChange={(e) => setCoolingChange(Number(e.target.value))} className="slider-track" />
        </div>
      </div>
      <button onClick={runSimulation} disabled={loading} className="w-full py-2 bg-[#38bdf8] hover:bg-[#0ea5e9] text-[#070b14] text-xs font-bold rounded-md transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
        {loading ? 'PROCESSING...' : 'RUN SCENARIO'}
      </button>
      {result && (
        <div className="mt-4 pt-4 border-t border-[#1c2740] fade-in">
          <div className="grid grid-cols-3 gap-2 text-center mb-3">
            <div>
              <div className="text-[10px] text-[#6e7a92] uppercase">Original</div>
              <div className="text-lg font-bold text-[#d4d9e4]">{result.originalRisk}</div>
            </div>
            <div>
              <div className="text-[10px] text-[#6e7a92] uppercase">Delta</div>
              <div className={`text-lg font-bold ${result.riskDelta > 0 ? 'text-[#ef4444]' : 'text-[#22c55e]'}`}>
                {result.riskDelta > 0 ? '+' : ''}{result.riskDelta}
              </div>
            </div>
            <div>
              <div className="text-[10px] text-[#6e7a92] uppercase">New</div>
              <div className="text-lg font-bold text-[#d4d9e4]">{result.newRisk}</div>
            </div>
          </div>
          <div className="flex justify-center">
            <RiskBadge level={result.newRiskLevel} />
          </div>
        </div>
      )}
    </div>
  );
}
