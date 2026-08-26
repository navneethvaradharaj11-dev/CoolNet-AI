class Ward {
  final String id;
  final String name;
  final int population;
  final double areaSqKm;
  final List<double> center; // [latitude, longitude]
  final List<List<List<double>>> polygonCoordinates; // [[[lat, lng], ...]]

  const Ward({
    required this.id,
    required this.name,
    required this.population,
    required this.areaSqKm,
    required this.center,
    required this.polygonCoordinates,
  });

  int get populationDensity => areaSqKm > 0 ? (population / areaSqKm).round() : 0;

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['id'] as String,
      name: json['name'] as String,
      population: json['population'] as int,
      areaSqKm: (json['areaSqKm'] as num).toDouble(),
      center: (json['center'] as List).map((e) => (e as num).toDouble()).toList(),
      polygonCoordinates: (json['polygonCoordinates'] as List)
          .map((ring) => (ring as List)
              .map((pt) => (pt as List).map((c) => (c as num).toDouble()).toList())
              .toList())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'population': population,
        'areaSqKm': areaSqKm,
        'center': center,
        'polygonCoordinates': polygonCoordinates,
      };
}

class WardDefinition {
  final String wardId;
  final String wardName;
  final String zone;
  final int population;
  final double areaSqKm;
  final int populationDensity;
  final double baselineVulnerabilityIndex;
  final List<double> coordinates; // [lng, lat]
  final Map<String, int> criticalFacilities;

  const WardDefinition({
    required this.wardId,
    required this.wardName,
    required this.zone,
    required this.population,
    required this.areaSqKm,
    required this.populationDensity,
    required this.baselineVulnerabilityIndex,
    required this.coordinates,
    required this.criticalFacilities,
  });
}
