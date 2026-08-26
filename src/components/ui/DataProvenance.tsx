"use client";

export function DataProvenance() {
  return (
    <div className="rounded-lg border border-border bg-base-950/80 p-4 text-xs text-ink-300 shadow-lg leading-relaxed">
      <div className="flex items-center gap-2 mb-2">
        <span className="h-2 w-2 rounded-full bg-accent" />
        <span className="font-bold tracking-wide uppercase text-accent">Data Provenance & Calibration Audit</span>
      </div>
      <div className="space-y-2.5 text-ink-400 text-[11px]">
        <p>
          <strong>Heat Index Calculation:</strong> Calculated using the NOAA National Weather Service (NWS) thermodynamic formula (Rothfusz regression model).
        </p>
        <p>
          <strong>Anchored Calibration Bounds:</strong> Ward weather and vulnerability values are demo data, bounded to realistic ranges from verified 2023-2025 IMD/MoHFW national heatwave statistics (230-554 heatwave days, 44-50.5°C peak temperatures, 374 confirmed heatstroke deaths).
        </p>
        <p>
          <strong>Power Grid Load Model:</strong> Electricity and grid stress data are simulated and calibrated to published heat-demand correlation patterns.
        </p>
        <p className="border-t border-border/40 pt-2 text-[10.5px] italic text-ink-500">
          No official Indian dataset for Heat Index/WBGT currently exists — this is a genuine gap this prototype addresses computationally.
        </p>
      </div>
    </div>
  );
}
