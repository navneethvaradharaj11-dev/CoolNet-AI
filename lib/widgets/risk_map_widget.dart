import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/ward.dart';
import '../models/risk_data.dart';
import '../services/mock_data_service.dart';

enum MapLayerType {
  darkCanvas,
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

class _RiskMapWidgetState extends State<RiskMapWidget> {
  late final MapController _mapController;
  MapLayerType _selectedLayer = MapLayerType.darkCanvas;
  final ValueNotifier<String> _cameraStatusNotifier = ValueNotifier<String>('· Zoom 12.0 · 28.63°N, 77.21°E');
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _cameraStatusNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RiskMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWard != null && widget.selectedWard?.id != oldWidget.selectedWard?.id) {
      _flyToWard(widget.selectedWard!);
    }
  }

  void _flyToWard(Ward ward) {
    final target = LatLng(ward.center[0], ward.center[1]);
    final double targetZoom = _mapController.camera.zoom < 12.5 ? 13.0 : _mapController.camera.zoom;
    _mapController.move(target, targetZoom);
    _cameraStatusNotifier.value =
        '· Zoom ${targetZoom.toStringAsFixed(1)} · ${target.latitude.toStringAsFixed(2)}°N, ${target.longitude.toStringAsFixed(2)}°E';
  }

  void _recenterOverview() {
    if (widget.selectedWard != null) {
      _flyToWard(widget.selectedWard!);
    } else {
      const delhiCenter = LatLng(28.6250, 77.2100);
      _mapController.move(delhiCenter, 11.8);
      _cameraStatusNotifier.value = '· Zoom 11.8 · 28.63°N, 77.21°E';
    }
  }

  void _zoomIn() {
    final newZoom = (_mapController.camera.zoom + 1.0).clamp(4.5, 18.5);
    _mapController.move(_mapController.camera.center, newZoom);
    _cameraStatusNotifier.value =
        '· Zoom ${newZoom.toStringAsFixed(1)} · ${_mapController.camera.center.latitude.toStringAsFixed(2)}°N, ${_mapController.camera.center.longitude.toStringAsFixed(2)}°E';
  }

  void _zoomOut() {
    final newZoom = (_mapController.camera.zoom - 1.0).clamp(4.5, 18.5);
    _mapController.move(_mapController.camera.center, newZoom);
    _cameraStatusNotifier.value =
        '· Zoom ${newZoom.toStringAsFixed(1)} · ${_mapController.camera.center.latitude.toStringAsFixed(2)}°N, ${_mapController.camera.center.longitude.toStringAsFixed(2)}°E';
  }

  void _panBy({required double dLat, required double dLng}) {
    final current = _mapController.camera.center;
    final newCenter = LatLng(current.latitude + dLat, current.longitude + dLng);
    _mapController.move(newCenter, _mapController.camera.zoom);
    _cameraStatusNotifier.value =
        '· Zoom ${_mapController.camera.zoom.toStringAsFixed(1)} · ${newCenter.latitude.toStringAsFixed(2)}°N, ${newCenter.longitude.toStringAsFixed(2)}°E';
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _isFullscreen = false);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF080F1C),
          body: Stack(
            children: [
              _buildMapCore(),
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton.small(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  tooltip: 'Exit Fullscreen',
                  onPressed: () => setState(() => _isFullscreen = false),
                  child: const Icon(Icons.fullscreen_exit_rounded, size: 22),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildMapCore();
  }

  Widget _buildMapCore() {
    final centerLat = widget.selectedWard != null ? widget.selectedWard!.center[0] : 28.6250;
    final centerLng = widget.selectedWard != null ? widget.selectedWard!.center[1] : 77.2100;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {},
      child: Stack(
        children: [
          // FlutterMap without setState on drag -> silky smooth 60fps GPU panning
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
                // DO NOT call setState here! Update ValueNotifier to avoid re-rendering polygons/markers on every frame
                if (hasGesture) {
                  _cameraStatusNotifier.value =
                      '· Zoom ${camera.zoom.toStringAsFixed(1)} · ${camera.center.latitude.toStringAsFixed(2)}°N, ${camera.center.longitude.toStringAsFixed(2)}°E';
                }
              },
            ),
            children: [
              // 100% Free Live Map Tile APIs - ZERO API Key Required
              if (_selectedLayer == MapLayerType.darkCanvas)
                TileLayer(
                  // ESRI World Dark Gray Base MapServer: 100% free, fast, no API key, no watermark
                  urlTemplate: 'https://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.coolnetai.app',
                  maxZoom: 18,
                )
              else if (_selectedLayer == MapLayerType.openStreetMap)
                TileLayer(
                  // Standard OpenStreetMap Tile Server: 100% free, live road & street map
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.coolnetai.app',
                  maxZoom: 19,
                )
              else if (_selectedLayer == MapLayerType.satellite)
                TileLayer(
                  // ESRI World Imagery: 100% free satellite photography, no API key
                  urlTemplate: 'https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.coolnetai.app',
                  maxZoom: 18,
                ),

              // Real Ward Boundaries
              PolygonLayer(
                polygons: widget.wards.map((w) {
                  final isSelected = widget.selectedWard?.id == w.id;
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
                    color: fillColor.withAlpha(isSelected ? 130 : 50),
                    borderColor: isSelected ? Colors.white : fillColor,
                    borderStrokeWidth: isSelected ? 3.0 : 1.6,
                  );
                }).toList(),
              ),

              // Real Ward Markers with Risk Badge
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
                        _flyToWard(w);
                      },
                      child: Container(
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
                              color: badgeColor.withAlpha(isSelected ? 140 : 70),
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
                  _layerButton(MapLayerType.darkCanvas, '🌙 Dark', 'ESRI World Dark Canvas · 100% Free, No Key'),
                  const SizedBox(width: 4),
                  _layerButton(MapLayerType.openStreetMap, '🗺️ Street', 'Live OpenStreetMap API · Free'),
                  const SizedBox(width: 4),
                  _layerButton(MapLayerType.satellite, '🛰️ Satellite', 'Real Esri World Imagery · Free'),
                ],
              ),
            ),
          ),

          // Floating Map Navigation & Zoom Controls (Right Middle)
          Positioned(
            right: 12,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mapActionButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 6),
                _mapActionButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onPressed: _zoomOut,
                ),
                const SizedBox(height: 6),
                _mapActionButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter on Selected Ward / Overview',
                  onPressed: _recenterOverview,
                  highlight: true,
                ),
                const SizedBox(height: 6),
                _mapActionButton(
                  icon: _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  tooltip: _isFullscreen ? 'Exit Fullscreen' : 'Expand Fullscreen Map',
                  onPressed: () => setState(() => _isFullscreen = !_isFullscreen),
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
                    'MOVE',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                  ),
                  const SizedBox(width: 6),
                  _panArrow(Icons.arrow_back_rounded, () => _panBy(dLat: 0.0, dLng: -0.04)),
                  _panArrow(Icons.arrow_upward_rounded, () => _panBy(dLat: 0.04, dLng: 0.0)),
                  _panArrow(Icons.arrow_downward_rounded, () => _panBy(dLat: -0.04, dLng: 0.0)),
                  _panArrow(Icons.arrow_forward_rounded, () => _panBy(dLat: 0.0, dLng: 0.04)),
                ],
              ),
            ),
          ),

          // Real Map API & Live Status Badge (Top Left)
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
                  ValueListenableBuilder<String>(
                    valueListenable: _cameraStatusNotifier,
                    builder: (context, statusText, _) {
                      return Text(
                        statusText,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
      case MapLayerType.darkCanvas:
        return 'ESRI Dark Gray (Free)';
      case MapLayerType.openStreetMap:
        return 'OpenStreetMap (Free)';
      case MapLayerType.satellite:
        return 'Esri Satellite (Free)';
    }
  }
}
