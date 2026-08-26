-- CoolNet AI Database Schema
-- Run this in your Supabase SQL Editor to initialize tables and insert seed data

-- 1. Create Grid Telemetry Table
CREATE TABLE IF NOT EXISTS grid_telemetry (
  ward_id VARCHAR(50) PRIMARY KEY,
  electricity_demand NUMERIC NOT NULL,
  grid_stress NUMERIC NOT NULL,
  historical_outage_freq NUMERIC NOT NULL,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create Social Vulnerability Index (SVI) Table
CREATE TABLE IF NOT EXISTS vulnerability_index (
  ward_id VARCHAR(50) PRIMARY KEY,
  vulnerability_score NUMERIC NOT NULL,
  cooling_access NUMERIC NOT NULL,
  elderly_ratio NUMERIC NOT NULL,
  income_index NUMERIC NOT NULL,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create Simulation Logs Table for Audit Audits
CREATE TABLE IF NOT EXISTS simulation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ward_id VARCHAR(50) NOT NULL,
  temperature_change NUMERIC NOT NULL,
  demand_change NUMERIC NOT NULL,
  cooling_access_change NUMERIC NOT NULL,
  original_risk NUMERIC NOT NULL,
  new_risk NUMERIC NOT NULL,
  risk_delta NUMERIC NOT NULL,
  new_risk_level VARCHAR(50) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE grid_telemetry ENABLE ROW LEVEL SECURITY;
ALTER TABLE vulnerability_index ENABLE ROW LEVEL SECURITY;
ALTER TABLE simulation_logs ENABLE ROW LEVEL SECURITY;

-- Create public read policies
CREATE POLICY "Allow public read access on grid_telemetry" ON grid_telemetry FOR SELECT USING (true);
CREATE POLICY "Allow public read access on vulnerability_index" ON vulnerability_index FOR SELECT USING (true);
CREATE POLICY "Allow public insert access on simulation_logs" ON simulation_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public read access on simulation_logs" ON simulation_logs FOR SELECT USING (true);

-- Create public insert/update policy for grid_telemetry (for demo interactivity)
CREATE POLICY "Allow public updates on grid_telemetry" ON grid_telemetry FOR ALL USING (true);

-- 4. Seed initial mock values
INSERT INTO grid_telemetry (ward_id, electricity_demand, grid_stress, historical_outage_freq) VALUES
('ward-01', 78, 62, 0.12),
('ward-02', 82, 68, 0.18),
('ward-03', 85, 72, 0.22),
('ward-04', 65, 48, 0.06),
('ward-05', 88, 74, 0.25),
('ward-06', 72, 58, 0.10),
('ward-07', 91, 78, 0.30),
('ward-08', 76, 60, 0.14),
('ward-09', 94, 85, 0.35),
('ward-10', 68, 52, 0.08),
('ward-11', 80, 65, 0.16),
('ward-12', 74, 59, 0.11),
('ward-13', 89, 75, 0.28),
('ward-14', 62, 45, 0.05),
('ward-15', 83, 69, 0.20),
('ward-16', 71, 55, 0.09),
('ward-17', 96, 88, 0.40),
('ward-18', 66, 50, 0.07),
('ward-19', 92, 82, 0.32),
('ward-20', 79, 63, 0.15)
ON CONFLICT (ward_id) DO UPDATE SET 
  electricity_demand = EXCLUDED.electricity_demand,
  grid_stress = EXCLUDED.grid_stress,
  historical_outage_freq = EXCLUDED.historical_outage_freq,
  last_updated = now();

INSERT INTO vulnerability_index (ward_id, vulnerability_score, cooling_access, elderly_ratio, income_index) VALUES
('ward-01', 45, 62, 12, 55),
('ward-02', 58, 48, 15, 42),
('ward-03', 62, 45, 18, 38),
('ward-04', 30, 78, 8, 72),
('ward-05', 68, 40, 20, 35),
('ward-06', 42, 65, 11, 58),
('ward-07', 75, 35, 22, 28),
('ward-08', 50, 55, 14, 50),
('ward-09', 82, 28, 25, 22),
('ward-10', 35, 72, 9, 68),
('ward-11', 55, 50, 16, 45),
('ward-12', 48, 60, 13, 52),
('ward-13', 72, 38, 21, 30),
('ward-14', 28, 80, 7, 75),
('ward-15', 60, 46, 17, 40),
('ward-16', 40, 68, 10, 60),
('ward-17', 85, 25, 26, 20),
('ward-18', 32, 75, 8, 70),
('ward-19', 78, 32, 24, 25),
('ward-20', 52, 52, 15, 48)
ON CONFLICT (ward_id) DO UPDATE SET 
  vulnerability_score = EXCLUDED.vulnerability_score,
  cooling_access = EXCLUDED.cooling_access,
  elderly_ratio = EXCLUDED.elderly_ratio,
  income_index = EXCLUDED.income_index,
  last_updated = now();
