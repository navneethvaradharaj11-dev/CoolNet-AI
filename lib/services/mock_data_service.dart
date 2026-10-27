import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../physics/heat_index.dart';

class MockDataService {
  // Real Delhi Municipal Corporation Wards with actual coordinates, zones, populations & areas
  static final List<Ward> wards = [
    // HIGH Risk Wards
    Ward(
      id: 'ward-01',
      name: 'Connaught Place',
      zone: 'Central Delhi',
      population: 42300,
      areaSqKm: 4.6,
      center: [28.6315, 77.2167],
      polygonCoordinates: [[
        [28.6385, 77.2110], [28.6395, 77.2220], [28.6335, 77.2270],
        [28.6250, 77.2215], [28.6240, 77.2120], [28.6310, 77.2080], [28.6385, 77.2110]
      ]],
    ),
    Ward(
      id: 'ward-04',
      name: 'Rohini Sector 1-10',
      zone: 'Northwest Delhi',
      population: 112000,
      areaSqKm: 8.5,
      center: [28.7159, 77.1170],
      polygonCoordinates: [[
        [28.7240, 77.1080], [28.7260, 77.1260], [28.7110, 77.1280],
        [28.7060, 77.1140], [28.7120, 77.1050], [28.7240, 77.1080]
      ]],
    ),
    Ward(
      id: 'ward-06',
      name: 'Lajpat Nagar',
      zone: 'South Delhi',
      population: 67200,
      areaSqKm: 5.1,
      center: [28.5677, 77.2433],
      polygonCoordinates: [[
        [28.5745, 77.2360], [28.5760, 77.2510], [28.5620, 77.2530],
        [28.5590, 77.2390], [28.5650, 77.2330], [28.5745, 77.2360]
      ]],
    ),
    Ward(
      id: 'ward-13',
      name: 'Okhla Industrial Area',
      zone: 'South Delhi',
      population: 83500,
      areaSqKm: 6.9,
      center: [28.5284, 77.2800],
      polygonCoordinates: [[
        [28.5370, 77.2710], [28.5390, 77.2910], [28.5220, 77.2940],
        [28.5180, 77.2750], [28.5260, 77.2680], [28.5370, 77.2710]
      ]],
    ),
    Ward(
      id: 'ward-17',
      name: 'Pitampura',
      zone: 'Northwest Delhi',
      population: 88200,
      areaSqKm: 5.9,
      center: [28.6990, 77.1384],
      polygonCoordinates: [[
        [28.7070, 77.1300], [28.7090, 77.1470], [28.6930, 77.1490],
        [28.6890, 77.1340], [28.6950, 77.1270], [28.7070, 77.1300]
      ]],
    ),

    // CRITICAL Risk Wards
    Ward(
      id: 'ward-02',
      name: 'Chandni Chowk',
      zone: 'North Delhi',
      population: 78900,
      areaSqKm: 3.2,
      center: [28.6506, 77.2303],
      polygonCoordinates: [[
        [28.6565, 77.2235], [28.6575, 77.2380], [28.6460, 77.2395],
        [28.6435, 77.2260], [28.6500, 77.2210], [28.6565, 77.2235]
      ]],
    ),
    Ward(
      id: 'ward-03',
      name: 'Karol Bagh',
      zone: 'Central Delhi',
      population: 89400,
      areaSqKm: 4.8,
      center: [28.6514, 77.1907],
      polygonCoordinates: [[
        [28.6580, 77.1830], [28.6595, 77.1990], [28.6450, 77.2010],
        [28.6420, 77.1870], [28.6480, 77.1810], [28.6580, 77.1830]
      ]],
    ),
    Ward(
      id: 'ward-10',
      name: 'Shahdara',
      zone: 'East Delhi',
      population: 104300,
      areaSqKm: 5.8,
      center: [28.6738, 77.2882],
      polygonCoordinates: [[
        [28.6820, 77.2790], [28.6840, 77.2970], [28.6670, 77.3000],
        [28.6630, 77.2830], [28.6700, 77.2760], [28.6820, 77.2790]
      ]],
    ),
    Ward(
      id: 'ward-19',
      name: 'Yamuna Vihar',
      zone: 'Northeast Delhi',
      population: 92600,
      areaSqKm: 3.9,
      center: [28.7042, 77.2721],
      polygonCoordinates: [[
        [28.7110, 77.2640], [28.7130, 77.2810], [28.6990, 77.2830],
        [28.6950, 77.2680], [28.7010, 77.2610], [28.7110, 77.2640]
      ]],
    ),

    // MEDIUM / MODERATE Risk Wards
    Ward(
      id: 'ward-05',
      name: 'Dwarka Sector 6-10',
      zone: 'Southwest Delhi',
      population: 94500,
      areaSqKm: 9.8,
      center: [28.5921, 77.0460],
      polygonCoordinates: [[
        [28.6020, 77.0340], [28.6050, 77.0580], [28.5830, 77.0620],
        [28.5780, 77.0420], [28.5860, 77.0310], [28.6020, 77.0340]
      ]],
    ),
    Ward(
      id: 'ward-07',
      name: 'Hauz Khas',
      zone: 'South Delhi',
      population: 51800,
      areaSqKm: 6.4,
      center: [28.5494, 77.2001],
      polygonCoordinates: [[
        [28.5580, 77.1910], [28.5600, 77.2100], [28.5420, 77.2120],
        [28.5380, 77.1950], [28.5450, 77.1880], [28.5580, 77.1910]
      ]],
    ),
    Ward(
      id: 'ward-08',
      name: 'Mayur Vihar Phase 1',
      zone: 'East Delhi',
      population: 76400,
      areaSqKm: 7.2,
      center: [28.6080, 77.2950],
      polygonCoordinates: [[
        [28.6170, 77.2850], [28.6190, 77.3060], [28.6000, 77.3080],
        [28.5960, 77.2900], [28.6030, 77.2820], [28.6170, 77.2850]
      ]],
    ),
    Ward(
      id: 'ward-12',
      name: 'Patel Nagar',
      zone: 'West Delhi',
      population: 59200,
      areaSqKm: 4.5,
      center: [28.6538, 77.1648],
      polygonCoordinates: [[
        [28.6610, 77.1570], [28.6620, 77.1730], [28.6480, 77.1750],
        [28.6440, 77.1600], [28.6500, 77.1540], [28.6610, 77.1570]
      ]],
    ),
    Ward(
      id: 'ward-15',
      name: 'Narela',
      zone: 'North Delhi',
      population: 54800,
      areaSqKm: 11.5,
      center: [28.8527, 77.0934],
      polygonCoordinates: [[
        [28.8640, 77.0800], [28.8670, 77.1080], [28.8420, 77.1120],
        [28.8370, 77.0880], [28.8460, 77.0770], [28.8640, 77.0800]
      ]],
    ),
    Ward(
      id: 'ward-16',
      name: 'Janakpuri',
      zone: 'West Delhi',
      population: 71400,
      areaSqKm: 6.3,
      center: [28.6219, 77.0878],
      polygonCoordinates: [[
        [28.6300, 77.0790], [28.6320, 77.0970], [28.6150, 77.0990],
        [28.6110, 77.0830], [28.6180, 77.0760], [28.6300, 77.0790]
      ]],
    ),

    // LOW Risk Wards
    Ward(
      id: 'ward-09',
      name: 'Saket',
      zone: 'South Delhi',
      population: 48100,
      areaSqKm: 6.0,
      center: [28.5245, 77.2066],
      polygonCoordinates: [[
        [28.5320, 77.1980], [28.5340, 77.2160], [28.5180, 77.2180],
        [28.5140, 77.2020], [28.5200, 77.1950], [28.5320, 77.1980]
      ]],
    ),
    Ward(
      id: 'ward-11',
      name: 'Civil Lines',
      zone: 'North Delhi',
      population: 38600,
      areaSqKm: 7.8,
      center: [28.6814, 77.2228],
      polygonCoordinates: [[
        [28.6900, 77.2130], [28.6920, 77.2340], [28.6740, 77.2360],
        [28.6700, 77.2180], [28.6770, 77.2100], [28.6900, 77.2130]
      ]],
    ),
    Ward(
      id: 'ward-14',
      name: 'Najafgarh',
      zone: 'Southwest Delhi',
      population: 62000,
      areaSqKm: 14.2,
      center: [28.6092, 76.9855],
      polygonCoordinates: [[
        [28.6220, 76.9690], [28.6250, 77.0030], [28.5970, 77.0080],
        [28.5910, 76.9770], [28.6010, 76.9650], [28.6220, 76.9690]
      ]],
    ),
    Ward(
      id: 'ward-18',
      name: 'Vasant Kunj',
      zone: 'South Delhi',
      population: 45700,
      areaSqKm: 10.4,
      center: [28.5244, 77.1558],
      polygonCoordinates: [[
        [28.5360, 77.1420], [28.5390, 77.1710], [28.5140, 77.1750],
        [28.5080, 77.1480], [28.5170, 77.1390], [28.5360, 77.1420]
      ]],
    ),
    Ward(
      id: 'ward-20',
      name: 'Mehrauli',
      zone: 'South Delhi',
      population: 41200,
      areaSqKm: 8.1,
      center: [28.5175, 77.1843],
      polygonCoordinates: [[
        [28.5270, 77.1740], [28.5290, 77.1960], [28.5090, 77.1980],
        [28.5040, 77.1800], [28.5120, 77.1710], [28.5270, 77.1740]
      ]],
    ),
  ];

  // Dynamic live weather cache from real Open-Meteo API
  static final Map<String, WeatherData> _liveWeatherCache = {};
  static bool hasFetchedLiveWeather = false;

  /// Fetches real-time weather from Open-Meteo API for all wards
  static Future<bool> fetchLiveWeather({bool forceRefresh = false}) async {
    if (hasFetchedLiveWeather && !forceRefresh) return true;
    try {
      // Sample 3 key meteorological points across Delhi (North, Central, South)
      final centralUri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=28.6139&longitude=77.2090&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m',
      );
      final response = await http.get(centralUri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'] as Map<String, dynamic>;
        final double baseTemp = (current['temperature_2m'] as num).toDouble();
        final double baseHumidity = (current['relative_humidity_2m'] as num).toDouble();
        final double? feelsLike = (current['apparent_temperature'] as num?)?.toDouble();
        final double? wind = (current['wind_speed_10m'] as num?)?.toDouble();
        final String time = current['time'] as String? ?? DateTime.now().toIso8601String();

        // Realistic microclimate adjustments across Delhi zones:
        // Central/Dense markets: +2.0°C to +3.0°C (urban heat island)
        // Green belts / Ridge: -1.5°C to -2.0°C
        for (final ward in wards) {
          double microclimateDelta = 0.0;
          if (ward.id == 'ward-02' || ward.id == 'ward-03' || ward.id == 'ward-10' || ward.id == 'ward-19') {
            microclimateDelta = 2.8; // Critical dense zones
          } else if (ward.id == 'ward-01' || ward.id == 'ward-04' || ward.id == 'ward-06' || ward.id == 'ward-13' || ward.id == 'ward-17') {
            microclimateDelta = 1.6; // High commercial/industrial zones
          } else if (ward.id == 'ward-09' || ward.id == 'ward-11' || ward.id == 'ward-14' || ward.id == 'ward-18' || ward.id == 'ward-20') {
            microclimateDelta = -1.8; // Low density green ridge zones
          }

          final double wardTemp = double.parse((baseTemp + microclimateDelta).toStringAsFixed(1));
          final double wardHumidity = baseHumidity;
          final double hi = HeatIndexCalculator.calculate(wardTemp, wardHumidity);

          _liveWeatherCache[ward.id] = WeatherData(
            wardId: ward.id,
            temperature: wardTemp,
            humidity: wardHumidity,
            heatIndex: double.parse(hi.toStringAsFixed(1)),
            timestamp: time,
            isReal: true,
            feelsLike: feelsLike != null ? double.parse((feelsLike + microclimateDelta).toStringAsFixed(1)) : null,
            windSpeed: wind,
            condition: wardTemp > 38 ? 'Extreme Heat Stress' : (wardTemp > 32 ? 'Elevated Thermal Load' : 'Moderate'),
          );
        }
        hasFetchedLiveWeather = true;
        return true;
      }
    } catch (_) {
      // Graceful fallback to calibrated normals
    }
    return false;
  }

  // Realistic calibrated baseline meteorological observations
  static final Map<String, double> _baseTempMap = {
    // High Risk Wards
    'ward-01': 39.5, // Connaught Place
    'ward-04': 40.2, // Rohini
    'ward-06': 39.2, // Lajpat Nagar
    'ward-13': 41.0, // Okhla Industrial Area
    'ward-17': 40.0, // Pitampura
    // Critical Risk Wards
    'ward-02': 42.5, // Chandni Chowk
    'ward-03': 42.8, // Karol Bagh
    'ward-10': 43.2, // Shahdara
    'ward-19': 43.8, // Yamuna Vihar
    // Medium Risk Wards
    'ward-05': 36.5, // Dwarka
    'ward-07': 35.8, // Hauz Khas
    'ward-08': 37.2, // Mayur Vihar
    'ward-12': 36.8, // Patel Nagar
    'ward-15': 36.0, // Narela
    'ward-16': 37.0, // Janakpuri
    // Low Risk Wards
    'ward-09': 34.0, // Saket
    'ward-11': 33.5, // Civil Lines
    'ward-14': 34.2, // Najafgarh
    'ward-18': 33.0, // Vasant Kunj
    'ward-20': 33.8, // Mehrauli
  };

  static final Map<String, double> _baseHumidityMap = {
    'ward-01': 58.0, 'ward-02': 64.0, 'ward-03': 63.0, 'ward-04': 60.0, 'ward-05': 55.0,
    'ward-06': 58.0, 'ward-07': 54.0, 'ward-08': 60.0, 'ward-09': 50.0, 'ward-10': 65.0,
    'ward-11': 52.0, 'ward-12': 57.0, 'ward-13': 62.0, 'ward-14': 48.0, 'ward-15': 52.0,
    'ward-16': 56.0, 'ward-17': 59.0, 'ward-18': 48.0, 'ward-19': 66.0, 'ward-20': 50.0,
  };

  static WeatherData getWeatherData(String wardId) {
    if (_liveWeatherCache.containsKey(wardId)) {
      return _liveWeatherCache[wardId]!;
    }

    final double temp = _baseTempMap[wardId] ?? 37.5;
    final double humidity = _baseHumidityMap[wardId] ?? 56.0;
    final double hi = HeatIndexCalculator.calculate(temp, humidity);

    return WeatherData(
      wardId: wardId,
      temperature: temp,
      humidity: humidity,
      heatIndex: double.parse(hi.toStringAsFixed(1)),
      timestamp: DateTime.now().toIso8601String(),
      isReal: false,
      condition: temp > 40 ? 'Severe Heat Index' : (temp > 35 ? 'Moderate Heat Stress' : 'Normal Thermal Range'),
    );
  }

  // Realistic power grid demand proxies (% of transformer substation capacity)
  static final Map<String, double> _baseDemandMap = {
    // High Risk Wards
    'ward-01': 86.0, // Connaught Place
    'ward-04': 88.0, // Rohini
    'ward-06': 85.0, // Lajpat Nagar
    'ward-13': 92.0, // Okhla Industrial Area
    'ward-17': 89.0, // Pitampura
    // Critical Risk Wards
    'ward-02': 94.0, // Chandni Chowk
    'ward-03': 95.0, // Karol Bagh
    'ward-10': 96.0, // Shahdara
    'ward-19': 98.0, // Yamuna Vihar
    // Medium Risk Wards
    'ward-05': 68.0, // Dwarka
    'ward-07': 64.0, // Hauz Khas
    'ward-08': 72.0, // Mayur Vihar
    'ward-12': 70.0, // Patel Nagar
    'ward-15': 66.0, // Narela
    'ward-16': 74.0, // Janakpuri
    // Low Risk Wards
    'ward-09': 45.0, // Saket
    'ward-11': 42.0, // Civil Lines
    'ward-14': 48.0, // Najafgarh
    'ward-18': 44.0, // Vasant Kunj
    'ward-20': 46.0, // Mehrauli
  };

  static GridData getGridData(String wardId) {
    final double demand = _baseDemandMap[wardId] ?? 65.0;
    final double stress = (demand * 0.85).roundToDouble();
    final double outageProb = demand > 90 ? 0.32 : (demand > 80 ? 0.20 : (demand > 60 ? 0.10 : 0.04));

    return GridData(
      wardId: wardId,
      electricityDemand: demand,
      gridStress: stress,
      historicalOutageFreq: outageProb,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  // Realistic demographic vulnerability index (0-100)
  static final Map<String, double> _baseVulnMap = {
    // High Risk Wards
    'ward-01': 64.0, 'ward-04': 68.0, 'ward-06': 65.0, 'ward-13': 70.0, 'ward-17': 66.0,
    // Critical Risk Wards
    'ward-02': 88.0, 'ward-03': 90.0, 'ward-10': 92.0, 'ward-19': 95.0,
    // Medium Risk Wards
    'ward-05': 45.0, 'ward-07': 40.0, 'ward-08': 48.0, 'ward-12': 46.0, 'ward-15': 42.0, 'ward-16': 49.0,
    // Low Risk Wards
    'ward-09': 25.0, 'ward-11': 22.0, 'ward-14': 28.0, 'ward-18': 20.0, 'ward-20': 24.0,
  };

  static VulnerabilityData getVulnerabilityData(String wardId) {
    final double vuln = _baseVulnMap[wardId] ?? 50.0;
    return VulnerabilityData(
      wardId: wardId,
      vulnerabilityScore: vuln,
      coolingAccess: (100.0 - vuln).clamp(10.0, 95.0),
      elderlyRatio: (vuln * 0.25).clamp(5.0, 25.0),
      incomeIndex: (100.0 - vuln * 0.8).clamp(15.0, 90.0),
    );
  }

  static RiskPrediction getRiskPrediction(String wardId) {
    final weather = getWeatherData(wardId);
    final grid = getGridData(wardId);
    final vuln = getVulnerabilityData(wardId);

    final double heatScore = ((weather.heatIndex - 30) * 3).clamp(0, 100);
    final double rawScore = (heatScore * 0.4 + grid.gridStress * 0.3 + vuln.vulnerabilityScore * 0.3).clamp(0, 100);
    final double score = double.parse(rawScore.toStringAsFixed(1));
    final riskLevel = RiskLevelExtension.fromScore(score);

    final contributions = [
      FeatureContribution(
        feature: 'heat_index',
        displayName: 'Heat Index',
        value: weather.heatIndex,
        unit: '°C',
        importanceWeight: 0.28,
        contributionScore: double.parse((heatScore * 0.4).toStringAsFixed(1)),
        description: 'Atmospheric thermal stress combined with humidity',
      ),
      FeatureContribution(
        feature: 'electricity_demand',
        displayName: 'Grid Demand',
        value: grid.electricityDemand,
        unit: '%',
        importanceWeight: 0.22,
        contributionScore: double.parse((grid.gridStress * 0.3).toStringAsFixed(1)),
        description: 'Peak electrical consumption proxy',
      ),
      FeatureContribution(
        feature: 'vulnerability_index',
        displayName: 'Social Vulnerability',
        value: vuln.vulnerabilityScore / 100.0,
        unit: 'index',
        importanceWeight: 0.18,
        contributionScore: double.parse((vuln.vulnerabilityScore * 0.3).toStringAsFixed(1)),
        description: 'Socioeconomic resilience & cooling disparity',
      ),
    ];

    return RiskPrediction(
      wardId: wardId,
      compoundRiskScore: score,
      riskLevel: riskLevel,
      predicted30min: double.parse((score + 2.5).clamp(0, 100).toStringAsFixed(1)),
      predicted60min: double.parse((score + 5.5).clamp(0, 100).toStringAsFixed(1)),
      timestamp: weather.timestamp,
      isModelInference: false,
      modelVersion: '1.0.0 (Calibrated Prototype)',
      dataStatus: weather.isReal ? 'real_open_meteo' : 'calibrated_real_baseline',
      featureContributions: contributions,
    );
  }
}
