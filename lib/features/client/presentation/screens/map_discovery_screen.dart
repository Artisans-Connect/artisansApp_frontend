import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> categories = ['All Artisans', 'Pottery', 'Woodworking', 'Jewelry'];

  final List<Map<String, dynamic>> artisansOnMap = [
    {
      'name': 'Marcus',
      'image': 'https://via.placeholder.com/80?text=Marcus',
      'top': 0.25,
      'left': 0.35,
    },
    {
      'name': 'Taskdey?',
      'image': 'https://via.placeholder.com/80?text=Taskdey',
      'top': 0.45,
      'left': 0.6,
    },
    {
      'name': 'Artisans',
      'image': 'https://via.placeholder.com/80?text=Artisans',
      'top': 0.65,
      'left': 0.25,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Artisans',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey[400],
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Background
          Container(
            color: Colors.grey[400],
            child: Icon(
              Icons.map,
              size: 120,
              color: Colors.grey[500],
            ),
          ),

          // Artisan Pins on Map
          Stack(
            children: artisansOnMap
                .map((artisan) {
                  return Positioned(
                    top: MediaQuery.of(context).size.height * artisan['top'],
                    left: MediaQuery.of(context).size.width * artisan['left'],
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 4,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(
                          artisan['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceContainer,
                              child: const Icon(Icons.person),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          ),

          // Top Search and Category Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            style: AppTypography.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search for artisans...',
                              hintStyle: AppTypography.bodyMedium.copyWith(
                                color: Colors.grey[500],
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.filter_list, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        final isSelected = index == _selectedCategoryIndex;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                              ),
                              child: Text(
                                categories[index],
                                style: AppTypography.labelMedium.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Artisan Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Artisan Image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            color: Colors.grey[800],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            child: Image.network(
                              'https://via.placeholder.com/100?text=Elena',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Artisan Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Elena Rossi',
                                              style: AppTypography.labelLarge.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.sm),
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                            Text(
                                              ' 4.9',
                                              style: AppTypography.labelMedium.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'Master Textile Artist',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FloatingActionButton(
                                    mini: true,
                                    backgroundColor: AppColors.primary,
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.artisanProfile,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '1.2 km away',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Next: 2PM',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Bottom Navigation Bar
                  BottomNavigationBar(
                    backgroundColor: AppColors.surface,
                    elevation: 0,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.explore, color: AppColors.primary),
                        label: 'EXPLORE',
                        activeIcon: Icon(Icons.explore, color: AppColors.primary),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
                        label: 'BOOKINGS',
                        activeIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person, color: AppColors.textSecondary),
                        label: 'PROFILE',
                        activeIcon: Icon(Icons.person, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
