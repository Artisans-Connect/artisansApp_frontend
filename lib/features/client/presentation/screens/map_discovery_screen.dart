import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/maps/map_feature_helpers.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../services/explore_service.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  final CategoriesService _categoriesService = CategoriesService();
  List<Map<String, dynamic>> nearbyWorkers = [];
  List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[];
  bool _isLoading = true;
  bool _loadingCategories = true;
  bool _locationUnavailable = false;
  String? _loadError;
  LatLng _userPosition = LatLng(
    DeviceLocation.accraDefault.latitude,
    DeviceLocation.accraDefault.longitude,
  );
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  int? _selectedWorkerIndex;
  String? _selectedCategoryId;
  double _radiusKm = 5;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _fetchNearbyWorkers();
  }

  Map<String, dynamic>? get _selectedWorker {
    final index = _selectedWorkerIndex;
    if (index == null || index < 0 || index >= nearbyWorkers.length) {
      return null;
    }
    return nearbyWorkers[index];
  }

  void _rebuildMarkers() {
    final markers = <Marker>{};
    if (!_locationUnavailable) {
      markers.add(
        Marker(
        markerId: const MarkerId('you'),
        position: _userPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You'),
      ),
      );
    }
    for (var i = 0; i < nearbyWorkers.length; i++) {
      final w = nearbyWorkers[i];
      final bool isSelected = _selectedWorkerIndex == i;
      markers.add(
        Marker(
          markerId: MarkerId('worker_${w['id'] ?? i}'),
          position: LatLng(w['lat'] as double, w['lng'] as double),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            MapFeatureHelpers.markerHueFor(
              isSelected
                  ? MapMarkerKind.selectedWorker
                  : w['hasFreshLocation'] == true
                      ? MapMarkerKind.worker
                      : MapMarkerKind.staleWorker,
            ),
          ),
          infoWindow: InfoWindow(
            title: w['name'] as String? ?? 'Artisan',
            snippet: '${w['profession']} • ${w['distance']}',
          ),
          onTap: () => _selectWorker(i, moveCamera: false),
        ),
      );
    }
    _markers = markers;
  }

  void _selectWorker(int index, {bool moveCamera = true}) {
    final worker = nearbyWorkers[index];
    final position = LatLng(worker['lat'] as double, worker['lng'] as double);
    setState(() {
      _selectedWorkerIndex = index;
      _rebuildMarkers();
    });
    if (moveCamera) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
    }
  }

  void _openWorkerProfile(Map<String, dynamic> worker) {
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
  }

  void _requestWorker(Map<String, dynamic> worker) {
    Navigator.pushNamed(
      context,
      AppRoutes.directWorkerRequest,
      arguments: worker,
    );
  }

  Future<void> _loadCategories() async {
    try {
      final raw = await _categoriesService.listCategories();
      if (!mounted) return;
      setState(() {
        _categories = raw
            .whereType<Map<dynamic, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _loadingCategories = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _applyCategory(String? categoryId) async {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedWorkerIndex = null;
      _loadError = null;
      _isLoading = true;
    });
    await _fetchNearbyWorkers();
  }

  Future<void> _applyRadius(double radiusKm) async {
    setState(() {
      _radiusKm = radiusKm;
      _selectedWorkerIndex = null;
      _loadError = null;
      _isLoading = true;
    });
    await _fetchNearbyWorkers();
  }

  Future<void> _fetchNearbyWorkers() async {
    try {
      final loc = await DeviceLocationService.getCurrentOrDefault();
      _userPosition = LatLng(loc.latitude, loc.longitude);
      if (loc.isFallback) {
        if (mounted) {
          setState(() {
            nearbyWorkers = <Map<String, dynamic>>[];
            _selectedWorkerIndex = null;
            _locationUnavailable = true;
            _loadError = null;
            _isLoading = false;
            _rebuildMarkers();
          });
          await _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_userPosition, 11),
          );
        }
        return;
      }

      final rawArtisans = await ExploreService.instance.getArtisans(
        categoryId: _selectedCategoryId,
        lat: loc.latitude,
        lng: loc.longitude,
        radiusKm: _radiusKm,
        limit: 15,
        forceRefresh: true,
      );
      
      final mappedWorkers = rawArtisans.map((raw) {
        final point = MapPoint.workerFromApi(raw);
        final profile = raw['profiles'] as Map<String, dynamic>? ?? {};
        final skills = raw['skills'] as List<dynamic>? ?? [];
        
        return {
          'name': point.title,
          'profession': point.subtitle,
          'lat': point.position.latitude,
          'lng': point.position.longitude,
          'distance': point.distanceLabel,
          'distanceKm': point.distanceKm,
          'rating': point.rating,
          'verified': point.isVerified,
          'available': point.isAvailable,
          'hasFreshLocation': point.hasFreshLocation,
          'imageUrl': point.avatarUrl ?? '',
          'userId': point.id,
          'id': point.id,
          'phone': profile['phone'],
          'profiles': profile,
          'skills': skills.map((dynamic item) => item.toString()).toList(),
        };
      }).toList();

      if (mounted) {
        setState(() {
          nearbyWorkers = mappedWorkers;
          _locationUnavailable = false;
          _loadError = null;
          _isLoading = false;
          _rebuildMarkers();
        });
        final GoogleMapController? controller = _mapController;
        if (controller != null) {
          await controller.animateCamera(
            CameraUpdate.newLatLngZoom(_userPosition, 14),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'Could not load nearby workers. Check your connection and try again.';
          nearbyWorkers = <Map<String, dynamic>>[];
          _selectedWorkerIndex = null;
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMapContextPill() {
    String categoryLabel = 'All services';
    if (_selectedCategoryId != null) {
      for (final category in _categories) {
        if (category['id'] == _selectedCategoryId) {
          categoryLabel = category['name'].toString();
          break;
        }
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.crosshair, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _locationUnavailable
                  ? 'Enable location to find nearby artisans'
                  : '$categoryLabel within ${_radiusKm.toStringAsFixed(0)} km',
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterPill(
                label: 'All',
                selected: _selectedCategoryId == null,
                onTap: () => _applyCategory(null),
              ),
              ..._categories.map(
                (category) {
                  final id = category['id'].toString();
                  return _FilterPill(
                    label: category['name'].toString(),
                    selected: _selectedCategoryId == id,
                    onTap: () => _applyCategory(id),
                  );
                },
              ),
              if (_loadingCategories)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: <double>[5, 10, 15].map((radius) {
            return _FilterPill(
              label: '${radius.toStringAsFixed(0)} km',
              selected: _radiusKm == radius,
              dense: true,
              onTap: () => _applyRadius(radius),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedWorkerPreview() {
    final worker = _selectedWorker;
    if (worker == null) return const SizedBox.shrink();
    final double? rating = worker['rating'] as double?;
    final bool isVerified = worker['verified'] == true;
    final bool isAvailable = worker['available'] == true;
    final bool isFresh = worker['hasFreshLocation'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ArtisanLogoAvatar(
                imageUrl: worker['imageUrl'] as String?,
                size: 54,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker['name'].toString(), style: AppTypography.labelLarge),
                    const SizedBox(height: 3),
                    Text(
                      worker['profession'].toString(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _TrustBadge(
                label: isAvailable && isFresh ? 'Live' : 'Check',
                icon: isAvailable && isFresh
                    ? PhosphorIcons.crosshair
                    : PhosphorIcons.warningCircle,
                color: isAvailable && isFresh
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _TrustBadge(
                label: worker['distance'].toString(),
                icon: PhosphorIcons.mapPin,
                color: AppColors.primary,
              ),
              if (rating != null)
                _TrustBadge(
                  label: rating.toStringAsFixed(1),
                  icon: PhosphorIcons.star,
                  color: AppColors.accentGold,
                ),
              if (isVerified)
                _TrustBadge(
                  label: 'Verified',
                  icon: PhosphorIcons.sealCheck,
                  color: AppColors.success,
                ),
              _TrustBadge(
                label: isFresh ? 'Fresh location' : 'Stale location',
                icon: PhosphorIcons.clock,
                color: isFresh ? AppColors.success : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openWorkerProfile(worker),
                  icon: Icon(PhosphorIcons.user),
                  label: const Text('Profile'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _requestWorker(worker),
                  icon: Icon(PhosphorIcons.paperPlaneTilt),
                  label: const Text('Request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationUnavailableState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.crosshair,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Turn on location to see nearby artisans.',
            style: AppTypography.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We only show nearby workers after getting your current location, so Accra, Kumasi, or any other city will use the user\'s real position.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _loadError = null;
                _isLoading = true;
              });
              _fetchNearbyWorkers();
            },
            icon: Icon(PhosphorIcons.arrowClockwise),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.warningCircle,
            size: 34,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _loadError ?? 'Could not load nearby workers.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _loadError = null;
                _isLoading = true;
              });
              _fetchNearbyWorkers();
            },
            icon: Icon(PhosphorIcons.arrowClockwise),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
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
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
          ),
          Positioned(
            left: AppSpacing.gutter,
            right: AppSpacing.gutter,
            top: AppSpacing.md,
            child: SafeArea(
              child: _buildMapContextPill(),
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
                      color: Colors.black.withValues(alpha: 0.1),
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
                          _locationUnavailable
                              ? 'Location Needed'
                              : _loadError != null
                              ? 'Nearby Workers'
                              : _selectedWorkerIndex == null
                              ? 'Recommended Near You'
                              : 'Selected Artisan',
                          style: AppTypography.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (!_locationUnavailable) ...[
                          _buildFilterControls(),
                          const SizedBox(height: AppSpacing.md),
                          _buildSelectedWorkerPreview(),
                        ],

                        // Workers List
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                        if (!_isLoading && _locationUnavailable)
                          _buildLocationUnavailableState(),
                        if (!_isLoading && _loadError != null)
                          _buildLoadErrorState(),
                        if (!_isLoading &&
                            _loadError == null &&
                            !_locationUnavailable &&
                            nearbyWorkers.isEmpty)
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
                                  final bool isAvailable =
                                      worker['available'] == true;
                                  final bool isFresh =
                                      worker['hasFreshLocation'] == true;
                                  final double? rating =
                                      worker['rating'] as double?;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: GestureDetector(
                                    onTap: () => _selectWorker(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedWorkerIndex == index
                                            ? AppColors.primaryContainer
                                            : AppColors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                                        border: Border.all(
                                          color: _selectedWorkerIndex == index
                                              ? AppColors.primary
                                              : AppColors.borderSubtle,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: Row(
                                        children: [
                                          // Avatar
                                          ArtisanLogoAvatar(
                                            imageUrl: worker['imageUrl'] as String?,
                                            size: 50,
                                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
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
                                                        color: isAvailable && isFresh
                                                            ? AppColors.success.withValues(alpha: 0.1)
                                                            : AppColors.outlineVariant.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                                      ),
                                                      child: Text(
                                                        isAvailable
                                                            ? isFresh
                                                                ? 'Available'
                                                                : 'Stale'
                                                            : 'Busy',
                                                        style: AppTypography.labelSmall.copyWith(
                                                          color: isAvailable && isFresh
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
                                                        if (worker['verified'] == true) ...[
                                                          Icon(
                                                            PhosphorIcons.sealCheck,
                                                            size: 14,
                                                            color: AppColors.success,
                                                          ),
                                                          const SizedBox(width: 4),
                                                        ],
                                                        if (rating != null) ...[
                                                          Icon(
                                                            PhosphorIcons.star,
                                                            size: 14,
                                                            color: AppColors.accentGold,
                                                          ),
                                                          const SizedBox(width: 3),
                                                          Text(
                                                            rating.toStringAsFixed(1),
                                                            style: AppTypography.bodySmall,
                                                          ),
                                                          const SizedBox(width: 8),
                                                        ],
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
                                          IconButton(
                                            onPressed: () => _openWorkerProfile(worker),
                                            icon: Icon(
                                              PhosphorIcons.caretRight,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                            tooltip: 'View profile',
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

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: dense ? AppSpacing.xs : AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: selected ? AppColors.onPrimary : AppColors.textSecondary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerLowest,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.outlineVariant,
        ),
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
