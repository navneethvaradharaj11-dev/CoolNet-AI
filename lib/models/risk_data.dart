enum RiskLevel {
  low,
  moderate,
  high,
  critical;

  String get name {
    switch (this) {
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.moderate:
        return 'MODERATE';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.critical:
        return 'CRITICAL';
    }
  }

  static RiskLevel fromScore(double score) {
    if (score >= 70.0) return RiskLevel.critical;
    if (score >= 50.0) return RiskLevel.high;
    if (score >= 30.0) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  // Backward-compatible constant aliases
  // ignore: constant_identifier_names
  static const RiskLevel LOW = RiskLevel.low;
  // ignore: constant_identifier_names
  static const RiskLevel MODERATE = RiskLevel.moderate;
  // ignore: constant_identifier_names
  static const RiskLevel HIGH = RiskLevel.high;
  // ignore: constant_identifier_names
  static const RiskLevel CRITICAL = RiskLevel.critical;
}

class RiskLevelExtension {
  static RiskLevel fromScore(double score) => RiskLevel.fromScore(score);
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
  final bool isModelInference;
  final String modelVersion;
  final String dataStatus; // 'real', 'simulated', 'estimated', 'demo_mode'
  final List<FeatureContribution> featureContributions;

  const RiskPrediction({
    required this.wardId,
    required this.compoundRiskScore,
    required this.riskLevel,
    required this.predicted30min,
    required this.predicted60min,
    required this.timestamp,
    this.isModelInference = false,
    this.modelVersion = '1.0.0 (Prototype)',
    this.dataStatus = 'simulated',
    this.featureContributions = const [],
  });
}

class KeyFactorItem {
  final String factor;
  final double contribution;
  final String explanation;

  const KeyFactorItem({
    required this.factor,
    required this.contribution,
    required this.explanation,
  });

  factory KeyFactorItem.fromJson(Map<String, dynamic> json) {
    return KeyFactorItem(
      factor: json['factor'] as String? ?? '',
      contribution: (json['contribution'] as num?)?.toDouble() ?? 0.0,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class ExplanationResult {
  final String summary;
  final String riskInterpretation;
  final List<KeyFactorItem> keyFactors;
  final List<String> recommendedActions;
  final String dataQualityNote;
  final List<String> limitations;
  final bool isLLMGenerated;

  const ExplanationResult({
    required this.summary,
    required this.riskInterpretation,
    required this.keyFactors,
    required this.recommendedActions,
    required this.dataQualityNote,
    required this.limitations,
    this.isLLMGenerated = false,
  });

  factory ExplanationResult.fromJson(Map<String, dynamic> json, {bool isLLM = true}) {
    return ExplanationResult(
      summary: json['summary'] as String? ?? '',
      riskInterpretation: json['risk_interpretation'] as String? ?? '',
      keyFactors: (json['key_factors'] as List? ?? [])
          .map((item) => KeyFactorItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      recommendedActions: (json['recommended_actions'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      dataQualityNote: json['data_quality_note'] as String? ?? '',
      limitations: (json['limitations'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      isLLMGenerated: isLLM,
    );
  }
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
