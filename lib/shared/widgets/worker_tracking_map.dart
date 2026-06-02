import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/haversine.dart';

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
        .select('current_lat, current_lng')
        .eq('id', widget.workerId)
        .maybeSingle();
    if (row == null || !mounted) return;
    final lat = (row['current_lat'] as num?)?.toDouble();
    final lng = (row['current_lng'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      _applyWorker(lat, lng);
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
            if (lat != null && lng != null) _applyWorker(lat, lng);
          },
        )
        .subscribe();
  }

  void _applyWorker(double lat, double lng) {
    setState(() => _workerPosition = LatLng(lat, lng));
    final km = haversineKm(widget.jobLat, widget.jobLng, lat, lng);
    widget.onEtaChanged?.call('~${etaMinutes(km)} min away');
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            math.min(widget.jobLat, lat),
            math.min(widget.jobLng, lng),
          ),
          northeast: LatLng(
            math.max(widget.jobLat, lat),
            math.max(widget.jobLng, lng),
          ),
        ),
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
      ),
      if (_workerPosition != null)
        Marker(
          markerId: const MarkerId('worker'),
          position: _workerPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
    };

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: job, zoom: 14),
          markers: markers,
          onMapCreated: (c) => _mapController = c,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }
}
