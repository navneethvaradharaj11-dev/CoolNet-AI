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
    final result = await MLService.runScenarioSimulation(input);
    if (mounted) {
      setState(() {
        _result = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final result = _result;
        final deltaColor = result == null
            ? const Color(0xFF91A4BC)
            : result.riskDelta > 0
                ? const Color(0xFFFB7185)
                : result.riskDelta < 0
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFFFBBF24);

        final sliders = <Widget>[
          _buildSlider(
            label: 'Temperature shift',
            value: _tempDelta,
            min: -5,
            max: 10,
            unit: '°C',
            onChanged: (value) {
              setState(() => _tempDelta = value);
              _runSim();
            },
          ),
          _buildSlider(
            label: 'Grid demand shift',
            value: _demandDelta,
            min: -30,
            max: 30,
            unit: '%',
            onChanged: (value) {
              setState(() => _demandDelta = value);
              _runSim();
            },
          ),
          _buildSlider(
            label: 'Cooling access shift',
            value: _coolingDelta,
            min: -20,
            max: 20,
            unit: '%',
            onChanged: (value) {
              setState(() => _coolingDelta = value);
              _runSim();
            },
          ),
        ];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1726),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF23334A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DD4BF).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF2DD4BF), size: 18),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Scenario lab', style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 13, fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Explore how changing conditions could affect this ward', style: TextStyle(color: Color(0xFF71839B), fontSize: 9)),
                      ],
                    ),
                  ),
                  if (!compact)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withAlpha(16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('WHAT-IF MODEL', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 8, letterSpacing: 0.55, fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF101B2B),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFF23334A)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _riskValue(
                        label: 'BASELINE RISK',
                        value: result == null ? '—' : result.originalRisk.toStringAsFixed(1),
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    Container(width: 1, height: 34, color: const Color(0xFF2B3B51)),
                    Expanded(
                      child: _riskValue(
                        label: 'SCENARIO RISK',
                        value: result == null ? '—' : result.newRisk.toStringAsFixed(1),
                        color: deltaColor,
                      ),
                    ),
                    Container(width: 1, height: 34, color: const Color(0xFF2B3B51)),
                    Expanded(
                      child: _riskValue(
                        label: 'RISK CHANGE',
                        value: result == null
                            ? (_isLoading ? '…' : '—')
                            : '${result.riskDelta >= 0 ? '+' : ''}${result.riskDelta.toStringAsFixed(1)}',
                        color: deltaColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (compact)
                Column(children: sliders)
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < sliders.length; index++) ...[
                      if (index > 0) const SizedBox(width: 14),
                      Expanded(child: sliders[index]),
                    ],
                  ],
                ),
              const SizedBox(height: 5),
              const Text(
                'Prototype simulation using local formulas and sample values; not an operational forecast.',
                style: TextStyle(color: Color(0xFF52657D), fontSize: 9, height: 1.35),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _riskValue({required String label, required String value, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF71839B), fontSize: 7, letterSpacing: 0.65, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w800, height: 1)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF91A4BC), fontSize: 10),
                ),
              ),
              Text(
                '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}$unit',
                style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF38BDF8),
              inactiveTrackColor: const Color(0xFF23334A),
              thumbColor: const Color(0xFF7DD3FC),
              overlayColor: const Color(0xFF38BDF8).withAlpha(24),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
