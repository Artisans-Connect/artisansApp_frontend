import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/maps/map_feature_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Client view: job site + live worker marker via Supabase Realtime on [workers].
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

class _WorkerTrackingMapState extends State<WorkerTrackingMap> {
  RealtimeChannel? _channel;
  LatLng? _workerPosition;
  DateTime? _workerLocationAt;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
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

  void _applyWorker(double lat, double lng, {DateTime? locationAt}) {
    final worker = LatLng(lat, lng);
    final job = LatLng(widget.jobLat, widget.jobLng);
    final estimate = MapRouteEstimate.between(origin: worker, destination: job);
    setState(() {
      _workerPosition = worker;
      _workerLocationAt = locationAt ?? DateTime.now().toUtc();
    });
    widget.onEtaChanged?.call('${estimate.etaLabel} away');
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        MapFeatureHelpers.boundsFor(<LatLng>[job, worker]),
        48,
      ),
    );
  }

  @override
  void dispose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppConstants.googleMapsApiKey.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Configure GOOGLE_MAPS_API_KEY for live tracking.',
            style: AppTypography.bodySmall,
          ),
        ),
      );
    }

    final job = LatLng(widget.jobLat, widget.jobLng);
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('job'),
        position: job,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Job site'),
      ),
      if (_workerPosition != null)
        Marker(
          markerId: const MarkerId('worker'),
          position: _workerPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Worker location'),
        ),
    };
    final polylines = <Polyline>{
      if (_workerPosition != null)
        Polyline(
          polylineId: const PolylineId('worker_to_job'),
          points: <LatLng>[_workerPosition!, job],
          color: AppColors.primary,
          width: 4,
        ),
    };

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(target: job, zoom: 14),
              markers: markers,
              polylines: polylines,
              onMapCreated: (c) {
                _mapController = c;
                if (_workerPosition != null) {
                  _applyWorker(
                    _workerPosition!.latitude,
                    _workerPosition!.longitude,
                    locationAt: _workerLocationAt,
                  );
                }
              },
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
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
                      ? 'Waiting for the worker location...'
                      : MapFeatureHelpers.isFreshLocation(_workerLocationAt)
                          ? 'Estimated route from worker to job site'
                          : 'Worker location may be stale',
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
