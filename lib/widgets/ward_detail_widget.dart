import 'package:flutter/material.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/mock_data_service.dart';

class WardDetailWidget extends StatelessWidget {
  final Ward ward;
  final bool embedded;

  const WardDetailWidget({
    super.key,
    required this.ward,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final weather = MockDataService.getWeatherData(ward.id);
    final grid = MockDataService.getGridData(ward.id);
    final vulnerability = MockDataService.getVulnerabilityData(ward.id);
    final prediction = MockDataService.getRiskPrediction(ward.id);
    final riskColor = _riskColor(prediction.riskLevel);

    final content = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WARD PROFILE',
                  style: TextStyle(color: Color(0xFF71839B), fontSize: 9, letterSpacing: 1.25, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  ward.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ward.id}  ·  ${ward.areaSqKm} km²',
                  style: const TextStyle(color: Color(0xFF91A4BC), fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: riskColor.withAlpha(20),
              border: Border.all(color: riskColor.withAlpha(85)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prediction.compoundRiskScore.toStringAsFixed(1),
                  style: TextStyle(color: riskColor, fontSize: 18, fontWeight: FontWeight.w800, height: 1),
                ),
                const SizedBox(height: 5),
                Text(
                  prediction.riskLevel.name,
                  style: TextStyle(color: riskColor, fontSize: 8, letterSpacing: 0.5, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1524),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF23334A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.people_alt_outlined, color: Color(0xFF7DD3FC), size: 18),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Population exposure', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(height: 3),
                  Text('Sample demographic profile', style: TextStyle(color: Color(0xFF71839B), fontSize: 9)),
                ],
              ),
            ),
            Text(
              '${ward.population.toString()}',
              style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _buildMetricCard(
        title: 'Heat & weather',
        icon: Icons.thermostat_rounded,
        color: const Color(0xFFFBBF24),
        items: [
          MapEntry('Air temperature', '${weather.temperature.toStringAsFixed(1)}°C'),
          MapEntry('Relative humidity', '${weather.humidity.toStringAsFixed(0)}%'),
          MapEntry('Calculated heat index', '${weather.heatIndex.toStringAsFixed(1)}°C'),
        ],
      ),
      const SizedBox(height: 12),
      _buildMetricCard(
        title: 'Electrical grid',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF38BDF8),
        items: [
          MapEntry('Demand proxy', '${grid.electricityDemand.toStringAsFixed(1)}%'),
          MapEntry('Estimated grid stress', '${grid.gridStress.toStringAsFixed(1)}%'),
          MapEntry('Sample outage frequency', '${(grid.historicalOutageFreq * 100).round()}%'),
        ],
      ),
      const SizedBox(height: 12),
      _buildMetricCard(
        title: 'Social vulnerability',
        icon: Icons.diversity_3_rounded,
        color: const Color(0xFFA78BFA),
        items: [
          MapEntry('Vulnerability score', '${vulnerability.vulnerabilityScore.toStringAsFixed(1)} / 100'),
          MapEntry('Cooling access index', '${vulnerability.coolingAccess.toStringAsFixed(1)}%'),
          MapEntry('Elderly population ratio', '${vulnerability.elderlyRatio.toStringAsFixed(1)}%'),
          MapEntry('Population density', '${ward.populationDensity} / km²'),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFBBF24).withAlpha(12),
          border: Border.all(color: const Color(0xFFFBBF24).withAlpha(45)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 15),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'Sample values for prototype exploration. These are not live telemetry or an operational alert.',
                style: TextStyle(color: Color(0xFFB8A678), fontSize: 10, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ];

    if (embedded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1726),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF23334A)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content),
      );
    }

    return Container(
      width: 352,
      decoration: const BoxDecoration(
        color: Color(0xFF0C1726),
        border: Border(left: BorderSide(color: Color(0xFF23334A), width: 1)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: content,
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<MapEntry<String, String>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23334A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 7),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const Divider(color: Color(0xFF23334A), height: 19),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(item.key, style: const TextStyle(color: Color(0xFF91A4BC), fontSize: 10)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.w600, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.CRITICAL:
        return const Color(0xFFFB7185);
      case RiskLevel.HIGH:
        return const Color(0xFFF97316);
      case RiskLevel.MODERATE:
        return const Color(0xFFFBBF24);
      case RiskLevel.LOW:
        return const Color(0xFF2DD4BF);
    }
  }
}
