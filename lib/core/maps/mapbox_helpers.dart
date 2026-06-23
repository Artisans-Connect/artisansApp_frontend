import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../theme/app_colors.dart';
import 'map_feature_helpers.dart';

/// Shared primitives for the Mapbox-rendered maps across the app. Keeps the
/// per-widget map implementations consistent (style, marker colors, camera
/// fitting) without coupling [MapFeatureHelpers] to the Mapbox SDK.

/// Default style used by every embedded Mapbox map. Standard renders reliably
/// on Android GL surfaces and reads light/warm by day, matching the app theme.
const String kMapboxStyle = mapbox.MapboxStyles.STANDARD;

/// Convert a Google [LatLng] (the app's lingua franca for coordinates) into a
/// Mapbox [mapbox.Point].
mapbox.Point mapboxPoint(google.LatLng position) {
  return mapbox.Point(
    coordinates: mapbox.Position(position.longitude, position.latitude),
  );
}

/// ARGB int expected by Mapbox annotation color fields.
int mapboxArgb(Color color) => color.toARGB32();

/// Theme color for a worker/job marker, accounting for the selected state.
Color mapboxColorFor(MapMarkerKind kind, {bool selected = false}) {
  if (selected) return AppColors.success;
  return switch (kind) {
    MapMarkerKind.selectedWorker => AppColors.success,
    MapMarkerKind.selectedJob => AppColors.success,
    MapMarkerKind.staleWorker => AppColors.error,
    MapMarkerKind.urgentJob => AppColors.error,
    MapMarkerKind.currentUser => AppColors.primary,
    MapMarkerKind.client => AppColors.primary,
    MapMarkerKind.worker => AppColors.accentGold,
    MapMarkerKind.job => AppColors.accentGold,
  };
}

/// Animate [map] so that all [points] are visible. Falls back to a simple
/// centered ease when only a single point is supplied.
Future<void> mapboxFitToPoints(
  mapbox.MapboxMap map,
  List<google.LatLng> points, {
  double singlePointZoom = 14,
  double pitch = 0,
  mapbox.MbxEdgeInsets? padding,
  int durationMs = 600,
}) async {
  if (points.isEmpty) return;
  final mapboxPoints = points.map(mapboxPoint).toList();
  if (mapboxPoints.length == 1) {
    await map.easeTo(
      mapbox.CameraOptions(
        center: mapboxPoints.first,
        zoom: singlePointZoom,
        pitch: pitch,
      ),
      mapbox.MapAnimationOptions(duration: durationMs),
    );
    return;
  }
  final camera = await map.cameraForCoordinatesPadding(
    mapboxPoints,
    mapbox.CameraOptions(pitch: pitch),
    padding ??
        mapbox.MbxEdgeInsets(top: 80, left: 60, bottom: 80, right: 60),
    null,
    null,
  );
  await map.easeTo(camera, mapbox.MapAnimationOptions(duration: durationMs));
}
