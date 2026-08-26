import 'package:flutter/material.dart';
import '../models/ward.dart';
import '../services/mock_data_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/ward_list_widget.dart';
import '../widgets/ward_detail_widget.dart';
import '../widgets/risk_map_widget.dart';
import '../widgets/simulation_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Ward? _selectedWard;

  @override
  void initState() {
    super.initState();
    if (MockDataService.wards.isNotEmpty) {
      _selectedWard = MockDataService.wards.first;
    }
  }

  void _handleRefresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final wards = MockDataService.wards;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Column(
        children: [
          HeaderWidget(onRefresh: _handleRefresh),
          Expanded(
            child: Row(
              children: [
                WardListWidget(
                  selectedWard: _selectedWard,
                  onSelectWard: (w) => setState(() => _selectedWard = w),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: RiskMapWidget(
                          wards: wards,
                          selectedWard: _selectedWard,
                          onSelectWard: (w) => setState(() => _selectedWard = w),
                        ),
                      ),
                      if (_selectedWard != null)
                        SimulationWidget(ward: _selectedWard!),
                    ],
                  ),
                ),
                if (_selectedWard != null)
                  WardDetailWidget(ward: _selectedWard!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
