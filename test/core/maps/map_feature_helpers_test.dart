import 'package:artisans_app/core/maps/map_feature_helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('RouteEstimate', () {
    test('creates a haversine estimate with a readable ETA label', () {
      final estimate = MapRouteEstimate.between(
        origin: const LatLng(5.6037, -0.1870),
        destination: const LatLng(5.6500, -0.1900),
      );

      expect(estimate.distanceKm, greaterThan(5));
      expect(estimate.distanceLabel, endsWith('km'));
      expect(estimate.etaLabel, startsWith('~'));
      expect(estimate.source, MapRouteEstimateSource.haversine);
    });

    test('formats short distances in meters', () {
      const estimate = MapRouteEstimate(
        distanceKm: 0.42,
        etaMinutes: 2,
        source: MapRouteEstimateSource.haversine,
      );

      expect(estimate.distanceLabel, '420 m');
      expect(estimate.etaLabel, '~2 min');
    });
  });

  group('MapFeatureHelpers', () {
    test('builds a Google Maps navigation URL', () {
      final uri = MapFeatureHelpers.googleMapsDirectionsUri(
        destination: const LatLng(6.6885, -1.6244),
        origin: const LatLng(6.6700, -1.6100),
      );

      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.query, contains('destination=6.6885%2C-1.6244'));
      expect(uri.query, contains('origin=6.67%2C-1.61'));
      expect(uri.query, contains('travelmode=driving'));
    });

    test('detects stale locations', () {
      final fresh = DateTime.now().toUtc().subtract(const Duration(minutes: 4));
      final stale = DateTime.now().toUtc().subtract(const Duration(minutes: 20));

      expect(MapFeatureHelpers.isFreshLocation(fresh), isTrue);
      expect(MapFeatureHelpers.isFreshLocation(stale), isFalse);
      expect(MapFeatureHelpers.isFreshLocation(null), isFalse);
    });
  });

  group('MapPoint', () {
    test('maps a nearby worker payload without losing ranking signals', () {
      final point = MapPoint.workerFromApi(
        {
          'id': 'worker-1',
          'current_lat': 5.61,
          'current_lng': -0.19,
          'distance_km': 1.25,
          'rating': 4.8,
          'is_verified': true,
          'is_available': true,
          'location_at': DateTime.now().toUtc().toIso8601String(),
          'skills': ['Electrician'],
          'profiles': {'full_name': 'Kofi Mensah'},
        },
      );

      expect(point.id, 'worker-1');
      expect(point.title, 'Kofi Mensah');
      expect(point.subtitle, 'Electrician');
      expect(point.distanceKm, 1.25);
      expect(point.rating, 4.8);
      expect(point.isVerified, isTrue);
      expect(point.isAvailable, isTrue);
      expect(point.hasFreshLocation, isTrue);
    });
  });
}
