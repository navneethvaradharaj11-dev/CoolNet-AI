import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/risk_data.dart';
import '../physics/heat_index.dart';
import 'mock_data_service.dart';

class MLService {
  /// Base URL configured via Flutter build-time environment (--dart-define=API_BASE_URL=...)
  /// In release builds, defaults to live Render backend; in debug mode, defaults to localhost.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static String get backendBaseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    return const bool.fromEnvironment('dart.vm.product')
        ? 'https://coolnet-ai-backend.onrender.com'
        : 'http://127.0.0.1:8000';
  }
  static const Duration requestTimeout = Duration(seconds: 8);

  /// Checks whether the backend API is reachable and healthy.
  static Future<bool> checkBackendHealth() async {
    try {
      final uri = Uri.parse('$backendBaseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Performs risk prediction for a ward.
  /// Attempts to call the local ONNX backend first; if unavailable or timing out,
  /// falls back deterministically to the calibrated local prototype engine.
  static Future<RiskPrediction> predictWardRisk(String wardId) async {
    final weather = MockDataService.getWeatherData(wardId);
    final grid = MockDataService.getGridData(wardId);
    final vuln = MockDataService.getVulnerabilityData(wardId);
    final ward = MockDataService.wards.firstWhere(
      (w) => w.id == wardId,
      orElse: () => MockDataService.wards.first,
    );

    try {
      final uri = Uri.parse('$backendBaseUrl/api/predict');
      final payload = jsonEncode({
        'ward_id': wardId,
        'temperature': weather.temperature,
        'humidity': weather.humidity,
        'heat_index': weather.heatIndex,
        'electricity_demand': grid.electricityDemand,
        'outage_probability': grid.historicalOutageFreq,
        'population_density': ward.populationDensity.toDouble(),
        'vulnerability_index': vuln.vulnerabilityScore / 100.0,
      });

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final double score = (data['compound_risk_score'] as num).toDouble();
        final List<FeatureContribution> contributions = (data['feature_contributions'] as List? ?? [])
            .map((item) => FeatureContribution(
                  feature: item['feature'] as String,
                  displayName: item['display_name'] as String,
                  value: (item['value'] as num).toDouble(),
                  unit: item['unit'] as String,
                  importanceWeight: (item['importance_weight'] as num).toDouble(),
                  contributionScore: (item['contribution_score'] as num).toDouble(),
                  description: item['description'] as String,
                ))
            .toList();

        return RiskPrediction(
          wardId: wardId,
          compoundRiskScore: score,
          riskLevel: RiskLevelExtension.fromScore(score),
          predicted30min: double.parse((score + 3).clamp(0, 100).toStringAsFixed(1)),
          predicted60min: double.parse((score + 7).clamp(0, 100).toStringAsFixed(1)),
          timestamp: data['timestamp'] as String? ?? DateTime.now().toIso8601String(),
          isModelInference: data['is_model_inference'] as bool? ?? true,
          modelVersion: data['model_version'] as String? ?? '1.0.0 (ONNX Ensemble)',
          dataStatus: data['data_status'] as String? ?? 'validated_inference',
          featureContributions: contributions,
        );
      }
    } catch (_) {
      // Backend not running or timeout; seamlessly use deterministic local engine
    }

    // Deterministic calibrated local fallback
    return MockDataService.getRiskPrediction(wardId);
  }

  /// Retrieves structured Explainable AI insights for a ward prediction.
  /// Calls the Python explanation backend (with LLM anti-hallucination validation)
  /// or returns a calibrated, rule-based evidence synthesis fallback.
  static Future<ExplanationResult> getRiskExplanationResult(
    String wardId,
    RiskPrediction prediction,
  ) async {
    final weather = MockDataService.getWeatherData(wardId);
    final grid = MockDataService.getGridData(wardId);

    try {
      final uri = Uri.parse('$backendBaseUrl/api/explain');
      final payload = jsonEncode({
        'ward_id': wardId,
        'risk_score': prediction.compoundRiskScore,
        'risk_level': prediction.riskLevel.name,
        'data': {
          'temperature': weather.temperature,
          'heat_index': weather.heatIndex,
          'electricity_demand': grid.electricityDemand,
        },
        'shap_factors': prediction.featureContributions
            .map((fc) => {
                  'feature': fc.feature,
                  'contribution': fc.contributionScore,
                })
            .toList(),
      });

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ExplanationResult.fromJson(data, isLLM: true);
      }
    } catch (_) {
      // Backend offline or request timed out; return local deterministic explanation
    }

    // Local evidence-grounded non-LLM explanation fallback
    final keyFactors = prediction.featureContributions.map((fc) {
      return KeyFactorItem(
        factor: fc.displayName,
        contribution: fc.contributionScore,
        explanation: '${fc.displayName} of ${fc.value.toStringAsFixed(1)}${fc.unit} creates compound risk pressure.',
      );
    }).toList();

    if (keyFactors.isEmpty) {
      keyFactors.add(KeyFactorItem(
        factor: 'Heat Index',
        contribution: weather.heatIndex,
        explanation: 'Atmospheric heat index of ${weather.heatIndex.toStringAsFixed(1)}°C.',
      ));
      keyFactors.add(KeyFactorItem(
        factor: 'Grid Demand',
        contribution: grid.electricityDemand,
        explanation: 'Power demand proxy at ${grid.electricityDemand.toStringAsFixed(0)}%.',
      ));
    }

    final levelStr = prediction.riskLevel.name;
    final summary = 'Ward $wardId is evaluated at $levelStr risk (${prediction.compoundRiskScore.toStringAsFixed(1)}/100) '
        'driven primarily by high heat index (${weather.heatIndex.toStringAsFixed(1)}°C) and elevated electricity demand (${grid.electricityDemand.toStringAsFixed(0)}%).';

    final interpretation = 'Thermal stress induces heavy air conditioning load, raising substation demand and compounding '
        'heat-health vulnerabilities across the resident population.';

    final recommendations = [
      'Monitor distribution transformers for thermal strain during peak hours.',
      'Ensure local public cooling centers and shaded water stations remain accessible.',
      if (prediction.riskLevel == RiskLevel.high || prediction.riskLevel == RiskLevel.critical) ...[
        'Position backup emergency mobile generators near primary healthcare clinics.',
        'Issue voluntary peak-shaving notifications to large commercial consumers.',
      ]
    ];

    const dataNote = 'Decision-support evaluation based on validated local demographic and meteorological inputs. '
        'Grid metrics represent simulated proxies, not real-time utility telemetry.';

    const limitations = [
      'Model does not forecast exact equipment failure or blackout times.',
      'Grid telemetry is simulated; utility SCADA integration is required for operational switching.',
      'Social vulnerability reflects aggregate demographic baselines.',
    ];

    return ExplanationResult(
      summary: summary,
      riskInterpretation: interpretation,
      keyFactors: keyFactors,
      recommendedActions: recommendations,
      dataQualityNote: dataNote,
      limitations: limitations,
      isLLMGenerated: false,
    );
  }

  /// Legacy RiskExplanation for backward compatibility
  static Future<RiskExplanation> getRiskExplanation(String wardId) async {
    final weather = MockDataService.getWeatherData(wardId);
    final grid = MockDataService.getGridData(wardId);
    final vuln = MockDataService.getVulnerabilityData(wardId);

    final double heatStress = ((weather.heatIndex - 30) * 3).clamp(0, 100);
    return RiskExplanation(
      heatStress: double.parse(heatStress.toStringAsFixed(1)),
      gridStress: grid.gridStress,
      vulnerability: vuln.vulnerabilityScore,
      coolingAccess: 100 - vuln.coolingAccess,
    );
  }

  /// Runs what-if scenario simulations with physical consistency.
  static Future<SimulationResult> runScenarioSimulation(SimulationInput input) async {
    final baseline = await predictWardRisk(input.wardId);
    final weather = MockDataService.getWeatherData(input.wardId);
    final grid = MockDataService.getGridData(input.wardId);
    final vuln = MockDataService.getVulnerabilityData(input.wardId);
    final ward = MockDataService.wards.firstWhere(
      (w) => w.id == input.wardId,
      orElse: () => MockDataService.wards.first,
    );

    final double newTemp = weather.temperature + input.temperatureChange;
    final double newHeatIndex = HeatIndexCalculator.calculate(newTemp, weather.humidity);
    final double newDemand = (grid.electricityDemand + input.demandChange).clamp(0, 100);
    final double newGridStress = (newDemand * 0.85).clamp(0, 100);
    final double newCoolingAccess = (vuln.coolingAccess + input.coolingAccessChange).clamp(0, 100);
    final double newVulnScore = (vuln.vulnerabilityScore - input.coolingAccessChange * 0.5).clamp(0, 100);

    double newRiskScore;

    // If backend is active, run scenario through backend ONNX model
    try {
      final uri = Uri.parse('$backendBaseUrl/api/predict');
      final payload = jsonEncode({
        'ward_id': input.wardId,
        'temperature': newTemp,
        'humidity': weather.humidity,
        'heat_index': newHeatIndex,
        'electricity_demand': newDemand,
        'outage_probability': grid.historicalOutageFreq,
        'population_density': ward.populationDensity.toDouble(),
        'vulnerability_index': newVulnScore / 100.0,
      });

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: payload)
          .timeout(const Duration(milliseconds: 800));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        newRiskScore = (data['compound_risk_score'] as num).toDouble();
      } else {
        final double heatScore = ((newHeatIndex - 30) * 3).clamp(0, 100);
        newRiskScore = (heatScore * 0.4 + newGridStress * 0.3 + newVulnScore * 0.3).clamp(0, 100);
      }
    } catch (_) {
      final double heatScore = ((newHeatIndex - 30) * 3).clamp(0, 100);
      newRiskScore = (heatScore * 0.4 + newGridStress * 0.3 + newVulnScore * 0.3).clamp(0, 100);
    }

    final double originalRisk = baseline.compoundRiskScore;
    final double newRisk = double.parse(newRiskScore.toStringAsFixed(1));
    final double delta = double.parse((newRisk - originalRisk).toStringAsFixed(1));
    final double finalHeatScore = ((newHeatIndex - 30) * 3).clamp(0, 100);

    return SimulationResult(
      originalRisk: originalRisk,
      newRisk: newRisk,
      riskDelta: delta,
      newRiskLevel: RiskLevelExtension.fromScore(newRisk),
      explanation: RiskExplanation(
        heatStress: double.parse(finalHeatScore.toStringAsFixed(1)),
        gridStress: newGridStress,
        vulnerability: newVulnScore,
        coolingAccess: 100 - newCoolingAccess,
      ),
    );
  }
}
