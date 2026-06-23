import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/location/device_location_service.dart';
import '../../core/maps/map_feature_helpers.dart';
import '../../core/maps/mapbox_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Worker view: current worker position and the client's service location.
///
/// Rendered with Mapbox on mobile; falls back to Google Maps on web or when
/// `MAPBOX_ACCESS_TOKEN` is not configured.
class JobSiteMap extends StatefulWidget {
  const JobSiteMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 220,
    this.label = 'Client',
    this.showDirectionsButton = true,
  });

  final double latitude;
  final double longitude;
  final double height;
  final String label;
  final bool showDirectionsButton;

  @override
  State<JobSiteMap> createState() => _JobSiteMapState();
}

class _JobSiteMapState extends State<JobSiteMap> {
  google.LatLng? _workerPosition;

  // Mapbox state.
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _markerManager;
  mapbox.PolylineAnnotationManager? _routeManager;
  bool _styleReady = false;

  // Google fallback controller.
  google.GoogleMapController? _googleController;

  google.LatLng get _jobSite => google.LatLng(widget.latitude, widget.longitude);

  bool get _useMapbox =>
      !kIsWeb && AppConstants.mapboxAccessToken.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadWorkerLocation();
  }

  Future<void> _loadWorkerLocation() async {
    final loc = await DeviceLocationService.getCurrentOrDefault();
    if (!mounted || loc.isFallback) return;
    setState(() => _workerPosition = google.LatLng(loc.latitude, loc.longitude));
    _fitMap();
    if (_styleReady) _syncMapboxAnnotations();
  }

  List<google.LatLng> get _fitPoints => <google.LatLng>[
        _jobSite,
        if (_workerPosition != null) _workerPosition!,
      ];

  void _fitMap() {
    if (_useMapbox) {
      final map = _map;
      if (map == null || !_styleReady) return;
      mapboxFitToPoints(
        map,
        _fitPoints,
        padding: mapbox.MbxEdgeInsets(top: 70, left: 50, bottom: 70, right: 50),
        singlePointZoom: 15,
      );
    } else {
      final controller = _googleController;
      final worker = _workerPosition;
      if (controller == null || worker == null) return;
      controller.animateCamera(
        google.CameraUpdate.newLatLngBounds(
          MapFeatureHelpers.boundsFor(<google.LatLng>[worker, _jobSite]),
          48,
        ),
      );
    }
  }

  Future<void> _openDirections() async {
    final uri = MapFeatureHelpers.googleMapsDirectionsUri(
      destination: _jobSite,
      origin: _workerPosition,
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Mapbox rendering ──────────────────────────────────────────────────────

  Future<void> _onMapboxCreated(mapbox.MapboxMap map) async {
    _map = map;
    await map.location.updateSettings(
      mapbox.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
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

    await markerManager.deleteAll();
    await routeManager.deleteAll();

    await markerManager.createMulti(<mapbox.CircleAnnotationOptions>[
      mapbox.CircleAnnotationOptions(
        geometry: mapboxPoint(_jobSite),
        circleColor: mapboxArgb(mapboxColorFor(MapMarkerKind.job)),
        circleRadius: 11,
        circleStrokeColor: mapboxArgb(Colors.white),
        circleStrokeWidth: 3,
        circleSortKey: 20,
      ),
      if (_workerPosition != null)
        mapbox.CircleAnnotationOptions(
          geometry: mapboxPoint(_workerPosition!),
          circleColor: mapboxArgb(mapboxColorFor(MapMarkerKind.currentUser)),
          circleRadius: 10,
          circleStrokeColor: mapboxArgb(Colors.white),
          circleStrokeWidth: 3,
          circleSortKey: 10,
        ),
    ]);

    if (_workerPosition != null) {
      await routeManager.create(
        mapbox.PolylineAnnotationOptions(
          geometry: mapbox.LineString.fromPoints(
            points: <mapbox.Point>[
              mapboxPoint(_workerPosition!),
              mapboxPoint(_jobSite),
            ],
          ),
          lineColor: mapboxArgb(AppColors.primary),
          lineWidth: 4,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_useMapbox && AppConstants.googleMapsApiKey.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Configure MAPBOX_ACCESS_TOKEN or GOOGLE_MAPS_API_KEY for the navigation map.',
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
            destination: _jobSite,
          );

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: <Widget>[
            _useMapbox ? _buildMapbox() : _buildGoogle(),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Text(
                  _workerPosition == null
                      ? 'Job site location'
                      : '${estimate!.distanceLabel} estimated route to client',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (widget.showDirectionsButton)
              Positioned(
                right: 12,
                bottom: 12,
                child: FilledButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Directions'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapbox() {
    return mapbox.MapWidget(
      key: const ValueKey<String>('job-site-mapbox-map'),
      styleUri: kMapboxStyle,
      viewport: mapbox.CameraViewportState(
        center: mapboxPoint(_workerPosition ?? _jobSite),
        zoom: _workerPosition == null ? 15 : 13,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      onMapCreated: _onMapboxCreated,
      onStyleLoadedListener: _onStyleLoaded,
    );
  }

  Widget _buildGoogle() {
    final markers = <google.Marker>{
      google.Marker(
        markerId: const google.MarkerId('job_site'),
        position: _jobSite,
        icon: google.BitmapDescriptor.defaultMarkerWithHue(
          google.BitmapDescriptor.hueOrange,
        ),
        infoWindow:
            google.InfoWindow(title: widget.label, snippet: 'Job site'),
      ),
      if (_workerPosition != null)
        google.Marker(
          markerId: const google.MarkerId('worker_current_location'),
          position: _workerPosition!,
          icon: google.BitmapDescriptor.defaultMarkerWithHue(
            google.BitmapDescriptor.hueAzure,
          ),
          infoWindow: const google.InfoWindow(title: 'You'),
        ),
    };
    final polylines = <google.Polyline>{
      if (_workerPosition != null)
        google.Polyline(
          polylineId: const google.PolylineId('worker_to_job_site'),
          points: <google.LatLng>[_workerPosition!, _jobSite],
          color: AppColors.primary,
          width: 4,
        ),
    };

    return google.GoogleMap(
      initialCameraPosition: google.CameraPosition(
        target: _workerPosition ?? _jobSite,
        zoom: _workerPosition == null ? 15 : 13,
      ),
      markers: markers,
      polylines: polylines,
      onMapCreated: (controller) {
        _googleController = controller;
        _fitMap();
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: true,
    );
  }
}
