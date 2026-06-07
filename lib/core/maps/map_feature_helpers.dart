import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/haversine.dart' as distance_utils;

enum MapRouteEstimateSource { haversine, googleRoutes }

class MapRouteEstimate {
  const MapRouteEstimate({
    required this.distanceKm,
    required this.etaMinutes,
    required this.source,
  });

  factory MapRouteEstimate.between({
    required LatLng origin,
    required LatLng destination,
    double speedKmh = 25,
  }) {
    final distance = distance_utils.haversineKm(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    return MapRouteEstimate(
      distanceKm: distance,
      etaMinutes: distance_utils.etaMinutes(distance, speedKmh: speedKmh),
      source: MapRouteEstimateSource.haversine,
    );
  }

  final double distanceKm;
  final int etaMinutes;
  final MapRouteEstimateSource source;

  String get distanceLabel {
    if (distanceKm < 1) return '${(distanceKm * 1000).round()} m';
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get etaLabel => '~$etaMinutes min';
}

enum MapPointRole { client, worker, job, currentUser }

class MapPoint {
  const MapPoint({
    required this.id,
    required this.role,
    required this.position,
    required this.title,
    required this.subtitle,
    this.distanceKm,
    this.rating,
    this.isVerified = false,
    this.isAvailable = false,
    this.locationAt,
    this.avatarUrl,
    this.raw = const <String, dynamic>{},
  });

  factory MapPoint.workerFromApi(Map<String, dynamic> raw) {
    final profile = MapFeatureHelpers.asStringMap(raw['profiles']);
    final skills = raw['skills'] is List ? raw['skills'] as List<dynamic> : const <dynamic>[];
    final title = (profile['full_name'] ?? raw['name'] ?? 'Artisan').toString();
    final subtitle = skills.isNotEmpty
        ? skills.first.toString()
        : (raw['profession'] ?? 'Professional').toString();
    final lat = MapFeatureHelpers.asDouble(raw['current_lat'] ?? raw['lat']);
    final lng = MapFeatureHelpers.asDouble(raw['current_lng'] ?? raw['lng']);

    return MapPoint(
      id: (raw['id'] ?? raw['worker_id'] ?? '').toString(),
      role: MapPointRole.worker,
      position: LatLng(lat ?? 0, lng ?? 0),
      title: title,
      subtitle: subtitle,
      distanceKm: MapFeatureHelpers.asDouble(raw['distance_km']),
      rating: MapFeatureHelpers.asDouble(raw['rating']),
      isVerified: raw['is_verified'] == true,
      isAvailable: raw['is_available'] == true || raw['available'] == true,
      locationAt: MapFeatureHelpers.asDateTime(raw['location_at']),
      avatarUrl: (profile['avatar_url'] ?? raw['imageUrl'])?.toString(),
      raw: raw,
    );
  }

  final String id;
  final MapPointRole role;
  final LatLng position;
  final String title;
  final String subtitle;
  final double? distanceKm;
  final double? rating;
  final bool isVerified;
  final bool isAvailable;
  final DateTime? locationAt;
  final String? avatarUrl;
  final Map<String, dynamic> raw;

  bool get hasFreshLocation => MapFeatureHelpers.isFreshLocation(locationAt);

  String get distanceLabel {
    final value = distanceKm;
    if (value == null) return 'Distance unavailable';
    if (value < 1) return '${(value * 1000).round()} m';
    return '${value.toStringAsFixed(1)} km';
  }
}

class MapFeatureHelpers {
  const MapFeatureHelpers._();

  static const Duration locationFreshnessWindow = Duration(minutes: 15);
  static const LatLng accraDefault = LatLng(5.6037, -0.1870);

  static bool isFreshLocation(DateTime? locationAt) {
    if (locationAt == null) return false;
    return DateTime.now().toUtc().difference(locationAt.toUtc()) <
        locationFreshnessWindow;
  }

  static Uri googleMapsDirectionsUri({
    required LatLng destination,
    LatLng? origin,
  }) {
    return Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      if (origin != null) 'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'travelmode': 'driving',
    });
  }

  static LatLngBounds boundsFor(Iterable<LatLng> points) {
    final list = points.toList();
    assert(list.isNotEmpty, 'boundsFor requires at least one point');
    double south = list.first.latitude;
    double north = list.first.latitude;
    double west = list.first.longitude;
    double east = list.first.longitude;
    for (final point in list.skip(1)) {
      south = math.min(south, point.latitude);
      north = math.max(north, point.latitude);
      west = math.min(west, point.longitude);
      east = math.max(east, point.longitude);
    }

    if (south == north) {
      south -= 0.002;
      north += 0.002;
    }
    if (west == east) {
      west -= 0.002;
      east += 0.002;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  static double? asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Map<String, dynamic> asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}
