enum RiskLevel { LOW, MODERATE, HIGH, CRITICAL }

extension RiskLevelExtension on RiskLevel {
  String get name {
    switch (this) {
      case RiskLevel.LOW:
        return 'LOW';
      case RiskLevel.MODERATE:
        return 'MODERATE';
      case RiskLevel.HIGH:
        return 'HIGH';
      case RiskLevel.CRITICAL:
        return 'CRITICAL';
    }
  }

  static RiskLevel fromScore(double score) {
    if (score >= 70) return RiskLevel.CRITICAL;
    if (score >= 50) return RiskLevel.HIGH;
    if (score >= 30) return RiskLevel.MODERATE;
    return RiskLevel.LOW;
  }
}

class WeatherData {
  final String wardId;
  final double temperature;
  final double humidity;
  final double heatIndex;
  final double? wbgt;
  final String timestamp;
  final bool isReal;
  final double? feelsLike;
  final String? condition;
  final double? windSpeed;

  const WeatherData({
    required this.wardId,
    required this.temperature,
    required this.humidity,
    required this.heatIndex,
    this.wbgt,
    required this.timestamp,
    this.isReal = false,
    this.feelsLike,
    this.condition,
    this.windSpeed,
  });
}

class GridData {
  final String wardId;
  final double electricityDemand;
  final double gridStress;
  final double historicalOutageFreq;
  final String timestamp;

  const GridData({
    required this.wardId,
    required this.electricityDemand,
    required this.gridStress,
    required this.historicalOutageFreq,
    required this.timestamp,
  });
}

class VulnerabilityData {
  final String wardId;
  final double vulnerabilityScore;
  final double coolingAccess;
  final double elderlyRatio;
  final double incomeIndex;

  const VulnerabilityData({
    required this.wardId,
    required this.vulnerabilityScore,
    required this.coolingAccess,
    required this.elderlyRatio,
    required this.incomeIndex,
  });
}

class RiskPrediction {
  final String wardId;
  final double compoundRiskScore;
  final RiskLevel riskLevel;
  final double predicted30min;
  final double predicted60min;
  final String timestamp;

  const RiskPrediction({
    required this.wardId,
    required this.compoundRiskScore,
    required this.riskLevel,
    required this.predicted30min,
    required this.predicted60min,
    required this.timestamp,
  });
}

class RiskExplanation {
  final double heatStress;
  final double gridStress;
  final double vulnerability;
  final double coolingAccess;

  const RiskExplanation({
    required this.heatStress,
    required this.gridStress,
    required this.vulnerability,
    required this.coolingAccess,
  });
}

class FeatureContribution {
  final String feature;
  final String displayName;
  final double value;
  final String unit;
  final double importanceWeight;
  final double contributionScore;
  final String description;

  const FeatureContribution({
    required this.feature,
    required this.displayName,
    required this.value,
    required this.unit,
    required this.importanceWeight,
    required this.contributionScore,
    required this.description,
  });
}

class SimulationInput {
  final double temperatureChange;
  final double demandChange;
  final double coolingAccessChange;
  final String wardId;

  const SimulationInput({
    required this.temperatureChange,
    required this.demandChange,
    required this.coolingAccessChange,
    required this.wardId,
  });
}

class SimulationResult {
  final double originalRisk;
  final double newRisk;
  final double riskDelta;
  final RiskLevel newRiskLevel;
  final RiskExplanation explanation;

  const SimulationResult({
    required this.originalRisk,
    required this.newRisk,
    required this.riskDelta,
    required this.newRiskLevel,
    required this.explanation,
  });
}
