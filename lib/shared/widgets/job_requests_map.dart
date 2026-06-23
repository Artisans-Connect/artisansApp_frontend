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
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/worker/presentation/models/worker_job.dart';

bool get _useMapbox => !kIsWeb && AppConstants.mapboxAccessToken.isNotEmpty;
bool get _mapsConfigured =>
    _useMapbox || AppConstants.googleMapsApiKey.isNotEmpty;

mapbox.CircleAnnotationOptions _jobMarkerOption(
  WorkerJob job, {
  required bool selected,
}) {
  final kind = selected
      ? MapMarkerKind.selectedJob
      : job.urgency == JobUrgency.asap || job.isUrgent
          ? MapMarkerKind.urgentJob
          : MapMarkerKind.job;
  return mapbox.CircleAnnotationOptions(
    geometry: mapboxPoint(google.LatLng(job.latitude, job.longitude)),
    circleColor: mapboxArgb(mapboxColorFor(kind, selected: selected)),
    circleRadius: selected ? 13 : 10,
    circleStrokeColor: mapboxArgb(Colors.white),
    circleStrokeWidth: selected ? 4 : 3,
    circleSortKey: selected ? 30 : 20,
    customData: <String, Object>{'jobId': job.id},
  );
}

mapbox.CircleAnnotationOptions _selfMarkerOption(google.LatLng position) {
  return mapbox.CircleAnnotationOptions(
    geometry: mapboxPoint(position),
    circleColor: mapboxArgb(mapboxColorFor(MapMarkerKind.currentUser)),
    circleRadius: 9,
    circleStrokeColor: mapboxArgb(Colors.white),
    circleStrokeWidth: 3,
    circleSortKey: 10,
  );
}

class JobRequestsMapPreview extends StatefulWidget {
  const JobRequestsMapPreview({
    super.key,
    required this.jobs,
    required this.onOpenJob,
    this.height = 190,
  });

  final List<WorkerJob> jobs;
  final ValueChanged<WorkerJob> onOpenJob;
  final double height;

  @override
  State<JobRequestsMapPreview> createState() => _JobRequestsMapPreviewState();
}

class _JobRequestsMapPreviewState extends State<JobRequestsMapPreview> {
  google.LatLng? _workerPosition;
  int _selectedIndex = 0;

  // Mapbox state.
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _markerManager;
  bool _styleReady = false;

  // Google fallback controller.
  google.GoogleMapController? _controller;

  List<WorkerJob> get _jobsWithLocation =>
      widget.jobs.where((job) => job.hasServiceLocation).toList();

  @override
  void initState() {
    super.initState();
    _loadWorkerPosition();
  }

  @override
  void didUpdateWidget(JobRequestsMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobs != widget.jobs && _styleReady) {
      _syncMapboxMarkers();
      _fitVisiblePoints();
    }
  }

  Future<void> _loadWorkerPosition() async {
    final location = await DeviceLocationService.getCurrentOrDefault();
    if (!mounted || location.isFallback) return;
    setState(() {
      _workerPosition = google.LatLng(location.latitude, location.longitude);
    });
    _fitVisiblePoints();
    if (_styleReady) _syncMapboxMarkers();
  }

  List<google.LatLng> get _fitPoints => <google.LatLng>[
        if (_workerPosition != null) _workerPosition!,
        ..._jobsWithLocation
            .map((job) => google.LatLng(job.latitude, job.longitude)),
      ];

  void _fitVisiblePoints() {
    final jobs = _jobsWithLocation;
    if (jobs.isEmpty) return;
    if (_useMapbox) {
      final map = _map;
      if (map == null || !_styleReady) return;
      mapboxFitToPoints(
        map,
        _fitPoints,
        padding: mapbox.MbxEdgeInsets(top: 60, left: 50, bottom: 60, right: 50),
        singlePointZoom: 13,
      );
    } else {
      _controller?.animateCamera(
        google.CameraUpdate.newLatLngBounds(
          MapFeatureHelpers.boundsFor(_fitPoints),
          48,
        ),
      );
    }
  }

  void _selectJobById(String jobId) {
    final jobs = _jobsWithLocation;
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index >= 0) {
      setState(() => _selectedIndex = index);
      _syncMapboxMarkers();
    }
  }

  // ── Mapbox rendering ────────────────────────────────────────────────────
  Future<void> _onMapboxCreated(mapbox.MapboxMap map) async {
    _map = map;
    await map.location.updateSettings(
      mapbox.LocationComponentSettings(enabled: true),
    );
  }

  Future<void> _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;
    _styleReady = true;
    _markerManager ??= await map.annotations.createCircleAnnotationManager();
    _markerManager?.tapEvents(onTap: (annotation) {
      final id = annotation.customData?['jobId']?.toString();
      if (id != null && id.isNotEmpty) _selectJobById(id);
    });
    await _syncMapboxMarkers();
    _fitVisiblePoints();
  }

  Future<void> _syncMapboxMarkers() async {
    final manager = _markerManager;
    if (manager == null) return;
    await manager.deleteAll();
    final jobs = _jobsWithLocation;
    await manager.createMulti(<mapbox.CircleAnnotationOptions>[
      if (_workerPosition != null) _selfMarkerOption(_workerPosition!),
      for (var i = 0; i < jobs.length; i++)
        _jobMarkerOption(jobs[i], selected: i == _selectedIndex),
    ]);
  }

  Set<google.Marker> _markers() {
    final markers = <google.Marker>{
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

    final jobs = _jobsWithLocation;
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      markers.add(
        google.Marker(
          markerId: google.MarkerId('job_request_${job.id}'),
          position: google.LatLng(job.latitude, job.longitude),
          icon: google.BitmapDescriptor.defaultMarkerWithHue(
            MapFeatureHelpers.markerHueFor(
              i == _selectedIndex
                  ? MapMarkerKind.selectedJob
                  : job.urgency == JobUrgency.asap || job.isUrgent
                      ? MapMarkerKind.urgentJob
                      : MapMarkerKind.job,
            ),
          ),
          infoWindow:
              google.InfoWindow(title: job.title, snippet: job.addressLabel),
          onTap: () => setState(() => _selectedIndex = i),
        ),
      );
    }
    return markers;
  }

  void _openExpandedMap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobRequestsMapScreen(
          jobs: widget.jobs,
          onOpenJob: widget.onOpenJob,
          initialWorkerPosition: _workerPosition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _jobsWithLocation;
    if (jobs.isEmpty) return const SizedBox.shrink();
    final selected = jobs[_selectedIndex.clamp(0, jobs.length - 1)];

    if (!_mapsConfigured) {
      return _MapUnavailableCard(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Stack(
          children: <Widget>[
            _useMapbox
                ? _buildMapbox(selected)
                : _buildGoogle(selected),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: _MapHeader(
                title: '${jobs.length} dispatched request${jobs.length == 1 ? '' : 's'}',
                actionLabel: 'Expand',
                onAction: _openExpandedMap,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _JobRequestMapCard(
                job: selected,
                workerPosition: _workerPosition,
                onOpen: () => widget.onOpenJob(selected),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapbox(WorkerJob selected) {
    return mapbox.MapWidget(
      key: const ValueKey<String>('job-requests-preview-mapbox-map'),
      styleUri: kMapboxStyle,
      viewport: mapbox.CameraViewportState(
        center: mapboxPoint(
          google.LatLng(selected.latitude, selected.longitude),
        ),
        zoom: 13,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      onMapCreated: _onMapboxCreated,
      onStyleLoadedListener: _onStyleLoaded,
    );
  }

  Widget _buildGoogle(WorkerJob selected) {
    return google.GoogleMap(
      initialCameraPosition: google.CameraPosition(
        target: google.LatLng(selected.latitude, selected.longitude),
        zoom: 13,
      ),
      markers: _markers(),
      onMapCreated: (controller) {
        _controller = controller;
        _fitVisiblePoints();
      },
      myLocationEnabled: _workerPosition != null,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

class JobRequestsMapScreen extends StatefulWidget {
  const JobRequestsMapScreen({
    super.key,
    required this.jobs,
    required this.onOpenJob,
    this.initialWorkerPosition,
  });

  final List<WorkerJob> jobs;
  final ValueChanged<WorkerJob> onOpenJob;
  final google.LatLng? initialWorkerPosition;

  @override
  State<JobRequestsMapScreen> createState() => _JobRequestsMapScreenState();
}

class _JobRequestsMapScreenState extends State<JobRequestsMapScreen> {
  google.LatLng? _workerPosition;
  int _selectedIndex = 0;

  // Mapbox state.
  mapbox.MapboxMap? _map;
  mapbox.CircleAnnotationManager? _markerManager;
  bool _styleReady = false;

  // Google fallback controller.
  google.GoogleMapController? _controller;

  List<WorkerJob> get _jobsWithLocation =>
      widget.jobs.where((job) => job.hasServiceLocation).toList();

  @override
  void initState() {
    super.initState();
    _workerPosition = widget.initialWorkerPosition;
    if (_workerPosition == null) _loadWorkerPosition();
  }

  Future<void> _loadWorkerPosition() async {
    final location = await DeviceLocationService.getCurrentOrDefault();
    if (!mounted || location.isFallback) return;
    setState(() {
      _workerPosition = google.LatLng(location.latitude, location.longitude);
    });
    _fitVisiblePoints();
    if (_styleReady) _syncMapboxMarkers();
  }

  List<google.LatLng> get _fitPoints => <google.LatLng>[
        if (_workerPosition != null) _workerPosition!,
        ..._jobsWithLocation
            .map((job) => google.LatLng(job.latitude, job.longitude)),
      ];

  void _fitVisiblePoints() {
    final jobs = _jobsWithLocation;
    if (jobs.isEmpty) return;
    if (_useMapbox) {
      final map = _map;
      if (map == null || !_styleReady) return;
      mapboxFitToPoints(
        map,
        _fitPoints,
        padding: mapbox.MbxEdgeInsets(top: 80, left: 64, bottom: 160, right: 64),
        singlePointZoom: 13,
      );
    } else {
      _controller?.animateCamera(
        google.CameraUpdate.newLatLngBounds(
          MapFeatureHelpers.boundsFor(_fitPoints),
          64,
        ),
      );
    }
  }

  void _selectJobById(String jobId) {
    final jobs = _jobsWithLocation;
    final index = jobs.indexWhere((job) => job.id == jobId);
    if (index >= 0) {
      setState(() => _selectedIndex = index);
      _syncMapboxMarkers();
    }
  }

  // ── Mapbox rendering ────────────────────────────────────────────────────
  Future<void> _onMapboxCreated(mapbox.MapboxMap map) async {
    _map = map;
    await map.location.updateSettings(
      mapbox.LocationComponentSettings(enabled: true),
    );
  }

  Future<void> _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;
    _styleReady = true;
    _markerManager ??= await map.annotations.createCircleAnnotationManager();
    _markerManager?.tapEvents(onTap: (annotation) {
      final id = annotation.customData?['jobId']?.toString();
      if (id != null && id.isNotEmpty) _selectJobById(id);
    });
    await _syncMapboxMarkers();
    _fitVisiblePoints();
  }

  Future<void> _syncMapboxMarkers() async {
    final manager = _markerManager;
    if (manager == null) return;
    await manager.deleteAll();
    final jobs = _jobsWithLocation;
    await manager.createMulti(<mapbox.CircleAnnotationOptions>[
      if (_workerPosition != null) _selfMarkerOption(_workerPosition!),
      for (var i = 0; i < jobs.length; i++)
        _jobMarkerOption(jobs[i], selected: i == _selectedIndex),
    ]);
  }

  Set<google.Marker> _markers() {
    final jobs = _jobsWithLocation;
    return <google.Marker>{
      if (_workerPosition != null)
        google.Marker(
          markerId: const google.MarkerId('worker_current_location'),
          position: _workerPosition!,
          icon: google.BitmapDescriptor.defaultMarkerWithHue(
            google.BitmapDescriptor.hueAzure,
          ),
          infoWindow: const google.InfoWindow(title: 'You'),
        ),
      for (var i = 0; i < jobs.length; i++)
        google.Marker(
          markerId: google.MarkerId('job_request_${jobs[i].id}'),
          position: google.LatLng(jobs[i].latitude, jobs[i].longitude),
          icon: google.BitmapDescriptor.defaultMarkerWithHue(
            MapFeatureHelpers.markerHueFor(
              i == _selectedIndex
                  ? MapMarkerKind.selectedJob
                  : jobs[i].urgency == JobUrgency.asap || jobs[i].isUrgent
                      ? MapMarkerKind.urgentJob
                      : MapMarkerKind.job,
            ),
          ),
          infoWindow: google.InfoWindow(
            title: jobs[i].title,
            snippet: jobs[i].addressLabel,
          ),
          onTap: () => setState(() => _selectedIndex = i),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _jobsWithLocation;
    final selected = jobs.isEmpty
        ? null
        : jobs[_selectedIndex.clamp(0, jobs.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Request Map'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: !_mapsConfigured
          ? const _MapUnavailableCard(height: double.infinity)
          : Stack(
              children: <Widget>[
                _useMapbox
                    ? _buildMapbox(selected)
                    : _buildGoogle(selected),
                if (selected != null)
                  Positioned(
                    left: AppSpacing.gutter,
                    right: AppSpacing.gutter,
                    bottom: AppSpacing.gutter,
                    child: _JobRequestMapCard(
                      job: selected,
                      workerPosition: _workerPosition,
                      onOpen: () => widget.onOpenJob(selected),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMapbox(WorkerJob? selected) {
    final center = selected == null
        ? MapFeatureHelpers.accraDefault
        : google.LatLng(selected.latitude, selected.longitude);
    return mapbox.MapWidget(
      key: const ValueKey<String>('job-requests-fullscreen-mapbox-map'),
      styleUri: kMapboxStyle,
      viewport: mapbox.CameraViewportState(
        center: mapboxPoint(center),
        zoom: selected == null ? 12 : 13,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      onMapCreated: _onMapboxCreated,
      onStyleLoadedListener: _onStyleLoaded,
    );
  }

  Widget _buildGoogle(WorkerJob? selected) {
    return google.GoogleMap(
      initialCameraPosition: google.CameraPosition(
        target: selected == null
            ? MapFeatureHelpers.accraDefault
            : google.LatLng(selected.latitude, selected.longitude),
        zoom: selected == null ? 12 : 13,
      ),
      markers: _markers(),
      onMapCreated: (controller) {
        _controller = controller;
        _fitVisiblePoints();
      },
      myLocationEnabled: _workerPosition != null,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(title, style: AppTypography.labelMedium),
            ),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobRequestMapCard extends StatelessWidget {
  const _JobRequestMapCard({
    required this.job,
    required this.workerPosition,
    required this.onOpen,
  });

  final WorkerJob job;
  final google.LatLng? workerPosition;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final estimate = workerPosition == null
        ? null
        : MapRouteEstimate.between(
            origin: workerPosition!,
            destination: google.LatLng(job.latitude, job.longitude),
          );
    final bool urgent = job.urgency == JobUrgency.asap || job.isUrgent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgent ? AppColors.error : AppColors.borderSubtle,
          width: urgent ? 1.4 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    job.title,
                    style: AppTypography.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.addressLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      if (urgent)
                        const _MiniChip(
                          label: 'Urgent',
                          emphasized: true,
                          danger: true,
                        ),
                      _MiniChip(label: job.category),
                      if (estimate != null)
                        _MiniChip(
                          label: '${estimate.distanceLabel} est.',
                          emphasized: true,
                        ),
                      _MiniChip(label: job.estimateDisplay),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FilledButton(
                  onPressed: onOpen,
                  child: const Text('Details'),
                ),
                TextButton(
                  onPressed: job.hasServiceLocation
                      ? () => launchUrl(
                            MapFeatureHelpers.googleMapsDirectionsUri(
                              destination: google.LatLng(job.latitude, job.longitude),
                              origin: workerPosition,
                            ),
                            mode: LaunchMode.externalApplication,
                          )
                      : null,
                  child: const Text('Navigate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    this.emphasized = false,
    this.danger = false,
  });

  final String label;
  final bool emphasized;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized
            ? (danger
                ? AppColors.errorContainer
                : AppColors.primaryFixed.withValues(alpha: 0.7))
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: danger
                ? AppColors.error
                : emphasized
                    ? AppColors.primary
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MapUnavailableCard extends StatelessWidget {
  const _MapUnavailableCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'Configure GOOGLE_MAPS_API_KEY to show dispatched requests on the map.',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
