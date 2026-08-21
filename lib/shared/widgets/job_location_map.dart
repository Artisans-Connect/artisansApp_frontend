import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:artisans_app/shared/widgets/mapbox_maps.dart';

/// Map centered on [initial]; calls [onPositionChanged] when the user drags the map.
///
/// The visual renderer is Mapbox for the client-facing location picker. Google
/// Places remains responsible for address search and reverse geocoding.
class JobLocationMap extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MapboxJobLocationMap(
      initial: initial,
      height: height,
      onPositionChanged: onPositionChanged,
    );
  }
}
