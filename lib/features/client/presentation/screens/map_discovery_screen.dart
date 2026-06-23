import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/location/device_location_service.dart';
import '../../../../core/maps/map_feature_helpers.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../../../shared/widgets/mapbox_client_map.dart';
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

  List<MapboxWorkerMarker> get _workerMarkers {
    return <MapboxWorkerMarker>[
      for (var i = 0; i < nearbyWorkers.length; i++)
        if (nearbyWorkers[i]['hasMapLocation'] == true)
          MapboxWorkerMarker(
            id: (nearbyWorkers[i]['id'] ?? i).toString(),
            position: LatLng(
              nearbyWorkers[i]['lat'] as double,
              nearbyWorkers[i]['lng'] as double,
            ),
            kind: _selectedWorkerIndex == i
                ? MapMarkerKind.selectedWorker
                : nearbyWorkers[i]['hasFreshLocation'] == true
                    ? MapMarkerKind.worker
                    : MapMarkerKind.staleWorker,
          ),
    ];
  }

  void _selectWorker(int index) {
    setState(() => _selectedWorkerIndex = index);
  }

  void _selectWorkerById(String workerId) {
    final index = nearbyWorkers.indexWhere(
      (worker) => (worker['id'] ?? '').toString() == workerId,
    );
    if (index >= 0) _selectWorker(index);
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
          });
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

        final double lat = point.position.latitude;
        final double lng = point.position.longitude;
        // A worker only gets a map pin when they have a real, live coordinate.
        // Workers without a shared GPS location ((0,0) sentinel) still appear in
        // the list so they remain discoverable by their stated area.
        final bool hasMapLocation = lat >= -90 &&
            lat <= 90 &&
            lng >= -180 &&
            lng <= 180 &&
            !(lat == 0 && lng == 0);
        final String? locationLabel = profile['location_label']?.toString();

        return {
          'name': point.title,
          'profession': point.subtitle,
          'tradeType': TradeTypeX.fromString(point.subtitle),
          'lat': lat,
          'lng': lng,
          'hasMapLocation': hasMapLocation,
          'locationLabel': locationLabel,
          'distance': hasMapLocation
              ? point.distanceLabel
              : (locationLabel != null && locationLabel.isNotEmpty
                  ? 'Near $locationLabel'
                  : 'Location not shared'),
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
        });
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
        if (category['id'].toString() == _selectedCategoryId) {
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
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOverlayControls() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        border: Border.all(color: AppColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmShadow,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint08,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIcons.magnifyingGlass,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _selectedCategoryId == null
                      ? 'Search services nearby'
                      : _selectedCategoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _MapControlChip(
                  label: 'All',
                  icon: Icons.more_horiz_rounded,
                  selected: _selectedCategoryId == null,
                  onTap: () => _applyCategory(null),
                ),
                ..._categories.map(
                  (category) {
                    final id = category['id'].toString();
                    return _MapControlChip(
                      label: category['name'].toString(),
                      icon: TradeTypeX.fromString(
                        category['name'].toString(),
                      ).icon,
                      selected: _selectedCategoryId == id,
                      onTap: () => _applyCategory(id),
                    );
                  },
                ),
                if (_loadingCategories)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: <double>[5, 10, 15].map((radius) {
              return _MapControlChip(
                label: '${radius.toStringAsFixed(0)} km',
                icon: PhosphorIcons.crosshair,
                selected: _radiusKm == radius,
                dense: true,
                onTap: () => _applyRadius(radius),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String get _selectedCategoryName {
    if (_selectedCategoryId == null) return 'All services';
    for (final category in _categories) {
      if (category['id'].toString() == _selectedCategoryId) {
        return category['name'].toString();
      }
    }
    return 'Selected service';
  }

  /// Presence status for a worker. A worker without a live shared location is
  /// treated as "Offline" — still listed and contactable via their profile,
  /// but not pinned on the map.
  ({String label, Color color, IconData icon}) _statusFor(
    Map<String, dynamic> worker,
  ) {
    final bool hasMapLocation = worker['hasMapLocation'] == true;
    final bool isAvailable = worker['available'] == true;
    final bool isFresh = worker['hasFreshLocation'] == true;
    if (!hasMapLocation) {
      return (
        label: 'Offline',
        color: AppColors.textSecondary,
        icon: PhosphorIcons.wifiSlash,
      );
    }
    if (isAvailable && isFresh) {
      return (
        label: 'Available',
        color: AppColors.success,
        icon: PhosphorIcons.crosshair,
      );
    }
    if (isAvailable) {
      return (
        label: 'Away',
        color: AppColors.accentGold,
        icon: PhosphorIcons.clock,
      );
    }
    return (
      label: 'Busy',
      color: AppColors.textSecondary,
      icon: PhosphorIcons.warningCircle,
    );
  }

  Widget _buildSelectedWorkerPreview() {
    final worker = _selectedWorker;
    if (worker == null) return const SizedBox.shrink();
    final double? rating = worker['rating'] as double?;
    final bool isVerified = worker['verified'] == true;
    final bool isFresh = worker['hasFreshLocation'] == true;
    final bool hasMapLocation = worker['hasMapLocation'] == true;
    final TradeType tradeType =
        worker['tradeType'] as TradeType? ?? TradeType.other;
    final status = _statusFor(worker);

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
                    Text(
                      worker['name'].toString(),
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          tradeType.icon,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            worker['profession'].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _TrustBadge(
                label: status.label,
                icon: status.icon,
                color: status.color,
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
                label: !hasMapLocation
                    ? 'Location not shared'
                    : isFresh
                        ? 'Fresh location'
                        : 'Stale location',
                icon: PhosphorIcons.mapPin,
                color: hasMapLocation && isFresh
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ],
          ),
          if (!hasMapLocation) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.wifiSlash,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'This artisan is offline and not sharing live location. '
                      'Open their profile to view details and reach out.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (hasMapLocation) ...[
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
              ] else
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openWorkerProfile(worker),
                    icon: Icon(PhosphorIcons.user),
                    label: const Text('View profile & contact'),
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

  Widget _buildNoWorkersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryTint08,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            ),
            child: Icon(
              PhosphorIcons.mapPinArea,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No artisans available here yet.',
            style: AppTypography.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We checked your current area for ${_selectedCategoryName.toLowerCase()} within ${_radiusKm.toStringAsFixed(0)} km.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _radiusKm >= 15 ? null : () => _applyRadius(15),
                  icon: Icon(PhosphorIcons.arrowsOutSimple),
                  label: const Text('Widen'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _loadError = null;
                      _isLoading = true;
                    });
                    _fetchNearbyWorkers();
                  },
                  icon: Icon(PhosphorIcons.arrowClockwise),
                  label: const Text('Refresh'),
                ),
              ),
            ],
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
          MapboxWorkerDiscoveryMap(
            userPosition: _userPosition,
            workers: _workerMarkers,
            selectedWorkerId: _selectedWorker == null
                ? null
                : (_selectedWorker!['id'] ?? '').toString(),
            onWorkerSelected: _selectWorkerById,
            radiusKm: _radiusKm,
            heightFactor: 0.72,
          ),
          Positioned(
            left: AppSpacing.gutter,
            right: AppSpacing.gutter,
            top: AppSpacing.md,
            child: SafeArea(
              child: Column(
                children: [
                  _buildMapContextPill(),
                  if (!_locationUnavailable) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildMapOverlayControls(),
                  ],
                ],
              ),
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
                        if (!_locationUnavailable) _buildSelectedWorkerPreview(),

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
                          _buildNoWorkersState(),
                        if (!_isLoading && nearbyWorkers.isNotEmpty)
                          Column(
                            children: [
                              ...List.generate(
                                nearbyWorkers.length,
                                (index) {
                                  final worker = nearbyWorkers[index];
                                  final status = _statusFor(worker);
                                  final double? rating =
                                      worker['rating'] as double?;
                                  final TradeType tradeType =
                                      worker['tradeType'] as TradeType? ??
                                          TradeType.other;
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
                                                        color: status.color.withValues(alpha: 0.1),
                                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            status.icon,
                                                            size: 12,
                                                            color: status.color,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            status.label,
                                                            style: AppTypography.labelSmall.copyWith(
                                                              color: status.color,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: AppSpacing.xs),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Icon(
                                                      tradeType.icon,
                                                      size: 15,
                                                      color: AppColors.primary,
                                                    ),
                                                    const SizedBox(width: 5),
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

class _MapControlChip extends StatelessWidget {
  const _MapControlChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: dense ? AppSpacing.xs : AppSpacing.sm),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 15,
          color: selected ? AppColors.onPrimary : AppColors.textSecondary,
        ),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: selected ? AppColors.onPrimary : AppColors.textSecondary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerLowest,
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.borderSubtle,
        ),
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

enum TradeType { electrician, plumber, carpenter, mason, painter, welder, other }

extension TradeTypeX on TradeType {
  String get label {
    switch (this) {
      case TradeType.electrician:
        return 'Electrician';
      case TradeType.plumber:
        return 'Plumber';
      case TradeType.carpenter:
        return 'Carpenter';
      case TradeType.mason:
        return 'Mason';
      case TradeType.painter:
        return 'Painter';
      case TradeType.welder:
        return 'Welder';
      case TradeType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TradeType.electrician:
        return Icons.bolt_rounded;
      case TradeType.plumber:
        return Icons.water_drop_rounded;
      case TradeType.carpenter:
        return Icons.handyman_rounded;
      case TradeType.mason:
        return Icons.foundation_rounded;
      case TradeType.painter:
        return Icons.format_paint_rounded;
      case TradeType.welder:
        return Icons.local_fire_department_rounded;
      case TradeType.other:
        return Icons.more_horiz_rounded;
    }
  }

  static TradeType fromString(String raw) {
    final String value = raw.toLowerCase();
    if (value.contains('electric')) return TradeType.electrician;
    if (value.contains('plumb')) return TradeType.plumber;
    if (value.contains('carpent')) return TradeType.carpenter;
    if (value.contains('mason')) return TradeType.mason;
    if (value.contains('paint')) return TradeType.painter;
    if (value.contains('weld')) return TradeType.welder;
    return TradeType.other;
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
