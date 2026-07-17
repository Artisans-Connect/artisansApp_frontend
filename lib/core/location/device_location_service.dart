import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../shared/widgets/app_toast.dart';

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

  static const DeviceLocation knustDefault = DeviceLocation(
    latitude: 6.674,
    longitude: -1.570,
    isFallback: true,
  );
}

class DeviceLocationService {
  static Future<bool> requestPermissionInteractive(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'GPS/location services are disabled on your device. Please turn them on so we can find your location.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              child: const Text('Enable GPS'),
            ),
          ],
        ),
      );
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!context.mounted) return false;
        AppToast.show(
          context,
          message: 'Location permission is required to use this feature.',
          type: AppToastType.error,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              requestPermissionInteractive(context);
            },
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permission is permanently denied in your device settings. Please enable it to use this feature.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<DeviceLocation> getCurrentOrDefault() async {
    final position = await _tryGetPosition();
    if (position != null) {
      return DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
    return DeviceLocation.knustDefault;
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
