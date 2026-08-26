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
    final filtered = MockDataService.wards.where((w) {
      final q = _searchQuery.toLowerCase();
      return w.name.toLowerCase().contains(q) || w.id.toLowerCase().contains(q);
    }).toList();

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search wards...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final ward = filtered[index];
                final isSelected = widget.selectedWard?.id == ward.id;
                final risk = MockDataService.getRiskPrediction(ward.id);

                Color badgeColor;
                switch (risk.riskLevel) {
                  case RiskLevel.CRITICAL:
                    badgeColor = const Color(0xFFEF4444);
                    break;
                  case RiskLevel.HIGH:
                    badgeColor = const Color(0xFFF97316);
                    break;
                  case RiskLevel.MODERATE:
                    badgeColor = const Color(0xFFEAB308);
                    break;
                  case RiskLevel.LOW:
                    badgeColor = const Color(0xFF10B981);
                    break;
                }

                return Material(
                  color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onSelectWard(ward),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ward.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${ward.id} • ${ward.population.toString()} residents',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: badgeColor.withAlpha(100)),
                            ),
                            child: Text(
                              '${risk.compoundRiskScore} ${risk.riskLevel.name}',
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
