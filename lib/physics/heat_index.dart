import 'dart:math';

/// Thermodynamic Heat Index Calculation Engine (Dart)
/// Implements the NOAA National Weather Service (NWS) Rothfusz regression algorithm.
class HeatIndexCalculator {
  /// Calculates Heat Index in Celsius given temperature (°C) and relative humidity (%)
  static double calculate(double tempC, double humidityPct) {
    // Convert Celsius to Fahrenheit for NWS regression
    final double t = (tempC * 9 / 5) + 32;
    final double rh = humidityPct.clamp(0.0, 100.0);

    // Simple Heat Index formula fallback for cool/moderate conditions
    final double simpleHI = 0.5 * (t + 61.0 + ((t - 68.0) * 1.2) + (rh * 0.094));
    if (simpleHI < 80) {
      final celsius = (simpleHI - 32) * 5 / 9;
      return double.parse(celsius.toStringAsFixed(1));
    }

    // Full NWS Rothfusz regression coefficients
    const double c1 = -42.379;
    const double c2 = 2.04901523;
    const double c3 = 10.14333127;
    const double c4 = -0.22475541;
    const double c5 = -0.00683783;
    const double c6 = -0.05481717;
    const double c7 = 0.00122874;
    const double c8 = 0.00085282;
    const double c9 = -0.00000199;

    double hi = c1 +
        (c2 * t) +
        (c3 * rh) +
        (c4 * t * rh) +
        (c5 * t * t) +
        (c6 * rh * rh) +
        (c7 * t * t * rh) +
        (c8 * t * rh * rh) +
        (c9 * t * t * rh * rh);

    // Apply boundary adjustments
    if (rh < 13 && t >= 80 && t <= 112) {
      final double adj = ((13 - rh) / 4) * sqrt((17 - (t - 95).abs()) / 17);
      hi -= adj;
    } else if (rh > 85 && t >= 80 && t <= 87) {
      final double adj = ((rh - 85) / 10) * ((87 - t) / 5);
      hi += adj;
    }

    final double celsius = (hi - 32) * 5 / 9;
    return double.parse(celsius.toStringAsFixed(1));
  }
}
