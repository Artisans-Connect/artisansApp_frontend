import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Debounced worker GPS pings directly to Supabase (no Express middleman).
class WorkerLocationService {
  WorkerLocationService._();
  static final WorkerLocationService instance = WorkerLocationService._();

  static const double _minMoveMeters = 10;
  static const Duration _maxInterval = Duration(seconds: 15);

  StreamSubscription<Position>? _subscription;
  Position? _lastPosition;
  DateTime? _lastPingAt;
  bool _running = false;

  bool get isRunning => _running;

  Future<void> start() async {
    if (_running) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final permission = await _ensurePermission();
    if (!permission) {
      throw Exception('Location permissions are required to go online.');
    }

    _running = true;
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      _onPosition,
      onError: (_) {},
    );

    try {
      final initial = await Geolocator.getCurrentPosition();
      await _maybePing(initial);
    } catch (_) {
      // Ignore initial location fetch error to prevent service startup failure.
    }
  }

  Future<void> stop() async {
    _running = false;
    await _subscription?.cancel();
    _subscription = null;
    _lastPosition = null;
    _lastPingAt = null;
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _onPosition(Position position) async {
    await _maybePing(position);
  }

  Future<void> _maybePing(Position position) async {
    final now = DateTime.now();
    final moved = _lastPosition == null ||
        Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            ) >=
            _minMoveMeters;
    final elapsed = _lastPingAt == null || now.difference(_lastPingAt!) >= _maxInterval;

    if (!moved && !elapsed) return;

    _lastPosition = position;
    _lastPingAt = now;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('workers').update({
      'current_lat': position.latitude,
      'current_lng': position.longitude,
      'location_at': now.toUtc().toIso8601String(),
    }).eq('id', userId);
  }
}
