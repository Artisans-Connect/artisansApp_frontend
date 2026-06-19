import 'package:geolocator/geolocator.dart';

/// Neutral fallback when GPS is unavailable. Callers must not treat this as
/// the user's live location without checking [isFallback].
class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    this.isFallback = false,
  });

  final double latitude;
  final double longitude;
  final bool isFallback;

  static const DeviceLocation accraDefault = DeviceLocation(
    latitude: 5.6037,
    longitude: -0.1870,
    isFallback: true,
  );
}

class DeviceLocationService {
  static Future<DeviceLocation> getCurrentOrDefault() async {
    final position = await _tryGetPosition();
    if (position != null) {
      return DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
    return DeviceLocation.accraDefault;
  }

  static Future<Position?> _tryGetPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
