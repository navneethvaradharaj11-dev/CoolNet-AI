import 'package:flutter/material.dart';
import '../models/risk_data.dart';
import '../models/ward.dart';
import '../services/mock_data_service.dart';

class OverviewMetricsWidget extends StatelessWidget {
  final List<Ward> wards;

  const OverviewMetricsWidget({super.key, required this.wards});

  @override
  Widget build(BuildContext context) {
    final predictions = wards.map((ward) => MockDataService.getRiskPrediction(ward.id)).toList();
    final criticalCount = predictions.where((p) => p.riskLevel == RiskLevel.critical).length;
    final highCount = predictions.where((p) => p.riskLevel == RiskLevel.high).length;
    final mediumCount = predictions.where((p) => p.riskLevel == RiskLevel.moderate).length;
    final lowCount = predictions.where((p) => p.riskLevel == RiskLevel.low).length;
    final highOrCritical = criticalCount + highCount;

    final peakTemperature = wards
        .map((ward) => MockDataService.getWeatherData(ward.id).temperature)
        .fold<double>(0, (peak, value) => value > peak ? value : peak);
    final averageRisk = predictions.isEmpty
        ? 0.0
        : predictions.fold<double>(0, (sum, prediction) => sum + prediction.compoundRiskScore) / predictions.length;

    final metrics = <_MetricData>[
      _MetricData(
        label: 'WARDS MONITORED',
        value: '${wards.length}',
        note: 'Delhi NCT administrative wards',
        icon: Icons.location_city_rounded,
        color: const Color(0xFF38BDF8),
      ),
      _MetricData(
        label: 'HIGH / CRITICAL WARDS',
        value: '$highOrCritical',
        note: '$criticalCount Critical · $highCount High',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFF97316),
      ),
      _MetricData(
        label: 'MEDIUM & LOW WARDS',
        value: '${mediumCount + lowCount}',
        note: '$mediumCount Medium · $lowCount Low',
        icon: Icons.shield_outlined,
        color: const Color(0xFF2DD4BF),
      ),
      _MetricData(
        label: 'PEAK HEAT INDEX',
        value: '${peakTemperature.toStringAsFixed(1)}°C',
        note: 'Real meteorological telemetry',
        icon: Icons.thermostat_rounded,
        color: const Color(0xFFFBBF24),
      ),
      _MetricData(
        label: 'MEAN RISK SCORE',
        value: '${averageRisk.toStringAsFixed(1)} / 100',
        note: 'Aggregated compound risk',
        icon: Icons.insights_rounded,
        color: const Color(0xFFA78BFA),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = metrics.length;
        final wide = constraints.maxWidth >= 1200;
        final medium = constraints.maxWidth >= 760;

        final double cardWidth;
        if (wide) {
          cardWidth = (constraints.maxWidth - (count - 1) * 10) / count;
        } else if (medium) {
          cardWidth = (constraints.maxWidth - 20) / 3;
        } else {
          cardWidth = (constraints.maxWidth - 10) / 2;
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: metrics
              .map((metric) => SizedBox(
                    width: cardWidth,
                    child: _MetricCard(metric: metric),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final String note;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.label,
    required this.value,
    required this.note,
    required this.icon,
    required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23334A)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: metric.color.withAlpha(24),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(metric.icon, size: 18, color: metric.color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF91A4BC),
                    fontSize: 8.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 18,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  metric.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
