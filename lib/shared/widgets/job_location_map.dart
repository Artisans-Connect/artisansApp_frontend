import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Map centered on [initial]; calls [onPositionChanged] when the user drags the map.
class JobLocationMap extends StatefulWidget {
  const JobLocationMap({
    super.key,
    required this.initial,
    this.onPositionChanged,
    this.height = 200,
  });

  final LatLng initial;
  final ValueChanged<LatLng>? onPositionChanged;
  final double height;

  @override
  State<JobLocationMap> createState() => _JobLocationMapState();
}

class _JobLocationMapState extends State<JobLocationMap> {
  GoogleMapController? _controller;
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    _center = widget.initial;
  }

  @override
  void didUpdateWidget(JobLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _center = widget.initial;
      _controller?.animateCamera(CameraUpdate.newLatLng(widget.initial));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppConstants.googleMapsApiKey.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Add GOOGLE_MAPS_API_KEY to .env and native config to show the map.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15,
              ),
              onMapCreated: (c) => _controller = c,
              onCameraMove: (pos) => _center = pos.target,
              onCameraIdle: () => widget.onPositionChanged?.call(_center),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
            Icon(Icons.location_on, color: AppColors.primary, size: 40),
          ],
        ),
      ),
    );
  }
}
