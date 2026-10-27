import 'package:flutter/material.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/mock_data_service.dart';

class WardListWidget extends StatefulWidget {
  final Ward? selectedWard;
  final ValueChanged<Ward> onSelectWard;

  const WardListWidget({
    super.key,
    required this.selectedWard,
    required this.onSelectWard,
  });

  @override
  State<WardListWidget> createState() => _WardListWidgetState();
}

class _WardListWidgetState extends State<WardListWidget> {
  String _searchQuery = '';
  String _selectedFilter = 'ALL'; // ALL, CRITICAL, HIGH, MEDIUM, LOW

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final narrow = viewportWidth < 900;
    final panelWidth = narrow ? double.infinity : (viewportWidth < 1360 ? 270.0 : 320.0);

    final allWards = MockDataService.wards;
    final filtered = allWards.where((ward) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          ward.name.toLowerCase().contains(query) ||
          ward.id.toLowerCase().contains(query) ||
          ward.zone.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'ALL') return true;
      final risk = MockDataService.getRiskPrediction(ward.id);
      if (_selectedFilter == 'CRITICAL') return risk.riskLevel == RiskLevel.critical;
      if (_selectedFilter == 'HIGH') return risk.riskLevel == RiskLevel.high;
      if (_selectedFilter == 'MEDIUM') return risk.riskLevel == RiskLevel.moderate;
      if (_selectedFilter == 'LOW') return risk.riskLevel == RiskLevel.low;
      return true;
    }).toList();

    return Container(
      width: panelWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF0C1726),
        border: Border(right: BorderSide(color: Color(0xFF23334A), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ward Intelligence',
                        style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withAlpha(22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${allWards.length} REAL WARDS',
                        style: const TextStyle(
                          color: Color(0xFF7DD3FC),
                          fontSize: 9,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Delhi NCT · Real administrative boundaries',
                  style: TextStyle(color: Color(0xFF71839B), fontSize: 10),
                ),
                const SizedBox(height: 10),

                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search ward or zone...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF71839B), size: 17),
                    prefixIconConstraints: const BoxConstraints(minWidth: 36),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: Color(0xFF23334A)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Risk Filter Chips (ALL, CRITICAL, HIGH, MEDIUM, LOW)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('ALL', 'ALL', null),
                      const SizedBox(width: 5),
                      _filterChip('CRITICAL', 'CRITICAL', const Color(0xFFFB7185)),
                      const SizedBox(width: 5),
                      _filterChip('HIGH', 'HIGH', const Color(0xFFF97316)),
                      const SizedBox(width: 5),
                      _filterChip('MEDIUM', 'MEDIUM', const Color(0xFFFBBF24)),
                      const SizedBox(width: 5),
                      _filterChip('LOW', 'LOW', const Color(0xFF2DD4BF)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF23334A)),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'No wards match that filter/search.',
                        style: TextStyle(color: Color(0xFF71839B), fontSize: 12),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ward = filtered[index];
                      final isSelected = widget.selectedWard?.id == ward.id;
                      final prediction = MockDataService.getRiskPrediction(ward.id);
                      final weather = MockDataService.getWeatherData(ward.id);
                      final color = _riskColor(prediction.riskLevel);
                      final String riskTag = _riskTag(prediction.riskLevel);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        child: Material(
                          color: isSelected ? const Color(0xFF162B44) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => widget.onSelectWard(ward),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF38BDF8).withAlpha(160) : Colors.transparent,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Location indicator with risk level color
                                  Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(25),
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(color: color.withAlpha(60), width: 1),
                                    ),
                                    child: Icon(Icons.location_on_rounded, size: 17, color: color),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ward.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFFF8FAFC) : const Color(0xFFCBD5E1),
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${ward.zone} · ${ward.population ~/ 1000}k pop · ${weather.temperature.toStringAsFixed(0)}°C',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Color(0xFF71839B), fontSize: 9.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        prediction.compoundRiskScore.toStringAsFixed(1),
                                        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: color.withAlpha(35),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          riskTag,
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 8,
                                            letterSpacing: 0.4,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF22C55E)),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Real meteorological & demographic baseline',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label, Color? color) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? (color != null ? color.withAlpha(40) : const Color(0xFF38BDF8).withAlpha(40))
              : const Color(0xFF101B2B),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFF38BDF8))
                : const Color(0xFF23334A),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (color ?? const Color(0xFF7DD3FC))
                : const Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return const Color(0xFFFB7185);
      case RiskLevel.high:
        return const Color(0xFFF97316);
      case RiskLevel.moderate:
        return const Color(0xFFFBBF24);
      case RiskLevel.low:
        return const Color(0xFF2DD4BF);
    }
  }

  String _riskTag(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return 'CRITICAL';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.moderate:
        return 'MEDIUM';
      case RiskLevel.low:
        return 'LOW';
    }
  }
}
