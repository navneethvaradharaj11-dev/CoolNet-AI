import 'package:flutter/material.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/ml_service.dart';

class SimulationWidget extends StatefulWidget {
  final Ward ward;

  const SimulationWidget({super.key, required this.ward});

  @override
  State<SimulationWidget> createState() => _SimulationWidgetState();
}

class _SimulationWidgetState extends State<SimulationWidget> {
  double _tempDelta = 2.0;
  double _demandDelta = 10.0;
  double _coolingDelta = -5.0;
  SimulationResult? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runSim();
  }

  @override
  void didUpdateWidget(covariant SimulationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ward.id != widget.ward.id) {
      _runSim();
    }
  }

  Future<void> _runSim() async {
    setState(() => _isLoading = true);
    final input = SimulationInput(
      temperatureChange: _tempDelta,
      demandChange: _demandDelta,
      coolingAccessChange: _coolingDelta,
      wardId: widget.ward.id,
    );
    final res = await MLService.runScenarioSimulation(input);
    if (mounted) {
      setState(() {
        _result = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡ What-If Heatwave Simulation Panel',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              if (_result != null)
                Text(
                  'Original: ${_result!.originalRisk} ➔ Sim: ${_result!.newRisk} (Δ ${_result!.riskDelta >= 0 ? "+" : ""}${_result!.riskDelta})',
                  style: TextStyle(
                    color: _result!.riskDelta > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSlider(
                  label: 'Temperature Delta',
                  value: _tempDelta,
                  min: -5,
                  max: 10,
                  unit: '°C',
                  onChanged: (v) {
                    setState(() => _tempDelta = v);
                    _runSim();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSlider(
                  label: 'Grid Demand Delta',
                  value: _demandDelta,
                  min: -30,
                  max: 30,
                  unit: '%',
                  onChanged: (v) {
                    setState(() => _demandDelta = v);
                    _runSim();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSlider(
                  label: 'Cooling Access Shift',
                  value: _coolingDelta,
                  min: -20,
                  max: 20,
                  unit: '%',
                  onChanged: (v) {
                    setState(() => _coolingDelta = v);
                    _runSim();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            Text('${value >= 0 ? "+" : ""}${value.toStringAsFixed(1)}$unit',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF38BDF8),
            inactiveTrackColor: const Color(0xFF1E293B),
            thumbColor: const Color(0xFF38BDF8),
            trackHeight: 3,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
