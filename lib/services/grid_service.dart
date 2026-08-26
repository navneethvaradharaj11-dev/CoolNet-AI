import 'dart:math';

class GeospatialGridCell {
  final String id;
  final List<double> center; // [lat, lng]
  final List<List<double>> bounds; // [[south, west], [north, east]]
  final double north;
  final double south;
  final double east;
  final double west;
  final double areaSqKm;

  const GeospatialGridCell({
    required this.id,
    required this.center,
    required this.bounds,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.areaSqKm,
  });
}

class GridService {
  static String getGridId(double lat, double lng, {double spacing = 0.01}) {
    final double south = (lat / spacing).floor() * spacing;
    final double west = (lng / spacing).floor() * spacing;
    final double centerLat = south + spacing / 2;
    final double centerLng = west + spacing / 2;

    final int latInt = centerLat.abs().floor();
    final int lngInt = centerLng.abs().floor();
    final int latFrac = (((centerLat.abs() - latInt) * 1000).round()).floor();

    return 'GRID-${latInt.toString().padLeft(2, '0')}-${lngInt.toString().padLeft(2, '0')}-${latFrac.toString().padLeft(3, '0')}';
  }

  static GeospatialGridCell getGridCellForCoordinate(double lat, double lng, {double spacing = 0.01}) {
    final double south = (lat / spacing).floor() * spacing;
    final double west = (lng / spacing).floor() * spacing;
    final double north = south + spacing;
    final double east = west + spacing;

    final double centerLat = south + spacing / 2;
    final double centerLng = west + spacing / 2;

    final double latDist = spacing * 111.32;
    final double lngDist = spacing * 111.32 * cos(centerLat * pi / 180.0);
    final double areaSqKm = double.parse((latDist * lngDist).toStringAsFixed(4));

    return GeospatialGridCell(
      id: getGridId(lat, lng, spacing: spacing),
      center: [double.parse(centerLat.toStringAsFixed(6)), double.parse(centerLng.toStringAsFixed(6))],
      bounds: [
        [double.parse(south.toStringAsFixed(6)), double.parse(west.toStringAsFixed(6))],
        [double.parse(north.toStringAsFixed(6)), double.parse(east.toStringAsFixed(6))]
      ],
      north: double.parse(north.toStringAsFixed(6)),
      south: double.parse(south.toStringAsFixed(6)),
      east: double.parse(east.toStringAsFixed(6)),
      west: double.parse(west.toStringAsFixed(6)),
      areaSqKm: areaSqKm,
    );
  }
}
