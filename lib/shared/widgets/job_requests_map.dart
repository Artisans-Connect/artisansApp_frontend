import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/location/device_location_service.dart';
import '../../core/maps/map_feature_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/worker/presentation/models/worker_job.dart';

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
  LatLng? _workerPosition;
  GoogleMapController? _controller;
  int _selectedIndex = 0;

  List<WorkerJob> get _jobsWithLocation =>
      widget.jobs.where((job) => job.hasServiceLocation).toList();

  @override
  void initState() {
    super.initState();
    _loadWorkerPosition();
  }

  Future<void> _loadWorkerPosition() async {
    final location = await DeviceLocationService.getCurrentOrDefault();
    if (!mounted || location.isFallback) return;
    setState(() {
      _workerPosition = LatLng(location.latitude, location.longitude);
    });
    _fitVisiblePoints();
  }

  void _fitVisiblePoints() {
    final controller = _controller;
    final jobs = _jobsWithLocation;
    if (controller == null || jobs.isEmpty) return;

    final points = <LatLng>[
      if (_workerPosition != null) _workerPosition!,
      ...jobs.map((job) => LatLng(job.latitude, job.longitude)),
    ];
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(MapFeatureHelpers.boundsFor(points), 48),
    );
  }

  Set<Marker> _markers() {
    final markers = <Marker>{
      if (_workerPosition != null)
        Marker(
          markerId: const MarkerId('worker_current_location'),
          position: _workerPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You'),
        ),
    };

    final jobs = _jobsWithLocation;
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      markers.add(
        Marker(
          markerId: MarkerId('job_request_${job.id}'),
          position: LatLng(job.latitude, job.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == _selectedIndex
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(title: job.title, snippet: job.addressLabel),
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

    if (AppConstants.googleMapsApiKey.isEmpty) {
      return _MapUnavailableCard(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(selected.latitude, selected.longitude),
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
            ),
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
  final LatLng? initialWorkerPosition;

  @override
  State<JobRequestsMapScreen> createState() => _JobRequestsMapScreenState();
}

class _JobRequestsMapScreenState extends State<JobRequestsMapScreen> {
  LatLng? _workerPosition;
  GoogleMapController? _controller;
  int _selectedIndex = 0;

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
      _workerPosition = LatLng(location.latitude, location.longitude);
    });
    _fitVisiblePoints();
  }

  void _fitVisiblePoints() {
    final controller = _controller;
    final jobs = _jobsWithLocation;
    if (controller == null || jobs.isEmpty) return;
    final points = <LatLng>[
      if (_workerPosition != null) _workerPosition!,
      ...jobs.map((job) => LatLng(job.latitude, job.longitude)),
    ];
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(MapFeatureHelpers.boundsFor(points), 64),
    );
  }

  Set<Marker> _markers() {
    final jobs = _jobsWithLocation;
    return <Marker>{
      if (_workerPosition != null)
        Marker(
          markerId: const MarkerId('worker_current_location'),
          position: _workerPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      for (var i = 0; i < jobs.length; i++)
        Marker(
          markerId: MarkerId('job_request_${jobs[i].id}'),
          position: LatLng(jobs[i].latitude, jobs[i].longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == _selectedIndex
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
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
      body: AppConstants.googleMapsApiKey.isEmpty
          ? const _MapUnavailableCard(height: double.infinity)
          : Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selected == null
                        ? MapFeatureHelpers.accraDefault
                        : LatLng(selected.latitude, selected.longitude),
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
                ),
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
  final LatLng? workerPosition;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final estimate = workerPosition == null
        ? null
        : MapRouteEstimate.between(
            origin: workerPosition!,
            destination: LatLng(job.latitude, job.longitude),
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
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
            FilledButton(
              onPressed: onOpen,
              child: const Text('Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized
            ? AppColors.primaryFixed.withValues(alpha: 0.7)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: emphasized ? AppColors.primary : AppColors.textSecondary,
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
