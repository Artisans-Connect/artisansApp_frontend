import 'dart:math' as math;

const double _earthRadiusKm = 6371;

double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRad(lat1)) *
          math.cos(_toRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return _earthRadiusKm * c;
}

double _toRad(double deg) => deg * math.pi / 180;

/// Rough urban ETA minutes at [speedKmh] (default 25 km/h).
int etaMinutes(double distanceKm, {double speedKmh = 25}) {
  if (distanceKm <= 0) return 1;
  return math.max(1, (distanceKm / speedKmh * 60).round());
}
