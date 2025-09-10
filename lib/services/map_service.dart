import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/widgets.dart';

class MapService {
  static MapService? _instance;
  static MapService get instance => _instance ??= MapService._();

  MapService._();

  MapController? _mapController;

  /// Initialize map controller
  void initializeController() {
    _mapController = MapController();
  }

  /// Get map controller
  MapController? get mapController => _mapController;

  /// Move camera to specific location
  void moveToLocation(double latitude, double longitude, {double zoom = 15.0}) {
    _mapController?.move(LatLng(latitude, longitude), zoom);
  }

  /// Get current map center
  LatLng? getCurrentCenter() {
    return _mapController?.camera.center;
  }

  /// Get current zoom level
  double getCurrentZoom() {
    return _mapController?.camera.zoom ?? 15.0;
  }

  /// Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }

  /// Create marker
  Marker createMarker({
    required LatLng point,
    required Widget child,
    double? width,
    double? height,
  }) {
    return Marker(
      point: point,
      child: child,
      width: width ?? 40.0,
      height: height ?? 40.0,
    );
  }

  /// Dispose resources
  void dispose() {
    _mapController = null;
  }
}
