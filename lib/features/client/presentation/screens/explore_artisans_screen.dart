import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/filter_chip.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class ExploreArtisansScreen extends StatefulWidget {
  const ExploreArtisansScreen({Key? key}) : super(key: key);

  @override
  State<ExploreArtisansScreen> createState() => _ExploreArtisansScreenState();
}

class _ExploreArtisansScreenState extends State<ExploreArtisansScreen> {
  String _searchQuery = '';
  String _selectedDistance = '';
  String _selectedRating = '';

  final List<Map<String, dynamic>> allArtisans = [
    {
      'name': 'John Smith',
      'profession': 'Professional Plumber',
      'rating': 4.8,
      'reviewCount': 342,
      'imageUrl': 'https://via.placeholder.com/200?text=John',
      'location': 'Downtown Area',
      'distance': '0.5 km',
    },
    {
      'name': 'Sarah Johnson',
      'profession': 'Expert Electrician',
      'rating': 4.9,
      'reviewCount': 567,
      'imageUrl': 'https://via.placeholder.com/200?text=Sarah',
      'location': 'Central District',
      'distance': '1.2 km',
    },
    {
      'name': 'Mike Wilson',
      'profession': 'Master Carpenter',
      'rating': 4.7,
      'reviewCount': 234,
      'imageUrl': 'https://via.placeholder.com/200?text=Mike',
      'location': 'Riverside',
      'distance': '2.1 km',
    },
    {
      'name': 'Emma Davis',
      'profession': 'Professional Cleaner',
      'rating': 4.9,
      'reviewCount': 412,
      'imageUrl': 'https://via.placeholder.com/200?text=Emma',
      'location': 'North End',
      'distance': '1.8 km',
    },
    {
      'name': 'Robert Brown',
      'profession': 'HVAC Specialist',
      'rating': 4.6,
      'reviewCount': 289,
      'imageUrl': 'https://via.placeholder.com/200?text=Robert',
      'location': 'East Side',
      'distance': '2.5 km',
    },
    {
      'name': 'Lisa Anderson',
      'profession': 'Interior Designer',
      'rating': 4.8,
      'reviewCount': 198,
      'imageUrl': 'https://via.placeholder.com/200?text=Lisa',
      'location': 'West Point',
      'distance': '3.0 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Explore Artisans',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              CustomSearchBar(
                hintText: 'Search by name or skill...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Filters
              Text(
                'Filters',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Distance Filter
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Nearby', '< 5 km', '< 10 km', '< 20 km']
                          .map((distance) {
                        final isSelected = _selectedDistance == distance;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(
                            label: distance,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedDistance = isSelected ? '' : distance;
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

              // Rating Filter
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['4.5+', '4.7+', '4.9+']
                          .map((rating) {
                        final isSelected = _selectedRating == rating;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(
                            label: rating,
                            isSelected: isSelected,
                            icon: Icons.star,
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

              // Results
              Text(
                '${allArtisans.length} Artisans Found',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.md),

              // Artisans List
              Column(
                children: List.generate(
                  allArtisans.length,
                  (index) {
                    final artisan = allArtisans[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.artisanProfile,
                            arguments: artisan,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            child: Row(
                              children: [
                                // Image
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Image.network(
                                    artisan['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.surfaceContainer,
                                        child: Icon(
                                          Icons.person,
                                          color: AppColors.outlineVariant,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          artisan['name'],
                                          style: AppTypography.labelLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          artisan['profession'],
                                          style: AppTypography.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: Color(0xFFFFC107),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${artisan['rating']}',
                                                  style: AppTypography.labelMedium,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              artisan['distance'],
                                              style: AppTypography.bodySmall.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Bookmark Icon
                                const Padding(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  child: Icon(
                                    Icons.bookmark_border,
                                    color: AppColors.outlineVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
