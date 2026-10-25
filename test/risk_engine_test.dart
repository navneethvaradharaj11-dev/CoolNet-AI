import 'package:flutter_test/flutter_test.dart';
import 'package:coolnet/models/risk_data.dart';
import 'package:coolnet/physics/heat_index.dart';
import 'package:coolnet/services/ml_service.dart';
import 'package:coolnet/services/mock_data_service.dart';

void main() {
  group('HeatIndexCalculator', () {
    test('returns a finite heat index for hot and humid input', () {
      final heatIndex = HeatIndexCalculator.calculate(40.0, 60.0);

      expect(heatIndex.isFinite, isTrue);
      expect(heatIndex, greaterThan(40.0));
      expect(heatIndex, lessThan(70.0));
    });

    test('handles moderate conditions using simple regression fallback', () {
      final heatIndex = HeatIndexCalculator.calculate(22.0, 45.0);
      expect(heatIndex.isFinite, isTrue);
      expect(heatIndex, inInclusiveRange(18.0, 30.0));
    });

    test('clamps relative humidity properly and handles boundary extremes', () {
      final extremeDry = HeatIndexCalculator.calculate(42.0, 5.0);
      final extremeWet = HeatIndexCalculator.calculate(35.0, 95.0);

      expect(extremeDry.isFinite, isTrue);
      expect(extremeWet.isFinite, isTrue);
      expect(extremeWet, greaterThan(extremeDry));
    });
  });

  group('Prototype ward risk scores & Determinism', () {
    test('risk-level thresholds are consistent at each exact boundary', () {
      expect(RiskLevelExtension.fromScore(29.9), RiskLevel.low);
      expect(RiskLevelExtension.fromScore(30.0), RiskLevel.moderate);
      expect(RiskLevelExtension.fromScore(49.9), RiskLevel.moderate);
      expect(RiskLevelExtension.fromScore(50.0), RiskLevel.high);
      expect(RiskLevelExtension.fromScore(69.9), RiskLevel.high);
      expect(RiskLevelExtension.fromScore(70.0), RiskLevel.critical);
      expect(RiskLevelExtension.fromScore(100.0), RiskLevel.critical);
    });

    test('all sample ward scores remain on the documented 0-100 scale and match their risk level', () {
      for (final ward in MockDataService.wards) {
        final prediction = MockDataService.getRiskPrediction(ward.id);

        expect(prediction.compoundRiskScore, inInclusiveRange(0.0, 100.0));
        expect(
          prediction.riskLevel,
          RiskLevelExtension.fromScore(prediction.compoundRiskScore),
          reason: 'Score ${prediction.compoundRiskScore} did not map to ${prediction.riskLevel} for ward ${ward.id}',
        );
        expect(prediction.dataStatus, isNotEmpty);
        expect(prediction.featureContributions, isNotEmpty);
      }
    });

    test('a hotter, higher-demand scenario raises prototype risk', () async {
      final ward = MockDataService.wards.first;
      final result = await MLService.runScenarioSimulation(
        SimulationInput(
          wardId: ward.id,
          temperatureChange: 2.0,
          demandChange: 10.0,
          coolingAccessChange: -5.0,
        ),
      );

      expect(result.newRisk, inInclusiveRange(0.0, 100.0));
      expect(result.newRisk, greaterThan(result.originalRisk));
      expect(result.riskDelta, greaterThan(0.0));
      expect(result.newRiskLevel, RiskLevelExtension.fromScore(result.newRisk));
    });

    test('an extreme cooling intervention scenario lowers risk', () async {
      final ward = MockDataService.wards.first;
      final result = await MLService.runScenarioSimulation(
        SimulationInput(
          wardId: ward.id,
          temperatureChange: -3.0,
          demandChange: -20.0,
          coolingAccessChange: 20.0,
        ),
      );

      expect(result.newRisk, inInclusiveRange(0.0, 100.0));
      expect(result.newRisk, lessThan(result.originalRisk));
      expect(result.riskDelta, lessThan(0.0));
    });

    test('structured explainability fallback provides actionable, non-empty recommendations', () async {
      final ward = MockDataService.wards.first;
      final prediction = MockDataService.getRiskPrediction(ward.id);
      final explanation = await MLService.getRiskExplanationResult(ward.id, prediction);

      expect(explanation.summary, isNotEmpty);
      expect(explanation.riskInterpretation, isNotEmpty);
      expect(explanation.recommendedActions, isNotEmpty);
      expect(explanation.keyFactors, isNotEmpty);
      expect(explanation.dataQualityNote, contains('simulated'));
      expect(explanation.limitations, isNotEmpty);
    });
  });
}
