import 'package:geolocator/geolocator.dart';

/// Accra fallback when GPS is unavailable (demo / permission denied).
class DeviceLocation {
  const DeviceLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  static const DeviceLocation accraDefault = DeviceLocation(
    latitude: 5.6037,
    longitude: -0.1870,
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
