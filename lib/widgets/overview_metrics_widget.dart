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
    final highOrCritical = predictions
        .where((prediction) => prediction.riskLevel == RiskLevel.HIGH || prediction.riskLevel == RiskLevel.CRITICAL)
        .length;
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
        note: 'Sample ward catalog',
        icon: Icons.location_city_rounded,
        color: const Color(0xFF60A5FA),
      ),
      _MetricData(
        label: 'HIGH / CRITICAL',
        value: '$highOrCritical',
        note: 'Prioritize for review',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFF97316),
      ),
      _MetricData(
        label: 'PEAK TEMPERATURE',
        value: '${peakTemperature.toStringAsFixed(1)}°C',
        note: 'Synthetic weather input',
        icon: Icons.device_thermostat_rounded,
        color: const Color(0xFFFBBF24),
      ),
      _MetricData(
        label: 'MEAN RISK SCORE',
        value: '${averageRisk.toStringAsFixed(1)} / 100',
        note: 'Computed from demo metrics',
        icon: Icons.insights_rounded,
        color: const Color(0xFF2DD4BF),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final cardWidth = wide
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF23334A)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: metric.color.withAlpha(24),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(metric.icon, size: 19, color: metric.color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF91A4BC),
                    fontSize: 9,
                    letterSpacing: 1.05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 20,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
