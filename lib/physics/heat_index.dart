import 'dart:math';

/// Thermodynamic Heat Index Calculation Engine (Dart)
/// Implements the NOAA National Weather Service (NWS) Rothfusz regression algorithm.
class HeatIndexCalculator {
  /// Calculates Heat Index in Celsius given temperature (°C) and relative humidity (%)
  static double calculate(double tempC, double humidityPct) {
    // Convert Celsius to Fahrenheit for NWS regression
    final double T = (tempC * 9 / 5) + 32;
    final double RH = humidityPct;

    // Simple Heat Index formula fallback for cool/moderate conditions
    final double simpleHI = 0.5 * (T + 61.0 + ((T - 68.0) * 1.2) + (RH * 0.094));
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
        (c2 * T) +
        (c3 * RH) +
        (c4 * T * RH) +
        (c5 * T * T) +
        (c6 * RH * RH) +
        (c7 * T * T * RH) +
        (c8 * T * RH * RH) +
        (c9 * T * T * RH * RH);

    // Apply boundary adjustments
    if (RH < 13 && T >= 80 && T <= 112) {
      final double adj = ((13 - RH) / 4) * sqrt((17 - (T - 95).abs()) / 17);
      hi -= adj;
    } else if (RH > 85 && T >= 80 && T <= 87) {
      final double adj = ((RH - 85) / 10) * ((87 - T) / 5);
      hi += adj;
    }

    final double celsius = (hi - 32) * 5 / 9;
    return double.parse(celsius.toStringAsFixed(1));
  }
}
