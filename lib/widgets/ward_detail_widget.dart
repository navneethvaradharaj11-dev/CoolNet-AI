import 'package:flutter/material.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/ml_service.dart';
import '../services/mock_data_service.dart';

class WardDetailWidget extends StatefulWidget {
  final Ward ward;
  final bool embedded;

  const WardDetailWidget({
    super.key,
    required this.ward,
    this.embedded = false,
  });

  @override
  State<WardDetailWidget> createState() => _WardDetailWidgetState();
}

class _WardDetailWidgetState extends State<WardDetailWidget> {
  RiskPrediction? _prediction;
  ExplanationResult? _explanation;
  bool _isLoadingPrediction = false;
  bool _isLoadingExplanation = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant WardDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ward.id != widget.ward.id) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingPrediction = true;
      _isLoadingExplanation = true;
    });

    final prediction = await MLService.predictWardRisk(widget.ward.id);
    if (!mounted) return;
    setState(() {
      _prediction = prediction;
      _isLoadingPrediction = false;
    });

    final explanation = await MLService.getRiskExplanationResult(widget.ward.id, prediction);
    if (!mounted) return;
    setState(() {
      _explanation = explanation;
      _isLoadingExplanation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weather = MockDataService.getWeatherData(widget.ward.id);
    final grid = MockDataService.getGridData(widget.ward.id);
    final vulnerability = MockDataService.getVulnerabilityData(widget.ward.id);
    final prediction = _prediction ?? MockDataService.getRiskPrediction(widget.ward.id);
    final riskColor = _riskColor(prediction.riskLevel);

    final content = <Widget>[
      // 1. Ward Header & Risk Score
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WARD INTELLIGENCE PROFILE',
                  style: TextStyle(color: Color(0xFF71839B), fontSize: 9, letterSpacing: 1.25, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.ward.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.ward.id}  ·  ${widget.ward.zone}  ·  ${widget.ward.areaSqKm} km²',
                  style: const TextStyle(color: Color(0xFF91A4BC), fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                  prediction.riskLevel.displayLabel,
                  style: TextStyle(color: riskColor, fontSize: 8.5, letterSpacing: 0.5, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // 2. Model & Data Provenance Badge
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF101B2B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF23334A)),
        ),
        child: Row(
          children: [
            Icon(
              prediction.isModelInference ? Icons.memory_rounded : Icons.calculate_outlined,
              size: 16,
              color: prediction.isModelInference ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.isModelInference ? 'ONNX Regressor Inference' : 'Calibrated Real Baseline Engine',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Status: ${prediction.dataStatus} · ${prediction.modelVersion}',
                    style: const TextStyle(color: Color(0xFF71839B), fontSize: 8),
                  ),
                ],
              ),
            ),
            if (_isLoadingPrediction)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8))),
          ],
        ),
      ),
      const SizedBox(height: 12),

      // 3. Contributing Factors / SHAP Attribution Breakdown
      if (prediction.featureContributions.isNotEmpty) ...[
        _buildContributionsCard(prediction.featureContributions),
        const SizedBox(height: 12),
      ],

      // 4. Metric Cards: Weather, Grid, Vulnerability
      _buildMetricCard(
        title: weather.isReal ? 'Live atmosphere (Open-Meteo API)' : 'Heat & atmosphere',
        icon: Icons.thermostat_rounded,
        color: const Color(0xFFFBBF24),
        items: [
          MapEntry('Air temperature', '${weather.temperature.toStringAsFixed(1)}°C'),
          MapEntry('Relative humidity', '${weather.humidity.toStringAsFixed(0)}%'),
          MapEntry('Calculated heat index', '${weather.heatIndex.toStringAsFixed(1)}°C'),
          if (weather.feelsLike != null)
            MapEntry('Feels like', '${weather.feelsLike!.toStringAsFixed(1)}°C'),
          if (weather.condition != null)
            MapEntry('Condition', weather.condition!),
        ],
      ),
      const SizedBox(height: 12),
      _buildMetricCard(
        title: 'Electrical grid (estimates)',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF38BDF8),
        items: [
          MapEntry('Electricity demand proxy', '${grid.electricityDemand.toStringAsFixed(1)}%'),
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
          MapEntry('Population density', '${widget.ward.populationDensity} / km²'),
        ],
      ),
      const SizedBox(height: 12),

      // 5. Explainable AI & Decision Support Panel
      _buildExplanationCard(),
      const SizedBox(height: 12),

      // 6. Data Integrity & Disclaimer Notice
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
                'Estimates are calibrated for resilience research. They do not represent live utility telemetry or emergency evacuation alerts.',
                style: TextStyle(color: Color(0xFFB8A678), fontSize: 10, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ];

    if (widget.embedded) {
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

  Widget _buildContributionsCard(List<FeatureContribution> contributions) {
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
            children: const [
              Icon(Icons.pie_chart_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Model Factor Contributions',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF23334A), height: 18),
          ...contributions.map((fc) {
            final double pct = (fc.importanceWeight * 100).clamp(0, 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(fc.displayName, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        '+${fc.contributionScore.toStringAsFixed(1)} pts (${pct.toStringAsFixed(0)}% wt)',
                        style: const TextStyle(color: Color(0xFF91A4BC), fontSize: 9),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: fc.importanceWeight.clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFF1E293B),
                      color: const Color(0xFF38BDF8),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    final exp = _explanation;
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
              const Icon(Icons.psychology_alt_rounded, size: 17, color: Color(0xFF2DD4BF)),
              const SizedBox(width: 7),
              const Expanded(
                child: Text('Explainable AI & Recommendations', style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              if (_isLoadingExplanation)
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2DD4BF))),
            ],
          ),
          const Divider(color: Color(0xFF23334A), height: 18),
          if (exp == null)
            const Text('Loading explainability synthesis...', style: TextStyle(color: Color(0xFF71839B), fontSize: 10))
          else ...[
            Text(
              exp.summary,
              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 10, height: 1.4, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            const Text('RECOMMENDED INTERVENTIONS', style: TextStyle(color: Color(0xFF71839B), fontSize: 8, letterSpacing: 0.8, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            ...exp.recommendedActions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 10, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(action, style: const TextStyle(color: Color(0xFF91A4BC), fontSize: 9, height: 1.35))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1524),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DATA QUALITY & LIMITATIONS', style: TextStyle(color: Color(0xFF64748B), fontSize: 7, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(exp.dataQualityNote, style: const TextStyle(color: Color(0xFF71839B), fontSize: 8, height: 1.3)),
                ],
              ),
            ),
          ],
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
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
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
}
