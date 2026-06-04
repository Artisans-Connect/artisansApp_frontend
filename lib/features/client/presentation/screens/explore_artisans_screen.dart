import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/filter_chip.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../navigation/client_navigation.dart';
import '../../services/explore_service.dart';

class ExploreArtisansScreen extends StatefulWidget {
  const ExploreArtisansScreen({super.key});

  @override
  State<ExploreArtisansScreen> createState() => _ExploreArtisansScreenState();
}

class _ExploreArtisansScreenState extends State<ExploreArtisansScreen> {
  String _searchQuery = '';
  String _selectedDistance = '';
  String _selectedRating = '';
  final Set<String> _savedArtisanNames = <String>{};

  List<Map<String, dynamic>> allArtisans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtisans();
  }

  Future<void> _fetchArtisans() async {
    try {
      final rawArtisans = await ExploreService.instance.getArtisans(limit: 50);
      
      final mappedArtisans = rawArtisans.map((raw) {
        final profile = raw['profiles'] as Map<String, dynamic>? ?? {};
        final name = profile['full_name'] as String? ?? 'Artisan';
        final imageUrl = profile['avatar_url'] as String? ?? 'https://via.placeholder.com/200?text=Artisan';
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
          'location': 'Location not set',
          'distance': raw['distance_km'] != null ? '${(raw['distance_km'] as num).toStringAsFixed(1)} km' : 'N/A',
          'userId': userId,
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
      if (_searchQuery.isNotEmpty) {
        final String q = _searchQuery.toLowerCase();
        if (!name.contains(q) && !profession.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  void _toggleSaved(String name) {
    setState(() {
      if (_savedArtisanNames.contains(name)) {
        _savedArtisanNames.remove(name);
      } else {
        _savedArtisanNames.add(name);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _savedArtisanNames.contains(name)
              ? 'Saved $name'
              : 'Removed $name from saved',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
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
            onPressed: () =>
                ClientNavigation.pushFlow(context, AppRoutes.mapDiscovery),
            icon: Icon(PhosphorIcons.mapTrifold, color: AppColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: () => ClientNavigation.openMessages(context),
            icon: Icon(
              PhosphorIcons.chatCircle,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            tooltip: 'My profile',
            onPressed: () => ClientNavigation.openOwnProfile(context),
            icon: Icon(PhosphorIcons.user, color: AppColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => ClientNavigation.openSettings(context),
            icon: Icon(PhosphorIcons.gear, color: AppColors.textPrimary),
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
                onChanged: (String value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
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
                final bool isSaved = _savedArtisanNames.contains(name);
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
                            child: Image.network(
                              artisan['imageUrl'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceContainer,
                                child: Icon(PhosphorIcons.user),
                              ),
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
                              onPressed: () => ClientNavigation.openChatForArtisan(
                                context,
                                artisan,
                              ),
                              icon: Icon(
                                PhosphorIcons.chatCircle,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            IconButton(
                              tooltip: isSaved ? 'Unsave' : 'Save',
                              onPressed: () => _toggleSaved(name),
                              icon: Icon(
                                isSaved
                                    ? PhosphorIcons.bookmark
                                    : PhosphorIcons.bookmark,
                                color: isSaved
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                                size: 22,
                              ),
                            ),
                            IconButton(
                              tooltip: 'View profile',
                              onPressed: () {
                                ClientNavigation.openArtisanProfile(
                                  context,
                                  userId: (artisan['userId'] ?? artisan['id'] ?? '').toString(),
                                  name: name,
                                  artisan: artisan,
                                );
                              },
                              icon: Icon(
                                PhosphorIcons.user,
                                color: AppColors.textSecondary,
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
