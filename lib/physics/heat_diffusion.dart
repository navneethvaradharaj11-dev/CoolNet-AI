import 'dart:math';

class WardDiffusionInput {
  final String id;
  final List<double> centroid; // [lat, lng]
  final double heatIndex;
  final double populationDensity;

  const WardDiffusionInput({
    required this.id,
    required this.centroid,
    required this.heatIndex,
    required this.populationDensity,
  });
}

class HeatDiffusionEngine {
  /// Distance in kilometers between two lat/lng coordinates (Haversine formula)
  static double calculateDistanceKm(List<double> c1, List<double> c2) {
    final double lat1 = c1[0];
    final double lon1 = c1[1];
    final double lat2 = c2[0];
    final double lon2 = c2[1];

    const double R = 6371.0;
    final double dLat = (lat2 - lat1) * pi / 180.0;
    final double dLon = (lon2 - lon1) * pi / 180.0;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  /// Calculates discrete spatial heat diffusion bleed between adjacent wards.
  static Map<String, double> applyHeatDiffusion(List<WardDiffusionInput> wards, {double k = 0.20}) {
    if (wards.length <= 1) {
      final Map<String, double> fallback = {};
      for (var w in wards) {
        fallback[w.id] = w.heatIndex;
      }
      return fallback;
    }

    final double totalDensity = wards.fold(0.0, (sum, w) => sum + w.populationDensity);
    final double avgDensity = totalDensity / wards.length;

    final Map<String, double> result = {};

    for (int i = 0; i < wards.length; i++) {
      final current = wards[i];
      double totalWeight = 0.0;
      double weightedNeighborSum = 0.0;

      for (int j = 0; j < wards.length; j++) {
        if (i == j) continue;
        final neighbor = wards[j];
        final double dist = max(0.05, calculateDistanceKm(current.centroid, neighbor.centroid));
        final double weight = 1.0 / dist;
        final double densityFactor = avgDensity > 0 ? (neighbor.populationDensity / avgDensity) : 1.0;

        weightedNeighborSum += (neighbor.heatIndex * densityFactor) * weight;
        totalWeight += weight;
      }

      final double weightedAvg = totalWeight > 0 ? (weightedNeighborSum / totalWeight) : current.heatIndex;
      final double effective = current.heatIndex * (1 - k) + k * weightedAvg;
      result[current.id] = double.parse(effective.toStringAsFixed(1));
    }

    return result;
  }
}
