import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../services/explore_service.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  List<Map<String, dynamic>> nearbyWorkers = [];
  bool _isLoading = true;
  LatLng _userPosition = LatLng(
    DeviceLocation.accraDefault.latitude,
    DeviceLocation.accraDefault.longitude,
  );
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchNearbyWorkers();
  }

  void _rebuildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('you'),
        position: _userPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You'),
      ),
    };
    for (var i = 0; i < nearbyWorkers.length; i++) {
      final w = nearbyWorkers[i];
      markers.add(
        Marker(
          markerId: MarkerId('worker_$i'),
          position: LatLng(w['lat'] as double, w['lng'] as double),
          infoWindow: InfoWindow(title: w['name'] as String? ?? 'Artisan'),
        ),
      );
    }
    _markers = markers;
  }

  Future<void> _fetchNearbyWorkers() async {
    try {
      final loc = await DeviceLocationService.getCurrentOrDefault();
      _userPosition = LatLng(loc.latitude, loc.longitude);

      final rawArtisans = await ExploreService.instance.getArtisans(
        lat: loc.latitude,
        lng: loc.longitude,
        radiusKm: 5,
        limit: 15,
      );
      
      final mappedWorkers = rawArtisans.map((raw) {
        final profile = raw['profiles'] as Map<String, dynamic>? ?? {};
        final name = profile['full_name'] as String? ?? 'Artisan';
        final imageUrl = profile['avatar_url'] as String? ?? 'https://via.placeholder.com/200?text=Artisan';
        final skills = raw['skills'] as List<dynamic>? ?? [];
        final profession = skills.isNotEmpty ? skills.first.toString() : 'Professional';
        final distanceKm = raw['distance_km'] as num?;
        
        return {
          'name': name,
          'profession': profession,
          'lat': raw['current_lat'] ?? 0.0,
          'lng': raw['current_lng'] ?? 0.0,
          'distance': distanceKm != null ? '${distanceKm.toStringAsFixed(1)} km' : 'N/A',
          'available': raw['is_available'] == true,
          'imageUrl': imageUrl,
          'userId': raw['id'],
        };
      }).toList();

      if (mounted) {
        setState(() {
          nearbyWorkers = mappedWorkers;
          _isLoading = false;
          _rebuildMarkers();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Nearby Workers',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            child: AppConstants.googleMapsApiKey.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'Add GOOGLE_MAPS_API_KEY to .env (Maps JavaScript API enabled for web).',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _userPosition,
                      zoom: 13,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
          ),

          // Bottom Sheet - Nearby Workers
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusXLarge),
                    topRight: Radius.circular(AppSpacing.radiusXLarge),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle indicator
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.outlineVariant,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          'Available Near You',
                          style: AppTypography.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Workers List
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                        if (!_isLoading && nearbyWorkers.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: Text('No workers found nearby.'),
                            ),
                          ),
                        if (!_isLoading && nearbyWorkers.isNotEmpty)
                          Column(
                            children: [
                              ...List.generate(
                                nearbyWorkers.length,
                                (index) {
                                  final worker = nearbyWorkers[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.artisanProfile,
                                        arguments: {
                                          'name': worker['name'],
                                          'profession': worker['profession'],
                                          'location': 'Nearby',
                                          'imageUrl': worker['imageUrl'],
                                          'userId': worker['userId'],
                                        },
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                                        border: Border.all(color: AppColors.borderSubtle),
                                      ),
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: Row(
                                        children: [
                                          // Avatar
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryContainer,
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                                            ),
                                            child: Icon(
                                              PhosphorIcons.user,
                                              color: AppColors.onPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          // Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      worker['name'],
                                                      style: AppTypography.labelLarge,
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: AppSpacing.sm,
                                                        vertical: AppSpacing.xs,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: worker['available']
                                                            ? AppColors.success.withOpacity(0.1)
                                                            : AppColors.outlineVariant.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                                      ),
                                                      child: Text(
                                                        worker['available'] ? 'Available' : 'Busy',
                                                        style: AppTypography.labelSmall.copyWith(
                                                          color: worker['available']
                                                              ? AppColors.success
                                                              : AppColors.textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: AppSpacing.xs),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      worker['profession'],
                                                      style: AppTypography.bodySmall,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          PhosphorIcons.mapPin,
                                                          size: 14,
                                                          color: AppColors.outlineVariant,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          worker['distance'],
                                                          style: AppTypography.bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // View Profile Icon
                                          Icon(
                                            PhosphorIcons.caretRight,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Loading more workers...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Load More Workers',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
