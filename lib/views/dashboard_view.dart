import 'package:flutter/material.dart';
import '../models/ward.dart';
import '../services/mock_data_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/overview_metrics_widget.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo view refreshed. This workspace currently uses sample inputs.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectWard(Ward ward) => setState(() => _selectedWard = ward);

  @override
  Widget build(BuildContext context) {
    final wards = MockDataService.wards;

    return Scaffold(
      backgroundColor: const Color(0xFF080F1C),
      body: SafeArea(
        child: Column(
          children: [
            HeaderWidget(onRefresh: _handleRefresh),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: OverviewMetricsWidget(wards: wards),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1360) {
                    return _buildDesktopLayout(wards);
                  }
                  if (constraints.maxWidth >= 900) {
                    return _buildTabletLayout(wards);
                  }
                  return _buildMobileLayout(wards);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(List<Ward> wards) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: WardListWidget(
            selectedWard: _selectedWard,
            onSelectWard: _selectWard,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 8, 12),
            child: Column(
              children: [
                _buildMapToolbar(compact: false),
                const SizedBox(height: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: RiskMapWidget(
                      wards: wards,
                      selectedWard: _selectedWard,
                      onSelectWard: _selectWard,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedWard != null) SimulationWidget(ward: _selectedWard!),
              ],
            ),
          ),
        ),
        if (_selectedWard != null)
          SizedBox(
            width: 352,
            child: WardDetailWidget(ward: _selectedWard!),
          ),
      ],
    );
  }

  Widget _buildTabletLayout(List<Ward> wards) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 250,
          child: WardListWidget(
            selectedWard: _selectedWard,
            onSelectWard: _selectWard,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMapToolbar(compact: true),
                const SizedBox(height: 10),
                SizedBox(
                  height: 440,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: RiskMapWidget(
                      wards: wards,
                      selectedWard: _selectedWard,
                      onSelectWard: _selectWard,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedWard != null) SimulationWidget(ward: _selectedWard!),
                if (_selectedWard != null) ...[
                  const SizedBox(height: 12),
                  WardDetailWidget(ward: _selectedWard!, embedded: true),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<Ward> wards) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMapToolbar(compact: true),
          const SizedBox(height: 10),
          SizedBox(
            height: 340,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RiskMapWidget(
                wards: wards,
                selectedWard: _selectedWard,
                onSelectWard: _selectWard,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: WardListWidget(
              selectedWard: _selectedWard,
              onSelectWard: _selectWard,
            ),
          ),
          if (_selectedWard != null) ...[
            const SizedBox(height: 12),
            SimulationWidget(ward: _selectedWard!),
            const SizedBox(height: 12),
            WardDetailWidget(ward: _selectedWard!, embedded: true),
          ],
        ],
      ),
    );
  }

  Widget _buildMapToolbar({required bool compact}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8).withAlpha(22),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.public_rounded, color: Color(0xFF38BDF8), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spatial risk map',
                style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                compact ? 'Tap a ward to inspect its risk profile' : 'Delhi sample wards · illustrative ward boundaries',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF71839B), fontSize: 11),
              ),
            ],
          ),
        ),
        if (!compact) ...[
          _legendItem('Critical', const Color(0xFFFB7185)),
          const SizedBox(width: 10),
          _legendItem('High', const Color(0xFFF97316)),
          const SizedBox(width: 10),
          _legendItem('Moderate', const Color(0xFFFBBF24)),
          const SizedBox(width: 10),
          _legendItem('Low', const Color(0xFF2DD4BF)),
        ],
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0xFF91A4BC), fontSize: 10)),
      ],
    );
  }
}
