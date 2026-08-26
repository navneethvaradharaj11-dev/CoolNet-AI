import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressDetails {
  final String? road;
  final String? suburb;
  final String? city;
  final String? state;
  final String? country;
  final String? displayName;

  const AddressDetails({
    this.road,
    this.suburb,
    this.city,
    this.state,
    this.country,
    this.displayName,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json, String displayName) {
    final addr = json['address'] as Map<String, dynamic>? ?? {};
    return AddressDetails(
      road: addr['road'] as String? ?? addr['pedestrian'] as String?,
      suburb: addr['suburb'] as String? ?? addr['neighbourhood'] as String?,
      city: addr['city'] as String? ?? addr['town'] as String? ?? addr['village'] as String?,
      state: addr['state'] as String?,
      country: addr['country'] as String?,
      displayName: displayName,
    );
  }
}

class GeocodingSearchResult {
  final double lat;
  final double lng;
  final AddressDetails address;

  const GeocodingSearchResult({
    required this.lat,
    required this.lng,
    required this.address,
  });
}

class GeocodingService {
  static const String userAgent = 'CoolNet-AI-Flutter/1.0';

  static Future<AddressDetails?> reverseGeocode(double lat, double lng) async {
    try {
      final Uri uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1');
      final response = await http.get(uri, headers: {'User-Agent': userAgent});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AddressDetails.fromJson(data, data['display_name'] as String? ?? '');
      }
    } catch (e) {
      // Graceful fallback
    }
    return null;
  }

  static Future<List<GeocodingSearchResult>> searchLocation(String query) async {
    if (query.trim().length < 3) return [];
    try {
      final Uri uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1');
      final response = await http.get(uri, headers: {'User-Agent': userAgent});
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body) as List;
        return list.map((item) {
          final map = item as Map<String, dynamic>;
          return GeocodingSearchResult(
            lat: double.parse(map['lat'].toString()),
            lng: double.parse(map['lon'].toString()),
            address: AddressDetails.fromJson(map, map['display_name'] as String? ?? ''),
          );
        }).toList();
      }
    } catch (e) {
      // Graceful fallback
    }
    return [];
  }
}
