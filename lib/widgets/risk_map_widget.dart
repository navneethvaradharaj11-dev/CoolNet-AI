import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/mock_data_service.dart';

class RiskMapWidget extends StatelessWidget {
  final List<Ward> wards;
  final Ward? selectedWard;
  final ValueChanged<Ward> onSelectWard;

  const RiskMapWidget({
    super.key,
    required this.wards,
    required this.selectedWard,
    required this.onSelectWard,
  });

  static const String cartoApiKey = String.fromEnvironment('CARTO_API_KEY', defaultValue: '');

  @override
  Widget build(BuildContext context) {
    final centerLat = selectedWard != null ? selectedWard!.center[0] : 28.6315;
    final centerLng = selectedWard != null ? selectedWard!.center[1] : 77.2220;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 12.5,
      ),
      children: [
        TileLayer(
          urlTemplate: cartoApiKey.isNotEmpty
              ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png?key=$cartoApiKey'
              : 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
          subdomains: cartoApiKey.isNotEmpty ? const ['a', 'b', 'c', 'd'] : const [],
          userAgentPackageName: 'com.coolnetai.app',
        ),
        PolygonLayer(
          polygons: wards.map((w) {
            final isSelected = selectedWard?.id == w.id;
            final risk = MockDataService.getRiskPrediction(w.id);

            Color fillColor;
            switch (risk.riskLevel) {
              case RiskLevel.critical:
                fillColor = const Color(0xFFFB7185);
                break;
              case RiskLevel.high:
                fillColor = const Color(0xFFF97316);
                break;
              case RiskLevel.moderate:
                fillColor = const Color(0xFFFBBF24);
                break;
              case RiskLevel.low:
                fillColor = const Color(0xFF2DD4BF);
                break;
            }

            final points = w.polygonCoordinates.first
                .map((pt) => LatLng(pt[0], pt[1]))
                .toList();

            return Polygon(
              points: points,
              color: fillColor.withAlpha(isSelected ? 120 : 60),
              borderColor: isSelected ? Colors.white : fillColor,
              borderStrokeWidth: isSelected ? 3.0 : 1.5,
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: wards.map((w) {
            final isSelected = selectedWard?.id == w.id;
            final risk = MockDataService.getRiskPrediction(w.id);

            Color badgeColor;
            switch (risk.riskLevel) {
              case RiskLevel.critical:
                badgeColor = const Color(0xFFFB7185);
                break;
              case RiskLevel.high:
                badgeColor = const Color(0xFFF97316);
                break;
              case RiskLevel.moderate:
                badgeColor = const Color(0xFFFBBF24);
                break;
              case RiskLevel.low:
                badgeColor = const Color(0xFF2DD4BF);
                break;
            }

            return Marker(
              point: LatLng(w.center[0], w.center[1]),
              width: 96,
              height: 48,
              child: GestureDetector(
                onTap: () => onSelectWard(w),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? Colors.white : badgeColor,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withAlpha(80),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          w.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Risk: ${risk.compoundRiskScore.toStringAsFixed(1)}',
                          style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
