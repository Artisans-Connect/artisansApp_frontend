import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/filter_chip.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../navigation/client_navigation.dart';
import '../../services/explore_service.dart';
import '../../../../core/location/device_location_service.dart';

class ExploreArtisansScreen extends StatefulWidget {
  const ExploreArtisansScreen({
    super.key,
    this.initialQuery = '',
    this.initialCategory = '',
    this.initialCategoryId = '',
  });

  final String initialQuery;
  final String initialCategory;
  final String initialCategoryId;

  @override
  State<ExploreArtisansScreen> createState() => _ExploreArtisansScreenState();
}

class _ExploreArtisansScreenState extends State<ExploreArtisansScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedCategoryId = '';
  String _selectedDistance = '';
  String _selectedRating = '';
  late final TextEditingController _searchController;

  List<Map<String, dynamic>> allArtisans = [];
  bool _isLoading = true;
  bool _openingMap = false;
  bool _openingMessages = false;
  final Set<String> _openingChatWorkerIds = <String>{};

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _selectedCategory = widget.initialCategory;
    _selectedCategoryId = widget.initialCategoryId;
    _searchController = TextEditingController(text: _searchQuery);
    _fetchArtisans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchArtisans() async {
    try {
      final loc = await DeviceLocationService.getCurrentOrDefault();
      final rawArtisans = await ExploreService.instance.getArtisans(
        limit: 50,
        lat: loc.latitude,
        lng: loc.longitude,
        categoryId: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
      );
      
      final mappedArtisans = rawArtisans.map((raw) {
        final profile = raw['profiles'] as Map<String, dynamic>? ?? {};
        final name = profile['full_name'] as String? ?? 'Artisan';
        final imageUrl = profile['avatar_url'] as String? ?? '';
        final skills = raw['skills'] as List<dynamic>? ?? [];
        final profession = skills.isNotEmpty ? skills.first.toString() : 'Professional';
        final rating = (raw['rating'] as num?)?.toDouble() ?? 0.0;
        final userId = raw['id'] as String;
        
        return {
          'name': name,
          'profession': profession,
          'rating': rating,
          'reviewCount': 0,
          'imageUrl': imageUrl,
          'location': (profile['location_label'] ?? 'Location not set').toString(),
          'distance': raw['distance_km'] != null ? '${(raw['distance_km'] as num).toStringAsFixed(1)} km' : '',
          'distanceKm': (raw['distance_km'] as num?)?.toDouble(),
          'userId': userId,
          'id': userId,
          'phone': profile['phone'],
          'skills': skills.map((dynamic item) => item.toString()).toList(),
          'profiles': profile,
        };
      }).toList();

      if (mounted) {
        setState(() {
          allArtisans = mappedArtisans;
          _isLoading = false;
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

  List<Map<String, dynamic>> get _filteredArtisans {
    return allArtisans.where((Map<String, dynamic> artisan) {
      final String name = (artisan['name'] as String).toLowerCase();
      final String profession =
          (artisan['profession'] as String).toLowerCase();
      final List<String> skills =
          (artisan['skills'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic item) => item.toString().toLowerCase())
              .toList();
      final String skillText = skills.join(' ');
      final String trimmedQuery = _searchQuery.trim();
      if (trimmedQuery.isNotEmpty) {
        final List<String> queryParts = trimmedQuery.toLowerCase().split(RegExp(r'\s+'));
        for (final String part in queryParts) {
          if (!name.contains(part) && !profession.contains(part) && !skillText.contains(part)) {
            return false;
          }
        }
      }
      if (_selectedCategory.isNotEmpty && _selectedCategoryId.isEmpty) {
        final String category = _selectedCategory.toLowerCase();
        if (!profession.contains(category) && !skillText.contains(category)) {
          return false;
        }
      }
      if (_selectedRating.isNotEmpty) {
        final double minRating =
            double.tryParse(_selectedRating.replaceAll('+', '')) ?? 0;
        final double rating = (artisan['rating'] as num?)?.toDouble() ?? 0;
        if (rating < minRating) return false;
      }
      if (_selectedDistance.isNotEmpty && _selectedDistance != 'Nearby') {
        final double? distance = artisan['distanceKm'] as double?;
        if (distance == null) return false;
        final double maxDistance = double.tryParse(
              _selectedDistance.replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            double.infinity;
        if (distance > maxDistance) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _openMap() async {
    if (_openingMap) return;
    setState(() => _openingMap = true);
    await ClientNavigation.pushFlow(context, AppRoutes.mapDiscovery);
    if (mounted) setState(() => _openingMap = false);
  }

  void _openMessages() {
    if (_openingMessages) return;
    setState(() => _openingMessages = true);
    ClientNavigation.openMessages(context);
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _openingMessages = false);
    });
  }

  Future<void> _openChat(Map<String, dynamic> artisan) async {
    final String workerId = (artisan['id'] ?? artisan['userId'] ?? '').toString();
    if (_openingChatWorkerIds.contains(workerId)) return;
    setState(() => _openingChatWorkerIds.add(workerId));
    await ClientNavigation.openChatForArtisan(context, artisan);
    if (mounted) setState(() => _openingChatWorkerIds.remove(workerId));
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> artisans = _filteredArtisans;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Explore Artisans',
        onBackPressed: () => Navigator.pop(context),
        actions: <Widget>[
          IconButton(
            tooltip: 'Map view',
            onPressed: _openingMap ? null : _openMap,
            icon: _openingMap
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(PhosphorIcons.mapTrifold, color: AppColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: _openingMessages ? null : _openMessages,
            icon: _openingMessages
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    PhosphorIcons.chatCircle,
                    color: AppColors.textPrimary,
                  ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomSearchBar(
                hintText: 'Search by name or skill...',
                controller: _searchController,
                onChanged: (String value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (_selectedCategory.isNotEmpty) ...<Widget>[
                AppFilterChip(
                  label: _selectedCategory,
                  isSelected: true,
                  icon: PhosphorIcons.funnel,
                  onTap: () {
                    setState(() {
                      _selectedCategory = '';
                      _selectedCategoryId = '';
                      _isLoading = true;
                    });
                    _fetchArtisans();
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Text('Filters', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Distance', style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <String>[
                        'Nearby',
                        '< 5 km',
                        '< 10 km',
                        '< 20 km',
                      ].map((String distance) {
                        final bool isSelected = _selectedDistance == distance;
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(
                            label: distance,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedDistance =
                                    isSelected ? '' : distance;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Rating', style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <String>['4.5+', '4.7+', '4.9+']
                          .map((String rating) {
                        final bool isSelected = _selectedRating == rating;
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(
                            label: rating,
                            isSelected: isSelected,
                            icon: PhosphorIcons.star,
                            onTap: () {
                              setState(() {
                                _selectedRating = isSelected ? '' : rating;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              if (!_isLoading)
                Text(
                  '${artisans.length} Artisans Found',
                  style: AppTypography.labelLarge,
                ),
              if (!_isLoading)
                const SizedBox(height: AppSpacing.md),
              if (!_isLoading)
                ...artisans.map((Map<String, dynamic> artisan) {
                  final String name = artisan['name'] as String;
                  final String workerId = (artisan['id'] ?? artisan['userId'] ?? '').toString();
                  final bool openingChat = _openingChatWorkerIds.contains(workerId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLarge),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.artisanProfile,
                              arguments: artisan,
                            );
                          },
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: ArtisanLogoPanel(
                              imageUrl: artisan['imageUrl'] as String?,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.artisanProfile,
                                arguments: artisan,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    name,
                                    style: AppTypography.labelLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    (artisan['profession'] ?? 'Professional').toString(),
                                    style: AppTypography.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        PhosphorIcons.star,
                                        size: 14,
                                        color: Color(0xFFFFC107),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${artisan['rating']}',
                                        style: AppTypography.labelMedium,
                                      ),
                                      const Spacer(),
                                      Text(
                                        (artisan['distance'] ?? '0 km').toString(),
                                        style: AppTypography.bodySmall
                                            .copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Message',
                              onPressed: openingChat ? null : () => _openChat(artisan),
                              icon: openingChat
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
                                      PhosphorIcons.chatCircle,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
