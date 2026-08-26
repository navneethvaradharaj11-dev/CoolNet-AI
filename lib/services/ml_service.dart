import '../models/risk_data.dart';
import 'mock_data_service.dart';

class MLService {
  static Future<RiskPrediction> predictWardRisk(String wardId) async {
    return MockDataService.getRiskPrediction(wardId);
  }

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

  static Future<SimulationResult> runScenarioSimulation(SimulationInput input) async {
    final baseline = MockDataService.getRiskPrediction(input.wardId);
    final weather = MockDataService.getWeatherData(input.wardId);
    final grid = MockDataService.getGridData(input.wardId);
    final vuln = MockDataService.getVulnerabilityData(input.wardId);

    final double newTemp = weather.temperature + input.temperatureChange;
    final double newHeatIndex = newTemp + (weather.humidity * 0.1);
    final double newDemand = (grid.electricityDemand + input.demandChange).clamp(0, 100);
    final double newGridStress = (newDemand * 0.85).clamp(0, 100);
    final double newCoolingAccess = (vuln.coolingAccess + input.coolingAccessChange).clamp(0, 100);
    final double newVulnScore = (vuln.vulnerabilityScore - input.coolingAccessChange * 0.5).clamp(0, 100);

    final double heatScore = (newHeatIndex - 30) * 3;
    final double newRiskScore = (heatScore * 0.4 + newGridStress * 0.3 + newVulnScore * 0.3).clamp(0, 100);

    final double originalRisk = baseline.compoundRiskScore;
    final double newRisk = double.parse(newRiskScore.toStringAsFixed(1));
    final double delta = double.parse((newRisk - originalRisk).toStringAsFixed(1));

    return SimulationResult(
      originalRisk: originalRisk,
      newRisk: newRisk,
      riskDelta: delta,
      newRiskLevel: RiskLevelExtension.fromScore(newRisk),
      explanation: RiskExplanation(
        heatStress: double.parse(heatScore.clamp(0, 100).toStringAsFixed(1)),
        gridStress: newGridStress,
        vulnerability: newVulnScore,
        coolingAccess: 100 - newCoolingAccess,
      ),
    );
  }
}
