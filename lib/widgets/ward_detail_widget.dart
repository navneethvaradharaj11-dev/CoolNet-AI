import 'package:flutter/material.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/mock_data_service.dart';

class WardDetailWidget extends StatelessWidget {
  final Ward ward;

  const WardDetailWidget({super.key, required this.ward});

  @override
  Widget build(BuildContext context) {
    final weather = MockDataService.getWeatherData(ward.id);
    final grid = MockDataService.getGridData(ward.id);
    final vuln = MockDataService.getVulnerabilityData(ward.id);
    final risk = MockDataService.getRiskPrediction(ward.id);

    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(left: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ward.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'ID: ${ward.id} • ${ward.areaSqKm} km²',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Text(
                  'Risk: ${risk.compoundRiskScore}',
                  style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricCard(
            title: 'Thermal & Weather Metrics',
            icon: Icons.thermostat,
            color: const Color(0xFFF97316),
            items: [
              MapEntry('Temperature', '${weather.temperature}°C'),
              MapEntry('Relative Humidity', '${weather.humidity}%'),
              MapEntry('Heat Index (Apparent)', '${weather.heatIndex}°C'),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'Electrical Grid Stress',
            icon: Icons.bolt,
            color: const Color(0xFF38BDF8),
            items: [
              MapEntry('Peak Demand Load', '${grid.electricityDemand}%'),
              MapEntry('Transformer Stress', '${grid.gridStress}%'),
              MapEntry('Historical Outages', '${(grid.historicalOutageFreq * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            title: 'Social Vulnerability',
            icon: Icons.people,
            color: const Color(0xFFA855F7),
            items: [
              MapEntry('Vulnerability Index', '${vuln.vulnerabilityScore}/100'),
              MapEntry('AC Cooling Access', '${vuln.coolingAccess}%'),
              MapEntry('Elderly Population Ratio', '${vuln.elderlyRatio}%'),
            ],
          ),
        ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155), height: 16),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    Text(e.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
