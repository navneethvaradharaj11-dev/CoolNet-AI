export function Metric({ value, label, unit }: { value: string | number; label: string; unit?: string }) {
  return (
    <div>
      <div className="metric-value">
        {value}
        {unit && <span className="text-sm font-normal ml-1 text-[#6e7a92]">{unit}</span>}
      </div>
      <div className="metric-label">{label}</div>
    </div>
  );
}
