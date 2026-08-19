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

const RiskMap = dynamic(() => import('@/components/map/RiskMap'), {
  ssr: false,
  loading: () => <div className="h-full flex items-center justify-center text-[#6e7a92] text-sm">Loading GIS Map...</div>
});

export default function Dashboard() {
  const [selectedWardId, setSelectedWardId] = useState<string | null>('ward-09');
  const [wardsData, setWardsData] = useState<WardFeatureData[]>(() => getAllWardsFeatureData());
  const [isWeatherLive, setIsWeatherLive] = useState(false);
  const selectedData = wardsData.find(w => w.ward.id === selectedWardId) || wardsData[0];

  useEffect(() => {
    async function loadLiveWeather() {
      const liveWeatherMap = await fetchBatchLiveWeather();
      if (liveWeatherMap) {
        const updatedWards = await Promise.all(
          wardsData.map(async (wardData) => {
            const live = liveWeatherMap[wardData.ward.id];
            if (!live) return wardData;

            const newWeather = {
              ...wardData.weather,
              temperature: live.temperature,
              humidity: live.humidity,
              heatIndex: live.heatIndex,
              wbgt: live.wbgt,
              timestamp: live.timestamp,
              isReal: true
            };

            const mockFeatures = getWardFeaturesForML(wardData.ward.id);
            if (!mockFeatures) return wardData;

            const updatedFeatures = {
              ...mockFeatures,
              temperature: newWeather.temperature,
              humidity: newWeather.humidity,
              heatIndex: newWeather.heatIndex,
              timestamp: newWeather.timestamp
            };

            const riskResult = await mockMLService.calculateCompoundRisk(updatedFeatures);
            const explanationResult = await mockMLService.getRiskExplanation(updatedFeatures);

            return {
              ...wardData,
              weather: newWeather,
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
        setIsWeatherLive(true);
      }
    }
    loadLiveWeather();
  }, []);

  return (
    <div className="h-screen flex flex-col bg-[#070b14]">
      <Header isWeatherLive={isWeatherLive} />
      <div className="bg-[#0c1220] border-b border-[#1c2740] py-1.5 px-6 flex justify-center items-center gap-2 text-xs text-[#6e7a92]">
        <DemoTag />
        <span>
          {isWeatherLive 
            ? "Compound risk calculated using LIVE weather telemetry from Open-Meteo API and simulated grid-stress coefficients."
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
