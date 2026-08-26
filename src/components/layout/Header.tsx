'use client';
import { useEffect, useState } from 'react';
import { DemoTag } from '@/components/ui/DemoTag';

interface HeaderProps {
  isWeatherLive?: boolean;
  isGridLive?: boolean;
}

export function Header({ isWeatherLive, isGridLive }: HeaderProps) {
  const [time, setTime] = useState(new Date());
  useEffect(() => {
    const timer = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const statusItems = [
    {
      key: 'weather',
      label: isWeatherLive ? 'Weather API (LIVE)' : 'Weather API (MOCK)',
      colorClass: isWeatherLive ? 'bg-[#22c55e]' : 'bg-[#eab308]'
    },
    {
      key: 'grid',
      label: isGridLive ? 'Grid Telemetry (LIVE)' : 'Grid Telemetry (SIMULATED)',
      colorClass: isGridLive ? 'bg-[#22c55e]' : 'bg-[#eab308]'
    },
    {
      key: 'svi',
      label: isGridLive ? 'SVI Index (LIVE)' : 'SVI Index (SIMULATED)',
      colorClass: isGridLive ? 'bg-[#22c55e]' : 'bg-[#eab308]'
    },
    {
      key: 'ml',
      label: (isWeatherLive || isGridLive) ? 'ML Model (LIVE)' : 'ML Model (DEMO)',
      colorClass: (isWeatherLive || isGridLive) ? 'bg-[#22c55e]' : 'bg-[#eab308]'
    }
  ];

  return (
    <header className="flex items-center justify-between h-14 px-6 border-b border-[#1c2740] bg-[#0c1220] z-50">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-md bg-gradient-to-br from-[#38bdf8] to-[#0ea5e9] flex items-center justify-center">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5">
              <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
            </svg>
          </div>
          <div>
            <h1 className="text-sm font-bold tracking-tight text-[#d4d9e4]">CoolNet AI</h1>
            <p className="text-[10px] text-[#6e7a92] -mt-0.5">Compound Heat-Grid Risk Intelligence</p>
          </div>
        </div>
      </div>
      <div className="flex items-center gap-6">
        <div className="hidden lg:flex items-center gap-4 text-xs text-[#6e7a92]">
          {statusItems.map(item => (
            <div key={item.key} className="flex items-center gap-1.5">
              <span className={`w-1.5 h-1.5 rounded-full ${item.colorClass}`}></span>
              {item.label}
            </div>
          ))}
        </div>
        <DemoTag />
        <div className="font-mono text-sm text-[#d4d9e4] border-l border-[#1c2740] pl-6">
          {time.toLocaleTimeString('en-US', { hour12: false })}
        </div>
      </div>
    </header>
  );
}
