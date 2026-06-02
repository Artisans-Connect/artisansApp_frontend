import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_typography.dart';

/// Worker view: navigate to client job site.
class JobSiteMap extends StatelessWidget {
  const JobSiteMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 220,
    this.label = 'Client',
  });

  final double latitude;
  final double longitude;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (AppConstants.googleMapsApiKey.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Configure GOOGLE_MAPS_API_KEY for navigation map.',
            style: AppTypography.bodySmall,
          ),
        ),
      );
    }

    final target = LatLng(latitude, longitude);
    return SizedBox(
      height: height,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: target, zoom: 15),
        markers: {
          Marker(
            markerId: const MarkerId('job_site'),
            position: target,
            infoWindow: InfoWindow(title: label),
          ),
        },
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
