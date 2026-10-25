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

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final narrow = viewportWidth < 900;
    final panelWidth = narrow ? double.infinity : (viewportWidth < 1360 ? 250.0 : 300.0);
    final filtered = MockDataService.wards.where((ward) {
      final query = _searchQuery.trim().toLowerCase();
      return ward.name.toLowerCase().contains(query) || ward.id.toLowerCase().contains(query);
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
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Ward watchlist',
                        style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withAlpha(18),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${MockDataService.wards.length} WARDS',
                        style: const TextStyle(color: Color(0xFF7DD3FC), fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a ward to inspect its risk profile',
                  style: TextStyle(color: Color(0xFF71839B), fontSize: 10),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search wards...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF71839B), size: 18),
                    prefixIconConstraints: const BoxConstraints(minWidth: 38),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF23334A)),
                    ),
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
                      child: Text('No wards match that search.', style: TextStyle(color: Color(0xFF71839B), fontSize: 12)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ward = filtered[index];
                      final isSelected = widget.selectedWard?.id == ward.id;
                      final prediction = MockDataService.getRiskPrediction(ward.id);
                      final color = _riskColor(prediction.riskLevel);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Material(
                          color: isSelected ? const Color(0xFF14263A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(11),
                            onTap: () => widget.onSelectWard(ward),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF28506A) : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(23),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.location_on_outlined, size: 18, color: color),
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
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${ward.population.toString()} residents',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Color(0xFF71839B), fontSize: 10),
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
                                      const SizedBox(height: 3),
                                      Text(
                                        prediction.riskLevel.name,
                                        style: TextStyle(color: color, fontSize: 8, letterSpacing: 0.45, fontWeight: FontWeight.w800),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Text(
              'Risk values are calculated from sample inputs.',
              style: TextStyle(color: Color(0xFF52657D), fontSize: 9),
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
