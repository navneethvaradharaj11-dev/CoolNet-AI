import '../models/ward.dart';
import '../models/risk_data.dart';

class MockDataService {
  static final List<Ward> wards = [
    Ward(id: 'ward-01', name: 'Ward 1', population: 45200, areaSqKm: 4.2, center: [28.6315, 77.2220], polygonCoordinates: [[ [28.634,77.214],[28.636,77.224],[28.633,77.230],[28.629,77.226],[28.628,77.218],[28.634,77.214] ]]),
    Ward(id: 'ward-02', name: 'Ward 2', population: 38700, areaSqKm: 3.8, center: [28.6395, 77.2310], polygonCoordinates: [[ [28.636,77.224],[28.642,77.226],[28.644,77.234],[28.640,77.238],[28.635,77.234],[28.636,77.224] ]]),
    Ward(id: 'ward-03', name: 'Ward 3', population: 52100, areaSqKm: 5.1, center: [28.6275, 77.2400], polygonCoordinates: [[ [28.631,77.234],[28.635,77.234],[28.633,77.246],[28.628,77.246],[28.625,77.240],[28.631,77.234] ]]),
    Ward(id: 'ward-04', name: 'Ward 4', population: 29300, areaSqKm: 2.9, center: [28.6455, 77.2440], polygonCoordinates: [[ [28.643,77.240],[28.649,77.240],[28.650,77.248],[28.646,77.252],[28.642,77.248],[28.643,77.240] ]]),
    Ward(id: 'ward-05', name: 'Ward 5', population: 61400, areaSqKm: 6.2, center: [28.6215, 77.2170], polygonCoordinates: [[ [28.625,77.210],[28.628,77.210],[28.628,77.218],[28.625,77.224],[28.619,77.222],[28.618,77.214],[28.625,77.210] ]]),
    Ward(id: 'ward-06', name: 'Ward 6', population: 33800, areaSqKm: 3.3, center: [28.6335, 77.2520], polygonCoordinates: [[ [28.631,77.248],[28.637,77.248],[28.638,77.256],[28.633,77.260],[28.629,77.256],[28.631,77.248] ]]),
    Ward(id: 'ward-07', name: 'Ward 7', population: 47600, areaSqKm: 4.7, center: [28.6175, 77.2310], polygonCoordinates: [[ [28.621,77.224],[28.625,77.224],[28.625,77.238],[28.621,77.242],[28.616,77.238],[28.615,77.228],[28.621,77.224] ]]),
    Ward(id: 'ward-08', name: 'Ward 8', population: 41200, areaSqKm: 4.0, center: [28.6415, 77.2110], polygonCoordinates: [[ [28.638,77.206],[28.645,77.206],[28.646,77.216],[28.642,77.220],[28.637,77.216],[28.638,77.206] ]]),
    Ward(id: 'ward-09', name: 'Ward 9', population: 55800, areaSqKm: 5.5, center: [28.6135, 77.2480], polygonCoordinates: [[ [28.617,77.242],[28.621,77.242],[28.620,77.254],[28.616,77.258],[28.611,77.258],[28.610,77.246],[28.617,77.242] ]]),
    Ward(id: 'ward-10', name: 'Ward 10', population: 36900, areaSqKm: 3.6, center: [28.6475, 77.2260], polygonCoordinates: [[ [28.645,77.220],[28.651,77.220],[28.652,77.232],[28.648,77.236],[28.644,77.232],[28.645,77.220] ]]),
    Ward(id: 'ward-11', name: 'Ward 11', population: 43100, areaSqKm: 4.3, center: [28.6255, 77.2060], polygonCoordinates: [[ [28.629,77.200],[28.634,77.200],[28.634,77.210],[28.628,77.214],[28.623,77.210],[28.622,77.204],[28.629,77.200] ]]),
    Ward(id: 'ward-12', name: 'Ward 12', population: 48900, areaSqKm: 4.8, center: [28.6375, 77.2600], polygonCoordinates: [[ [28.635,77.256],[28.641,77.256],[28.642,77.264],[28.638,77.268],[28.633,77.264],[28.635,77.256] ]]),
    Ward(id: 'ward-13', name: 'Ward 13', population: 34600, areaSqKm: 3.4, center: [28.6095, 77.2220], polygonCoordinates: [[ [28.613,77.216],[28.617,77.216],[28.616,77.228],[28.612,77.230],[28.607,77.226],[28.607,77.220],[28.613,77.216] ]]),
    Ward(id: 'ward-14', name: 'Ward 14', population: 52300, areaSqKm: 5.2, center: [28.6495, 77.2520], polygonCoordinates: [[ [28.647,77.246],[28.653,77.246],[28.654,77.258],[28.650,77.262],[28.646,77.258],[28.647,77.246] ]]),
    Ward(id: 'ward-15', name: 'Ward 15', population: 39400, areaSqKm: 3.9, center: [28.6215, 77.2620], polygonCoordinates: [[ [28.625,77.256],[28.629,77.256],[28.628,77.268],[28.624,77.272],[28.619,77.268],[28.618,77.260],[28.625,77.256] ]]),
    Ward(id: 'ward-16', name: 'Ward 16', population: 44700, areaSqKm: 4.4, center: [28.6355, 77.1990], polygonCoordinates: [[ [28.632,77.194],[28.639,77.194],[28.640,77.204],[28.636,77.208],[28.631,77.204],[28.632,77.194] ]]),
    Ward(id: 'ward-17', name: 'Ward 17', population: 67800, areaSqKm: 6.8, center: [28.6175, 77.2080], polygonCoordinates: [[ [28.621,77.200],[28.625,77.200],[28.623,77.214],[28.619,77.216],[28.614,77.214],[28.613,77.204],[28.621,77.200] ]]),
    Ward(id: 'ward-18', name: 'Ward 18', population: 31500, areaSqKm: 3.1, center: [28.6435, 77.2680], polygonCoordinates: [[ [28.641,77.264],[28.647,77.264],[28.648,77.274],[28.644,77.278],[28.639,77.274],[28.641,77.264] ]]),
    Ward(id: 'ward-19', name: 'Ward 19', population: 58200, areaSqKm: 5.7, center: [28.6075, 77.2380], polygonCoordinates: [[ [28.611,77.230],[28.616,77.230],[28.615,77.246],[28.611,77.250],[28.605,77.246],[28.604,77.236],[28.611,77.230] ]]),
    Ward(id: 'ward-20', name: 'Ward 20', population: 40100, areaSqKm: 4.0, center: [28.6515, 77.2380], polygonCoordinates: [[ [28.649,77.232],[28.655,77.232],[28.656,77.244],[28.652,77.248],[28.648,77.244],[28.649,77.232] ]]),
  ];

  static WeatherData getWeatherData(String wardId) {
    final Map<String, double> tempMap = {
      'ward-01': 38.2, 'ward-02': 39.5, 'ward-03': 37.8, 'ward-04': 36.5, 'ward-05': 40.1,
      'ward-06': 37.2, 'ward-07': 41.3, 'ward-08': 38.8, 'ward-09': 42.5, 'ward-10': 36.8,
      'ward-11': 39.2, 'ward-12': 37.5, 'ward-13': 40.8, 'ward-14': 35.9, 'ward-15': 38.5,
      'ward-16': 37.0, 'ward-17': 43.0, 'ward-18': 36.2, 'ward-19': 41.8, 'ward-20': 37.8,
    };
    final double temp = tempMap[wardId] ?? 38.0;
    final double humidity = 60.0;
    final double hi = temp + (humidity * 0.1);
    return WeatherData(
      wardId: wardId,
      temperature: temp,
      humidity: humidity,
      heatIndex: double.parse(hi.toStringAsFixed(1)),
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  static GridData getGridData(String wardId) {
    final Map<String, double> demandMap = {
      'ward-01': 78.0, 'ward-02': 82.0, 'ward-03': 85.0, 'ward-04': 65.0, 'ward-05': 88.0,
      'ward-06': 72.0, 'ward-07': 91.0, 'ward-08': 76.0, 'ward-09': 94.0, 'ward-10': 68.0,
      'ward-11': 80.0, 'ward-12': 74.0, 'ward-13': 89.0, 'ward-14': 62.0, 'ward-15': 83.0,
      'ward-16': 71.0, 'ward-17': 96.0, 'ward-18': 66.0, 'ward-19': 92.0, 'ward-20': 79.0,
    };
    final double demand = demandMap[wardId] ?? 75.0;
    return GridData(
      wardId: wardId,
      electricityDemand: demand,
      gridStress: (demand * 0.85).roundToDouble(),
      historicalOutageFreq: 0.15,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  static VulnerabilityData getVulnerabilityData(String wardId) {
    return VulnerabilityData(
      wardId: wardId,
      vulnerabilityScore: 55.0,
      coolingAccess: 50.0,
      elderlyRatio: 15.0,
      incomeIndex: 45.0,
    );
  }

  static RiskPrediction getRiskPrediction(String wardId) {
    final weather = getWeatherData(wardId);
    final grid = getGridData(wardId);
    final vuln = getVulnerabilityData(wardId);

    final double heatScore = (weather.heatIndex - 30) * 3;
    final double score = (heatScore * 0.4 + grid.gridStress * 0.3 + vuln.vulnerabilityScore * 0.3).clamp(0, 100);
    return RiskPrediction(
      wardId: wardId,
      compoundRiskScore: double.parse(score.toStringAsFixed(1)),
      riskLevel: RiskLevelExtension.fromScore(score),
      predicted30min: double.parse((score + 3).clamp(0, 100).toStringAsFixed(1)),
      predicted60min: double.parse((score + 7).clamp(0, 100).toStringAsFixed(1)),
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}
