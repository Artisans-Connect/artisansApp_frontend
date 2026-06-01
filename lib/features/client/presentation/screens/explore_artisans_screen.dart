import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/filter_chip.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../navigation/client_navigation.dart';

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

  final List<Map<String, dynamic>> allArtisans = <Map<String, dynamic>>[
    {
      'name': 'John Smith',
      'profession': 'Professional Plumber',
      'rating': 4.8,
      'reviewCount': 342,
      'imageUrl': 'https://via.placeholder.com/200?text=John',
      'location': 'Downtown Area',
      'distance': '0.5 km',
      'userId': 'worker-john',
    },
    {
      'name': 'Sarah Johnson',
      'profession': 'Expert Electrician',
      'rating': 4.9,
      'reviewCount': 567,
      'imageUrl': 'https://via.placeholder.com/200?text=Sarah',
      'location': 'Central District',
      'distance': '1.2 km',
      'userId': 'worker-sarah',
    },
    {
      'name': 'Mike Wilson',
      'profession': 'Master Carpenter',
      'rating': 4.7,
      'reviewCount': 234,
      'imageUrl': 'https://via.placeholder.com/200?text=Mike',
      'location': 'Riverside',
      'distance': '2.1 km',
      'userId': 'worker-mike',
    },
    {
      'name': 'Emma Davis',
      'profession': 'Professional Cleaner',
      'rating': 4.9,
      'reviewCount': 412,
      'imageUrl': 'https://via.placeholder.com/200?text=Emma',
      'location': 'North End',
      'distance': '1.8 km',
      'userId': 'worker-emma',
    },
    {
      'name': 'Robert Brown',
      'profession': 'HVAC Specialist',
      'rating': 4.6,
      'reviewCount': 289,
      'imageUrl': 'https://via.placeholder.com/200?text=Robert',
      'location': 'East Side',
      'distance': '2.5 km',
      'userId': 'worker-robert',
    },
    {
      'name': 'Lisa Anderson',
      'profession': 'Interior Designer',
      'rating': 4.8,
      'reviewCount': 198,
      'imageUrl': 'https://via.placeholder.com/200?text=Lisa',
      'location': 'West Point',
      'distance': '3.0 km',
      'userId': 'worker-lisa',
    },
  ];

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
            icon: Icon(PhosphorIcons.mapTrifold(), color: AppColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: () => ClientNavigation.openMessages(context),
            icon: Icon(
              PhosphorIcons.chatCircle(),
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            tooltip: 'My profile',
            onPressed: () => ClientNavigation.openOwnProfile(context),
            icon: Icon(PhosphorIcons.user(), color: AppColors.textPrimary),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => ClientNavigation.openSettings(context),
            icon: Icon(PhosphorIcons.gear(), color: AppColors.textPrimary),
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
                            icon: PhosphorIcons.star(),
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
              Text(
                '${artisans.length} Artisans Found',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.md),
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
                                child: Icon(PhosphorIcons.user()),
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
                                    artisan['profession'] as String,
                                    style: AppTypography.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        PhosphorIcons.star(),
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
                                        artisan['distance'] as String,
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
                                PhosphorIcons.chatCircle(),
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            IconButton(
                              tooltip: isSaved ? 'Unsave' : 'Save',
                              onPressed: () => _toggleSaved(name),
                              icon: Icon(
                                isSaved
                                    ? PhosphorIcons.bookmark()
                                    : PhosphorIcons.bookmark(),
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
                                  userId: artisan['userId'] as String,
                                  name: name,
                                );
                              },
                              icon: Icon(
                                PhosphorIcons.user(),
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
