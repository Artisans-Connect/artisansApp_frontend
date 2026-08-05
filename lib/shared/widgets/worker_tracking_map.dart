import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/maps/map_feature_helpers.dart';
import '../../core/maps/mapbox_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Client view: job site + live worker marker via Supabase Realtime on [workers].
///
/// Rendered with Mapbox on mobile; falls back to Google Maps on web or when
/// `MAPBOX_ACCESS_TOKEN` is not configured.
class WorkerTrackingMap extends StatefulWidget {
  const WorkerTrackingMap({
    super.key,
    required this.workerId,
    required this.jobLat,
    required this.jobLng,
    this.height = 300,
    this.onEtaChanged,
  });

  final String workerId;
  final double jobLat;
  final double jobLng;
  final double height;
  final ValueChanged<String>? onEtaChanged;

  @override
  State<WorkerTrackingMap> createState() => _WorkerTrackingMapState();
}

class _WorkerTrackingMapState extends State<WorkerTrackingMap>
    with SingleTickerProviderStateMixin {
  RealtimeChannel? _channel;
  google.LatLng? _workerPosition;
  DateTime? _workerLocationAt;
  late final AnimationController _pulseController;

  // Mapbox state.
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _markerManager;
  mapbox.PolylineAnnotationManager? _routeManager;
  bool _styleReady = false;
  bool _hasInitialFit = false;
  google.LatLng? _lastSyncedWorkerPos;

  // Google fallback controller.
  google.GoogleMapController? _googleController;

  google.LatLng get _job => google.LatLng(widget.jobLat, widget.jobLng);

  bool get _useMapbox =>
      !kIsWeb && AppConstants.mapboxAccessToken.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _loadInitialWorker();
    _subscribeWorker();
  }

  Future<void> _loadInitialWorker() async {
    final row = await Supabase.instance.client
        .from('workers')
        .select('current_lat, current_lng, location_at')
        .eq('id', widget.workerId)
        .maybeSingle();
    if (row == null || !mounted) return;
    final lat = (row['current_lat'] as num?)?.toDouble();
    final lng = (row['current_lng'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      _applyWorker(
        lat,
        lng,
        locationAt: MapFeatureHelpers.asDateTime(row['location_at']),
      );
    }
  }

  void _subscribeWorker() {
    _channel = Supabase.instance.client
        .channel('worker-loc-${widget.workerId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'workers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.workerId,
          ),
          callback: (payload) {
            final lat = (payload.newRecord['current_lat'] as num?)?.toDouble();
            final lng = (payload.newRecord['current_lng'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              _applyWorker(
                lat,
                lng,
                locationAt: MapFeatureHelpers.asDateTime(
                  payload.newRecord['location_at'],
                ),
              );
            }
          },
        )
        .subscribe();
  }

  Future<void> _applyWorker(double lat, double lng, {DateTime? locationAt}) async {
    final worker = google.LatLng(lat, lng);
    final estimate = await MapFeatureHelpers.defaultRouteProvider.estimate(
      origin: worker,
      destination: _job,
    );
    if (!mounted) return;
    setState(() {
      _workerPosition = worker;
      _workerLocationAt = locationAt ?? DateTime.now().toUtc();
    });
    widget.onEtaChanged?.call(
      estimate.distanceKm < 0.2 || estimate.etaMinutes <= 1
          ? 'Arriving now'
          : '${estimate.etaLabel} away',
    );
    _fitMap();
    if (_styleReady) _syncMapboxAnnotations();
  }

  void _fitMap({bool force = false}) {
    final worker = _workerPosition;
    if (worker == null) return;
    if (!force && _hasInitialFit) return;
    _hasInitialFit = true;

    if (_useMapbox) {
      final map = _map;
      if (map == null || !_styleReady) return;
      mapboxFitToPoints(
        map,
        <google.LatLng>[_job, worker],
        padding: mapbox.MbxEdgeInsets(top: 70, left: 50, bottom: 70, right: 50),
      );
    } else {
      _googleController?.animateCamera(
        google.CameraUpdate.newLatLngBounds(
          MapFeatureHelpers.boundsFor(<google.LatLng>[_job, worker]),
          48,
        ),
      );
    }
  }

  // ── Mapbox rendering ──────────────────────────────────────────────────────

  Future<void> _onMapboxCreated(mapbox.MapboxMap map) async {
    _map = map;
  }

  Future<void> _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;
    _styleReady = true;
    _routeManager ??= await map.annotations.createPolylineAnnotationManager();
    _markerManager ??= await map.annotations.createCircleAnnotationManager();
    await _syncMapboxAnnotations();
    _fitMap();
  }

  Future<void> _syncMapboxAnnotations() async {
    final markerManager = _markerManager;
    final routeManager = _routeManager;
    if (markerManager == null || routeManager == null) return;

    if (_lastSyncedWorkerPos != null && _lastSyncedWorkerPos == _workerPosition) {
      return;
    }
    _lastSyncedWorkerPos = _workerPosition;

    final hasFreshLocation =
        MapFeatureHelpers.isFreshLocation(_workerLocationAt);

    await markerManager.deleteAll();
    await routeManager.deleteAll();

    await markerManager.createMulti(<mapbox.CircleAnnotationOptions>[
      mapbox.CircleAnnotationOptions(
        geometry: mapboxPoint(_job),
        circleColor: mapboxArgb(mapboxColorFor(MapMarkerKind.client)),
        circleRadius: 11,
        circleStrokeColor: mapboxArgb(Colors.white),
        circleStrokeWidth: 3,
        circleSortKey: 20,
      ),
      if (_workerPosition != null)
        mapbox.CircleAnnotationOptions(
          geometry: mapboxPoint(_workerPosition!),
          circleColor: mapboxArgb(
            mapboxColorFor(
              hasFreshLocation
                  ? MapMarkerKind.selectedWorker
                  : MapMarkerKind.staleWorker,
            ),
          ),
          circleRadius: 12,
          circleStrokeColor: mapboxArgb(Colors.white),
          circleStrokeWidth: 3,
          circleSortKey: 30,
        ),
    ]);

    if (_workerPosition != null) {
      await routeManager.create(
        mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString.fromPoints(
            points: <mapbox.Point>[
              mapboxPoint(_workerPosition!),
              mapboxPoint(_job),
            ],
          ),
          lineColor: mapboxArgb(AppColors.primary),
          lineWidth: 4,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_useMapbox && AppConstants.googleMapsApiKey.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Configure MAPBOX_ACCESS_TOKEN or GOOGLE_MAPS_API_KEY for live tracking.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final estimate = _workerPosition == null
        ? null
        : MapRouteEstimate.between(
            origin: _workerPosition!,
            destination: _job,
          );
    final hasFreshLocation =
        MapFeatureHelpers.isFreshLocation(_workerLocationAt);

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: <Widget>[
            _useMapbox ? _buildMapbox() : _buildGoogle(hasFreshLocation),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: _TrackingStatusCard(
                animation: _pulseController,
                waiting: _workerPosition == null,
                fresh: hasFreshLocation,
                estimate: estimate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapbox() {
    return mapbox.MapWidget(
      key: const ValueKey<String>('worker-tracking-mapbox-map'),
      styleUri: kMapboxStyle,
      viewport: mapbox.CameraViewportState(
        center: mapboxPoint(_workerPosition ?? _job),
        zoom: 14,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      onMapCreated: _onMapboxCreated,
      onStyleLoadedListener: _onStyleLoaded,
    );
  }

  Widget _buildGoogle(bool hasFreshLocation) {
    final markers = <google.Marker>{
      google.Marker(
        markerId: const google.MarkerId('job'),
        position: _job,
        icon: MapFeatureHelpers.markerIconFor(MapMarkerKind.client),
        infoWindow: const google.InfoWindow(title: 'Job site'),
      ),
      if (_workerPosition != null)
        google.Marker(
          markerId: const google.MarkerId('worker'),
          position: _workerPosition!,
          icon: MapFeatureHelpers.markerIconFor(
            hasFreshLocation
                ? MapMarkerKind.selectedWorker
                : MapMarkerKind.staleWorker,
          ),
          infoWindow: const google.InfoWindow(title: 'Worker location'),
        ),
    };
    final polylines = <google.Polyline>{
      if (_workerPosition != null)
        google.Polyline(
          polylineId: const google.PolylineId('worker_to_job'),
          points: <google.LatLng>[_workerPosition!, _job],
          color: AppColors.primary,
          width: 4,
        ),
    };

    return google.GoogleMap(
      initialCameraPosition: google.CameraPosition(target: _job, zoom: 14),
      markers: markers,
      polylines: polylines,
      onMapCreated: (c) {
        _googleController = c;
        _fitMap();
      },
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

class _TrackingStatusCard extends StatelessWidget {
  const _TrackingStatusCard({
    required this.animation,
    required this.waiting,
    required this.fresh,
    required this.estimate,
  });

  final Animation<double> animation;
  final bool waiting;
  final bool fresh;
  final MapRouteEstimate? estimate;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = waiting
        ? AppColors.textSecondary
        : fresh
            ? AppColors.success
            : AppColors.error;
    final String title = waiting
        ? 'Waiting for worker location'
        : fresh
            ? 'Worker en route'
            : 'Worker location may be stale';
    final String subtitle = estimate == null
        ? 'Live tracking starts when the worker shares location.'
        : !fresh && !waiting
            ? '${estimate!.distanceLabel} estimated distance • Try calling artisan if location is quiet'
            : '${estimate!.distanceLabel} estimated distance - ${estimate!.etaLabel} away';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                width: 12 + animation.value * 5,
                height: 12 + animation.value * 5,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.labelMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
