import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/mock_data_service.dart';

enum MapLayerType {
  cartoDark,
  openStreetMap,
  satellite,
}

class RiskMapWidget extends StatefulWidget {
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
  State<RiskMapWidget> createState() => _RiskMapWidgetState();
}

class _RiskMapWidgetState extends State<RiskMapWidget> with TickerProviderStateMixin {
  late final MapController _mapController;
  MapLayerType _selectedLayer = MapLayerType.cartoDark;
  double _currentZoom = 12.0;
  LatLng _currentCenter = const LatLng(28.6250, 77.2100);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.selectedWard != null) {
      _currentCenter = LatLng(widget.selectedWard!.center[0], widget.selectedWard!.center[1]);
    }
  }

  @override
  void didUpdateWidget(covariant RiskMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWard != null && widget.selectedWard?.id != oldWidget.selectedWard?.id) {
      _animateToWard(widget.selectedWard!);
    }
  }

  void _animateToWard(Ward ward) {
    final target = LatLng(ward.center[0], ward.center[1]);
    final targetZoom = _currentZoom < 12.5 ? 13.0 : _currentZoom;
    _mapController.move(target, targetZoom);
    setState(() {
      _currentCenter = target;
      _currentZoom = targetZoom;
    });
  }

  void _recenterOverview() {
    if (widget.selectedWard != null) {
      _animateToWard(widget.selectedWard!);
    } else {
      const delhiCenter = LatLng(28.6250, 77.2100);
      _mapController.move(delhiCenter, 11.8);
      setState(() {
        _currentCenter = delhiCenter;
        _currentZoom = 11.8;
      });
    }
  }

  void _zoomIn() {
    final newZoom = (_mapController.camera.zoom + 1.0).clamp(5.0, 18.0);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() => _currentZoom = newZoom);
  }

  void _zoomOut() {
    final newZoom = (_mapController.camera.zoom - 1.0).clamp(5.0, 18.0);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() => _currentZoom = newZoom);
  }

  void _panBy({required double dLat, required double dLng}) {
    final current = _mapController.camera.center;
    final newCenter = LatLng(current.latitude + dLat, current.longitude + dLng);
    _mapController.move(newCenter, _mapController.camera.zoom);
    setState(() => _currentCenter = newCenter);
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = widget.selectedWard != null ? widget.selectedWard!.center[0] : 28.6250;
    final centerLng = widget.selectedWard != null ? widget.selectedWard!.center[1] : 77.2100;

    return Stack(
      children: [
        // Real Interactive Map Container
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLng),
            initialZoom: 12.0,
            minZoom: 4.5,
            maxZoom: 18.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
              enableMultiFingerGestureRace: true,
            ),
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture && mounted) {
                setState(() {
                  _currentZoom = camera.zoom;
                  _currentCenter = camera.center;
                });
              }
            },
          ),
          children: [
            // Real Map API Tile Layer based on user selection
            if (_selectedLayer == MapLayerType.openStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.coolnetai.app',
                maxZoom: 19,
              )
            else if (_selectedLayer == MapLayerType.cartoDark)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.coolnetai.app',
                maxZoom: 19,
              )
            else if (_selectedLayer == MapLayerType.satellite)
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.coolnetai.app',
                maxZoom: 18,
              ),

            // Real Ward Boundary Polygons
            PolygonLayer(
              polygons: widget.wards.map((w) {
                final isSelected = widget.selectedWard?.id == w.id;
                final risk = MockDataService.getRiskPrediction(w.id);

                Color fillColor;
                switch (risk.riskLevel) {
                  case RiskLevel.critical:
                    fillColor = const Color(0xFFFB7185); // Critical Rose
                    break;
                  case RiskLevel.high:
                    fillColor = const Color(0xFFF97316); // High Orange
                    break;
                  case RiskLevel.moderate:
                    fillColor = const Color(0xFFFBBF24); // Medium / Moderate Amber
                    break;
                  case RiskLevel.low:
                    fillColor = const Color(0xFF2DD4BF); // Low Teal
                    break;
                }

                final points = w.polygonCoordinates.first
                    .map((pt) => LatLng(pt[0], pt[1]))
                    .toList();

                return Polygon(
                  points: points,
                  color: fillColor.withAlpha(isSelected ? 130 : 55),
                  borderColor: isSelected ? Colors.white : fillColor,
                  borderStrokeWidth: isSelected ? 3.0 : 1.8,
                );
              }).toList(),
            ),

            // Real Data Ward Markers with HIGH, MEDIUM, LOW, CRITICAL & Temperature
            MarkerLayer(
              markers: widget.wards.map((w) {
                final isSelected = widget.selectedWard?.id == w.id;
                final risk = MockDataService.getRiskPrediction(w.id);
                final weather = MockDataService.getWeatherData(w.id);

                Color badgeColor;
                String riskLabel;
                switch (risk.riskLevel) {
                  case RiskLevel.critical:
                    badgeColor = const Color(0xFFFB7185);
                    riskLabel = 'CRITICAL';
                    break;
                  case RiskLevel.high:
                    badgeColor = const Color(0xFFF97316);
                    riskLabel = 'HIGH';
                    break;
                  case RiskLevel.moderate:
                    badgeColor = const Color(0xFFFBBF24);
                    riskLabel = 'MEDIUM';
                    break;
                  case RiskLevel.low:
                    badgeColor = const Color(0xFF2DD4BF);
                    riskLabel = 'LOW';
                    break;
                }

                return Marker(
                  point: LatLng(w.center[0], w.center[1]),
                  width: 104,
                  height: 52,
                  child: GestureDetector(
                    onTap: () {
                      widget.onSelectWard(w);
                      _animateToWard(w);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1524).withAlpha(240),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.white : badgeColor.withAlpha(190),
                          width: isSelected ? 2.2 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withAlpha(isSelected ? 140 : 80),
                            blurRadius: isSelected ? 12 : 6,
                            spreadRadius: isSelected ? 2 : 1,
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
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withAlpha(40),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    riskLabel,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${weather.temperature.toStringAsFixed(0)}°C',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
        ),

        // Real Map Layer Selector (Top Right)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withAlpha(235),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _layerButton(MapLayerType.cartoDark, '🌙 Dark', 'High-contrast Carto Dark Matter API'),
                const SizedBox(width: 4),
                _layerButton(MapLayerType.openStreetMap, '🗺️ Street', 'Live OpenStreetMap API'),
                const SizedBox(width: 4),
                _layerButton(MapLayerType.satellite, '🛰️ Satellite', 'Real Esri World Imagery API'),
              ],
            ),
          ),
        ),

        // Floating Map Navigation & Zoom Controls (Right Middle)
        Positioned(
          right: 12,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom In
              _mapActionButton(
                icon: Icons.add_rounded,
                tooltip: 'Zoom In',
                onPressed: _zoomIn,
              ),
              const SizedBox(height: 6),
              // Zoom Out
              _mapActionButton(
                icon: Icons.remove_rounded,
                tooltip: 'Zoom Out',
                onPressed: _zoomOut,
              ),
              const SizedBox(height: 6),
              // Recenter on Ward / Delhi
              _mapActionButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Recenter on Selected Ward / Overview',
                onPressed: _recenterOverview,
                highlight: true,
              ),
            ],
          ),
        ),

        // Pan Controller (Bottom Left) for quick directional movement on all devices
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withAlpha(230),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pan_tool_outlined, size: 13, color: Color(0xFF38BDF8)),
                const SizedBox(width: 6),
                const Text(
                  'DRAG TO PAN',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                ),
                const SizedBox(width: 6),
                _panArrow(Icons.arrow_back_rounded, () => _panBy(dLat: 0.0, dLng: -0.03)),
                _panArrow(Icons.arrow_upward_rounded, () => _panBy(dLat: 0.03, dLng: 0.0)),
                _panArrow(Icons.arrow_downward_rounded, () => _panBy(dLat: -0.03, dLng: 0.0)),
                _panArrow(Icons.arrow_forward_rounded, () => _panBy(dLat: 0.0, dLng: 0.03)),
              ],
            ),
          ),
        ),

        // Real Map API & Attribution Badge (Top Left)
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withAlpha(225),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF22C55E).withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _layerDisplayName(_selectedLayer),
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· Zoom ${_currentZoom.toStringAsFixed(1)} · ${_currentCenter.latitude.toStringAsFixed(2)}°N, ${_currentCenter.longitude.toStringAsFixed(2)}°E',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _layerButton(MapLayerType layer, String label, String tooltip) {
    final isSelected = _selectedLayer == layer;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: () => setState(() => _selectedLayer = layer),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF38BDF8).withAlpha(45) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF7DD3FC) : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool highlight = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFF0F172A).withAlpha(240),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onPressed,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: highlight ? const Color(0xFF38BDF8).withAlpha(160) : const Color(0xFF334155),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 19,
              color: highlight ? const Color(0xFF38BDF8) : const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panArrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, size: 14, color: const Color(0xFFCBD5E1)),
      ),
    );
  }

  String _layerDisplayName(MapLayerType layer) {
    switch (layer) {
      case MapLayerType.cartoDark:
        return 'CartoDB Dark API (Live)';
      case MapLayerType.openStreetMap:
        return 'OpenStreetMap Real API (Live)';
      case MapLayerType.satellite:
        return 'Esri Satellite Real API (Live)';
    }
  }
}
