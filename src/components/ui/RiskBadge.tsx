import { RiskLevel } from '@/lib/types';

const riskClassMap: Record<RiskLevel, string> = {
  LOW: 'risk-low', MODERATE: 'risk-moderate', HIGH: 'risk-high', CRITICAL: 'risk-critical',
};

export function RiskBadge({ level }: { level: RiskLevel }) {
  return <span className={`risk-badge ${riskClassMap[level]}`}>{level}</span>;
}
