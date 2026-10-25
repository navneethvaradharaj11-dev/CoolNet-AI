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
  });

  group('Prototype ward risk scores', () {
    test('risk-level thresholds are consistent at each boundary', () {
      expect(RiskLevelExtension.fromScore(29.9), RiskLevel.LOW);
      expect(RiskLevelExtension.fromScore(30.0), RiskLevel.MODERATE);
      expect(RiskLevelExtension.fromScore(50.0), RiskLevel.HIGH);
      expect(RiskLevelExtension.fromScore(70.0), RiskLevel.CRITICAL);
    });

    test('all sample ward scores remain on the documented 0-100 scale', () {
      for (final ward in MockDataService.wards) {
        final prediction = MockDataService.getRiskPrediction(ward.id);

        expect(prediction.compoundRiskScore, inInclusiveRange(0.0, 100.0));
        expect(
          prediction.riskLevel,
          RiskLevelExtension.fromScore(prediction.compoundRiskScore),
        );
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
    });
  });
}
