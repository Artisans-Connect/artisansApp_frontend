import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../core/constants/app_constants.dart';
import '../../core/maps/map_feature_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'custom_marker_builder.dart';

class MapboxWorkerMarker {
  const MapboxWorkerMarker({
    required this.id,
    required this.position,
    required this.kind,
    this.iconData,
  });

  final String id;
  final google.LatLng position;
  final MapMarkerKind kind;
  final IconData? iconData;
}

class MapboxWorkerDiscoveryMap extends StatefulWidget {
  const MapboxWorkerDiscoveryMap({
    super.key,
    required this.userPosition,
    required this.workers,
    required this.onWorkerSelected,
    required this.radiusKm,
    this.selectedWorkerId,
    this.heightFactor = 0.5,
  });

  final google.LatLng userPosition;
  final List<MapboxWorkerMarker> workers;
  final String? selectedWorkerId;
  final ValueChanged<String> onWorkerSelected;
  final double radiusKm;
  final double heightFactor;

  @override
  State<MapboxWorkerDiscoveryMap> createState() =>
      _MapboxWorkerDiscoveryMapState();
}

class _MapboxWorkerDiscoveryMapState extends State<MapboxWorkerDiscoveryMap> {
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _manager;
  mapbox.PointAnnotationManager? _pointManager;
  mapbox.PolylineAnnotationManager? _ringManager;
  bool _styleReady = false;

  @override
  void didUpdateWidget(MapboxWorkerDiscoveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workers != widget.workers ||
        oldWidget.selectedWorkerId != widget.selectedWorkerId ||
        oldWidget.userPosition != widget.userPosition ||
        oldWidget.radiusKm != widget.radiusKm) {
      if (_styleReady) {
        _syncSearchRings();
        _syncMarkers();
        _fitCamera();
      }
    }
  }

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _map = map;
    
    final userIconBytes = await CustomMarkerBuilder.createMarkerImage(
      Icons.waving_hand_rounded,
      AppColors.primary,
      size: 90.0,
    );
    
    await map.location.updateSettings(
      mapbox.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        locationPuck: mapbox.LocationPuck(
          locationPuck2D: mapbox.LocationPuck2D(
            topImage: userIconBytes,
          ),
        ),
      ),
    );
  }

  Future<void> _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;
    _styleReady = true;
    _ringManager ??= await map.annotations.createPolylineAnnotationManager();
    _manager ??= await map.annotations.createCircleAnnotationManager();
    _pointManager ??= await map.annotations.createPointAnnotationManager();
    
    _manager?.tapEvents(onTap: (annotation) {
      final id = annotation.customData?['workerId']?.toString();
      if (id != null && id.isNotEmpty) widget.onWorkerSelected(id);
    });
    
    _pointManager?.tapEvents(onTap: (annotation) {
      final id = annotation.customData?['workerId']?.toString();
      if (id != null && id.isNotEmpty) widget.onWorkerSelected(id);
    });
    
    await _syncSearchRings();
    await _syncMarkers();
    await _fitCamera();
  }

  Future<void> _syncMarkers() async {
    final manager = _manager;
    final pManager = _pointManager;
    if (manager == null || pManager == null) return;
    
    await manager.deleteAll();
    await pManager.deleteAll();
    
    final pointOptions = <mapbox.PointAnnotationOptions>[];
    for (final worker in widget.workers) {
      final selected = worker.id == widget.selectedWorkerId;
      final color = _colorFor(worker.kind, selected);
      
      Uint8List? imageBytes;
      if (worker.iconData != null) {
        imageBytes = await CustomMarkerBuilder.createMarkerImage(
          worker.iconData!,
          color,
          size: selected ? 110.0 : 90.0,
        );
      }
      
      if (imageBytes != null) {
        pointOptions.add(mapbox.PointAnnotationOptions(
          geometry: _point(worker.position),
          image: imageBytes,
          symbolSortKey: selected ? 30 : 20,
          customData: <String, Object>{'workerId': worker.id},
        ));
      } else {
        await manager.create(mapbox.CircleAnnotationOptions(
          geometry: _point(worker.position),
          circleColor: _argb(color),
          circleRadius: selected ? 14 : 11,
          circleStrokeColor: _argb(Colors.white),
          circleStrokeWidth: selected ? 4 : 3,
          circleSortKey: selected ? 30 : 20,
          customData: <String, Object>{'workerId': worker.id},
        ));
      }
    }
    
    if (pointOptions.isNotEmpty) {
      await pManager.createMulti(pointOptions);
    }
  }

  Future<void> _syncSearchRings() async {
    final manager = _ringManager;
    if (manager == null) return;
    await manager.deleteAll();
    final radii = <double>{
      widget.radiusKm,
      (widget.radiusKm * 0.66).clamp(0.5, widget.radiusKm),
      (widget.radiusKm * 0.33).clamp(0.25, widget.radiusKm),
    }.toList()
      ..sort();

    await manager.createMulti(
      radii.map((radius) {
        final bool outer = radius == widget.radiusKm;
        return mapbox.PolylineAnnotationOptions(
          geometry: _ring(widget.userPosition, radius),
          lineColor: _argb(AppColors.accentGold),
          lineOpacity: outer ? 0.78 : 0.42,
          lineWidth: outer ? 2.4 : 1.35,
          lineBlur: outer ? 1.4 : 0.6,
          lineSortKey: 5,
        );
      }).toList(),
    );
  }

  Future<void> _fitCamera() async {
    final map = _map;
    if (map == null) return;
    final ringPoints = _ringPoints(widget.userPosition, widget.radiusKm);
    final points = <mapbox.Point>[
      _point(widget.userPosition),
      ...widget.workers.map((worker) => _point(worker.position)),
      ...ringPoints.map(_point),
    ];
    if (points.length <= 1) {
      await map.easeTo(
        mapbox.CameraOptions(center: points.first, zoom: 14, pitch: 24),
        mapbox.MapAnimationOptions(duration: 500),
      );
      return;
    }
    final camera = await map.cameraForCoordinatesPadding(
      points,
      mapbox.CameraOptions(pitch: 24),
      mapbox.MbxEdgeInsets(top: 90, left: 60, bottom: 260, right: 60),
      15,
      null,
    );
    await map.easeTo(camera, mapbox.MapAnimationOptions(duration: 700));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || AppConstants.mapboxAccessToken.isEmpty) {
      if (AppConstants.googleMapsApiKey.isNotEmpty) {
        return _GoogleWorkerDiscoveryFallback(
          userPosition: widget.userPosition,
          workers: widget.workers,
          selectedWorkerId: widget.selectedWorkerId,
          onWorkerSelected: widget.onWorkerSelected,
          radiusKm: widget.radiusKm,
          heightFactor: widget.heightFactor,
        );
      }
      return _MapboxUnavailable(
        height: MediaQuery.of(context).size.height * widget.heightFactor,
        message:
            'Configure MAPBOX_ACCESS_TOKEN or GOOGLE_MAPS_API_KEY to show the client map experience.',
      );
    }

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * widget.heightFactor,
      child: mapbox.MapWidget(
        key: const ValueKey<String>('client-mapbox-discovery-map'),
        styleUri: mapbox.MapboxStyles.STANDARD,
        viewport: mapbox.CameraViewportState(
          center: _point(widget.userPosition),
          zoom: 13,
          pitch: 24,
        ),
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        onMapCreated: _onMapCreated,
        onStyleLoadedListener: _onStyleLoaded,
      ),
    );
  }
}

class _GoogleWorkerDiscoveryFallback extends StatelessWidget {
  const _GoogleWorkerDiscoveryFallback({
    required this.userPosition,
    required this.workers,
    required this.selectedWorkerId,
    required this.onWorkerSelected,
    required this.radiusKm,
    required this.heightFactor,
  });

  final google.LatLng userPosition;
  final List<MapboxWorkerMarker> workers;
  final String? selectedWorkerId;
  final ValueChanged<String> onWorkerSelected;
  final double radiusKm;
  final double heightFactor;

  Set<google.Marker> get _markers {
    return <google.Marker>{
      google.Marker(
        markerId: const google.MarkerId('current-user'),
        position: userPosition,
        icon: google.BitmapDescriptor.defaultMarkerWithHue(
          MapFeatureHelpers.markerHueFor(MapMarkerKind.currentUser),
        ),
        infoWindow: const google.InfoWindow(title: 'You'),
      ),
      ...workers.map((worker) {
        final selected = worker.id == selectedWorkerId;
        final kind = selected ? MapMarkerKind.selectedWorker : worker.kind;
        return google.Marker(
          markerId: google.MarkerId('worker-${worker.id}'),
          position: worker.position,
          icon: google.BitmapDescriptor.defaultMarkerWithHue(
            MapFeatureHelpers.markerHueFor(kind),
          ),
          onTap: () => onWorkerSelected(worker.id),
        );
      }),
    };
  }

  Set<google.Circle> get _circles {
    final radii = <double>{
      radiusKm,
      (radiusKm * 0.66).clamp(0.5, radiusKm),
      (radiusKm * 0.33).clamp(0.25, radiusKm),
    }.toList();

    return <google.Circle>{
      for (final radius in radii)
        google.Circle(
          circleId: google.CircleId('search-zone-$radius'),
          center: userPosition,
          radius: radius * 1000,
          strokeColor: AppColors.primary.withValues(
            alpha: radius == radiusKm ? 0.78 : 0.42,
          ),
          strokeWidth: radius == radiusKm ? 3 : 2,
          fillColor: AppColors.primary.withValues(
            alpha: radius == radiusKm ? 0.11 : 0.04,
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * heightFactor,
      child: google.GoogleMap(
        key: ValueKey<String>(
          'client-google-discovery-${radiusKm.toStringAsFixed(0)}-$selectedWorkerId-${workers.length}',
        ),
        initialCameraPosition: google.CameraPosition(
          target: userPosition,
          zoom: radiusKm <= 5 ? 13 : 12,
        ),
        markers: _markers,
        circles: _circles,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
      ),
    );
  }
}

class MapboxJobLocationMap extends StatefulWidget {
  const MapboxJobLocationMap({
    super.key,
    required this.initial,
    this.onPositionChanged,
    this.height = 200,
  });

  final google.LatLng initial;
  final ValueChanged<google.LatLng>? onPositionChanged;
  final double height;

  @override
  State<MapboxJobLocationMap> createState() => _MapboxJobLocationMapState();
}

class _MapboxJobLocationMapState extends State<MapboxJobLocationMap> {
  mapbox.MapboxMap? _map;
  google.LatLng _center = const google.LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _center = widget.initial;
  }

  @override
  void didUpdateWidget(MapboxJobLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _center = widget.initial;
      _map?.easeTo(
        mapbox.CameraOptions(center: _point(widget.initial), zoom: 15),
        mapbox.MapAnimationOptions(duration: 450),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || AppConstants.mapboxAccessToken.isEmpty) {
      return _MapboxUnavailable(
        height: widget.height,
        message:
            'Configure MAPBOX_ACCESS_TOKEN to use the Mapbox location picker.',
      );
    }

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Stack(
          alignment: Alignment.center,
          children: [
            mapbox.MapWidget(
              key: const ValueKey<String>('job-location-mapbox-map'),
              styleUri: mapbox.MapboxStyles.STANDARD,
              viewport: mapbox.CameraViewportState(
                center: _point(_center),
                zoom: 15,
                pitch: 18,
              ),
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              onMapCreated: (map) {
                _map = map;
                map.location.updateSettings(
                  mapbox.LocationComponentSettings(enabled: true),
                );
              },
              onCameraChangeListener: (event) {
                final coordinates = event.cameraState.center.coordinates;
                _center = google.LatLng(
                  coordinates.lat.toDouble(),
                  coordinates.lng.toDouble(),
                );
              },
              onMapIdleListener: (_) {
                widget.onPositionChanged?.call(_center);
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Text(
                  'Move the map to set the exact service point.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IgnorePointer(
              child: Icon(Icons.location_on, color: AppColors.primary, size: 42),
            ),
          ],
        ),
      ),
    );
  }
}

mapbox.Point _point(google.LatLng position) {
  return mapbox.Point(
    coordinates: mapbox.Position(position.longitude, position.latitude),
  );
}

mapbox.LineString _ring(google.LatLng center, double radiusKm) {
  return mapbox.LineString.fromPoints(
    points: _ringPoints(center, radiusKm).map(_point).toList(),
  );
}

List<google.LatLng> _ringPoints(google.LatLng center, double radiusKm) {
  const steps = 96;
  final latRadians = center.latitude * math.pi / 180;
  const latDegreeKm = 110.574;
  final lngDegreeKm =
      (111.320 * math.cos(latRadians).abs()).clamp(10.0, 111.320);

  return List<google.LatLng>.generate(steps + 1, (index) {
    final angle = (index / steps) * math.pi * 2;
    final lat = center.latitude + (math.sin(angle) * radiusKm / latDegreeKm);
    final lng = center.longitude + (math.cos(angle) * radiusKm / lngDegreeKm);
    return google.LatLng(lat, lng);
  });
}

Color _colorFor(MapMarkerKind kind, bool selected) {
  if (selected) return AppColors.success;
  return switch (kind) {
    MapMarkerKind.selectedWorker => AppColors.success,
    MapMarkerKind.staleWorker => AppColors.error,
    MapMarkerKind.currentUser => AppColors.primary,
    MapMarkerKind.worker => AppColors.accentGold,
    _ => AppColors.primary,
  };
}

int _argb(Color color) => color.toARGB32();

class _MapboxUnavailable extends StatelessWidget {
  const _MapboxUnavailable({
    required this.height,
    required this.message,
  });

  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
