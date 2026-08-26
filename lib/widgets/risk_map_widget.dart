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
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.coolnetai.app',
        ),
        PolygonLayer(
          polygons: wards.map((w) {
            final isSelected = selectedWard?.id == w.id;
            final risk = MockDataService.getRiskPrediction(w.id);

            Color fillColor;
            switch (risk.riskLevel) {
              case RiskLevel.CRITICAL:
                fillColor = const Color(0xFFEF4444);
                break;
              case RiskLevel.HIGH:
                fillColor = const Color(0xFFF97316);
                break;
              case RiskLevel.MODERATE:
                fillColor = const Color(0xFFEAB308);
                break;
              case RiskLevel.LOW:
                fillColor = const Color(0xFF10B981);
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
              case RiskLevel.CRITICAL:
                badgeColor = const Color(0xFFEF4444);
                break;
              case RiskLevel.HIGH:
                badgeColor = const Color(0xFFF97316);
                break;
              case RiskLevel.MODERATE:
                badgeColor = const Color(0xFFEAB308);
                break;
              case RiskLevel.LOW:
                badgeColor = const Color(0xFF10B981);
                break;
            }

            return Marker(
              point: LatLng(w.center[0], w.center[1]),
              width: 90,
              height: 40,
              child: GestureDetector(
                onTap: () => onSelectWard(w),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        w.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Risk: ${risk.compoundRiskScore}',
                        style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
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
