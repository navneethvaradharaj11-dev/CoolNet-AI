'use client';
import { useState, useEffect } from 'react';
import dynamic from 'next/dynamic';
import { Header } from '@/components/layout/Header';
import { WardList } from '@/components/panels/WardList';
import { WardDetail } from '@/components/panels/WardDetail';
import { ForecastPanel } from '@/components/panels/ForecastPanel';
import { SimulationPanel } from '@/components/simulation/SimulationPanel';
import { getAllWardsFeatureData, getWardFeaturesForML } from '@/lib/mock-data/demo-data';
import { DemoTag } from '@/components/ui/DemoTag';
import { fetchBatchLiveWeather } from '@/lib/services/weather-service';
import { mockMLService } from '@/lib/ml/mock-ml-service';
import { WardFeatureData } from '@/lib/types';
import { supabase, isSupabaseConfigured } from '@/lib/supabase/supabase-client';

const RiskMap = dynamic(() => import('@/components/map/RiskMap'), {
  ssr: false,
  loading: () => <div className="h-full flex items-center justify-center text-[#6e7a92] text-sm">Loading GIS Map...</div>
});

export default function Dashboard() {
  const [selectedWardId, setSelectedWardId] = useState<string | null>('ward-09');
  const [wardsData, setWardsData] = useState<WardFeatureData[]>(() => getAllWardsFeatureData());
  const [isWeatherLive, setIsWeatherLive] = useState(false);
  const [isGridLive, setIsGridLive] = useState(false);
  const selectedData = wardsData.find(w => w.ward.id === selectedWardId) || wardsData[0];

  useEffect(() => {
    async function loadLiveWeatherData() {
      // 1. Fetch live Open-Meteo weather
      const liveWeatherMap = await fetchBatchLiveWeather();

      // 2. Fetch live grid/SVI from Supabase if configured
      const dbGridMap: Record<string, { electricityDemand: number; gridStress: number; historicalOutageFreq: number }> = {};
      const dbVulnerabilityMap: Record<string, { vulnerabilityScore: number; coolingAccess: number; elderlyRatio: number; incomeIndex: number }> = {};
      let hasDbConnection = false;

      if (isSupabaseConfigured() && supabase) {
        try {
          console.log('⚡ CoolNet DB: Connecting to Supabase server...');
          const { data: gridData, error: gridError } = await supabase
            .from('grid_telemetry')
            .select('*');

          const { data: vulData, error: vulError } = await supabase
            .from('vulnerability_index')
            .select('*');

          if (gridError) throw gridError;
          if (vulError) throw vulError;

          if (gridData && gridData.length > 0) {
            gridData.forEach(item => {
              dbGridMap[item.ward_id] = {
                electricityDemand: Number(item.electricity_demand),
                gridStress: Number(item.grid_stress),
                historicalOutageFreq: Number(item.historical_outage_freq)
              };
            });
            hasDbConnection = true;
          }

          if (vulData && vulData.length > 0) {
            vulData.forEach(item => {
              dbVulnerabilityMap[item.ward_id] = {
                vulnerabilityScore: Number(item.vulnerability_score),
                coolingAccess: Number(item.cooling_access),
                elderlyRatio: Number(item.elderly_ratio),
                incomeIndex: Number(item.income_index)
              };
            });
          }
        } catch (dbErr) {
          console.error('⚡ CoolNet DB: Database telemetry fetch failed', dbErr);
        }
      }

      // 3. Map wardsData with either live database data or mock fallbacks
      const updatedWards = await Promise.all(
        wardsData.map(async (wardData) => {
          // Merge live weather
          const liveWeather = liveWeatherMap ? liveWeatherMap[wardData.ward.id] : null;
          const newWeather = liveWeather ? {
            ...wardData.weather,
            temperature: liveWeather.temperature,
            humidity: liveWeather.humidity,
            heatIndex: liveWeather.heatIndex,
            wbgt: liveWeather.wbgt,
            timestamp: liveWeather.timestamp,
            isReal: true
          } : wardData.weather;

          // Merge Supabase grid telemetry
          const dbGrid = dbGridMap[wardData.ward.id];
          const newGrid = dbGrid ? {
            ...wardData.grid,
            electricityDemand: dbGrid.electricityDemand,
            gridStress: dbGrid.gridStress,
            historicalOutageFreq: dbGrid.historicalOutageFreq
          } : wardData.grid;

          // Merge Supabase vulnerability indices
          const dbVul = dbVulnerabilityMap[wardData.ward.id];
          const newVul = dbVul ? {
            ...wardData.vulnerability,
            vulnerabilityScore: dbVul.vulnerabilityScore,
            coolingAccess: dbVul.coolingAccess,
            elderlyRatio: dbVul.elderlyRatio,
            incomeIndex: dbVul.incomeIndex
          } : wardData.vulnerability;

          // Recalculate compound risk using ML model
          const mockFeatures = getWardFeaturesForML(wardData.ward.id);
          if (!mockFeatures) return wardData;

          const updatedFeatures = {
            ...mockFeatures,
            temperature: newWeather.temperature,
            humidity: newWeather.humidity,
            heatIndex: newWeather.heatIndex,
            electricityDemand: newGrid.electricityDemand,
            gridStress: newGrid.gridStress,
            vulnerabilityScore: newVul.vulnerabilityScore,
            coolingAccess: newVul.coolingAccess
          };

          const riskResult = await mockMLService.calculateCompoundRisk(updatedFeatures);
          const explanationResult = await mockMLService.getRiskExplanation(updatedFeatures);

          return {
            ...wardData,
            weather: newWeather,
            grid: newGrid,
            vulnerability: newVul,
            risk: {
              ...wardData.risk,
              compoundRiskScore: riskResult.score,
              riskLevel: riskResult.level
            },
            explanation: explanationResult
          };
        })
      );

      setWardsData(updatedWards);
      if (liveWeatherMap) setIsWeatherLive(true);
      if (hasDbConnection) setIsGridLive(true);
    }
    loadLiveWeatherData();
  }, []);

  return (
    <div className="h-screen flex flex-col bg-[#070b14]">
      <Header isWeatherLive={isWeatherLive} isGridLive={isGridLive} />
      <div className="bg-[#0c1220] border-b border-[#1c2740] py-1.5 px-6 flex justify-center items-center gap-2 text-xs text-[#6e7a92]">
        <DemoTag />
        <span>
          {isWeatherLive && isGridLive
            ? "Compound risk calculated using LIVE weather telemetry (Open-Meteo) and LIVE grid-stress databases (Supabase)."
            : isWeatherLive
            ? "Compound risk calculated using LIVE weather telemetry (Open-Meteo) and simulated grid-stress coefficients."
            : "System is running on seeded mock data and heuristic models. Not for production use."}
        </span>
      </div>
      <main className="flex-1 grid grid-cols-12 gap-4 p-4 overflow-hidden">
        {/* Left Sidebar - Ward List */}
        <div className="col-span-2 bg-[#0c1220] border border-[#1c2740] rounded-lg overflow-hidden">
          <WardList wardsData={wardsData} selectedWardId={selectedData.ward.id} onSelectWard={setSelectedWardId} />
        </div>

        {/* Center - Map */}
        <div className="col-span-7 bg-[#0c1220] border border-[#1c2740] rounded-lg overflow-hidden relative">
          <RiskMap wardsData={wardsData} selectedWardId={selectedData.ward.id} onSelectWard={setSelectedWardId} />
          <div className="absolute bottom-4 left-4 bg-[#0c1220]/90 backdrop-blur-sm border border-[#1c2740] rounded-md p-3 z-[1000]">
            <div className="text-[10px] font-semibold text-[#6e7a92] uppercase mb-2">Risk Level</div>
            <div className="space-y-1.5">
              {[
                { label: 'Critical', color: '#ef4444' },
                { label: 'High', color: '#f97316' },
                { label: 'Moderate', color: '#eab308' },
                { label: 'Low', color: '#22c55e' },
              ].map(item => (
                <div key={item.label} className="flex items-center gap-2">
                  <div className="w-2.5 h-2.5 rounded-sm" style={{ backgroundColor: item.color }} />
                  <span className="text-xs text-[#d4d9e4]">{item.label}</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Sidebar - Details, Forecast, & Simulation */}
        <div className="col-span-3 grid grid-rows-3 gap-4 overflow-hidden">
          <div className="bg-[#0c1220] border border-[#1c2740] rounded-lg overflow-hidden">
            <WardDetail data={selectedData} />
          </div>
          <div className="overflow-hidden">
            <ForecastPanel data={selectedData} />
          </div>
          <div className="overflow-hidden">
            <SimulationPanel data={selectedData} />
          </div>
        </div>
      </main>
    </div>
  );
}
