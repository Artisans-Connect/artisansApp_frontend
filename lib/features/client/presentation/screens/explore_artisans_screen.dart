import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/search_bar.dart';

class ExploreArtisansScreen extends StatefulWidget {
  const ExploreArtisansScreen({Key? key}) : super(key: key);

  @override
  State<ExploreArtisansScreen> createState() => _ExploreArtisansScreenState();
}

class _ExploreArtisansScreenState extends State<ExploreArtisansScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> categories = ['All', 'Home', 'Technical', 'Personal'];

  final List<Map<String, dynamic>> allArtisans = [
    {
      'name': 'Sarah Jenkins',
      'profession': 'Master Electrician',
      'rating': 4.9,
      'skills': ['Wiring', 'Installations'],
      'hourlyRate': '\$85',
      'imageUrl': 'https://via.placeholder.com/200?text=Sarah',
    },
    {
      'name': 'David Chen',
      'profession': 'Custom Carpentry',
      'rating': 5.0,
      'skills': ['Furniture', 'Restoration'],
      'hourlyRate': '\$120',
      'imageUrl': 'https://via.placeholder.com/200?text=David',
    },
    {
      'name': 'Marcus Chen',
      'profession': 'Master Electrician',
      'rating': 4.9,
      'skills': ['Wiring', 'Repairs'],
      'hourlyRate': '\$90',
      'imageUrl': 'https://via.placeholder.com/200?text=Marcus',
    },
    {
      'name': 'Amara Okafor',
      'profession': 'Plumbing Expert',
      'rating': 4.8,
      'skills': ['Repairs', 'Installation'],
      'hourlyRate': '\$75',
      'imageUrl': 'https://via.placeholder.com/200?text=Amara',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
          'ConnectFlow',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              CustomSearchBar(
                hintText: 'Search for artisans, skills, or services..',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                            border: !isSelected
                                ? Border.all(color: AppColors.outlineVariant)
                                : null,
                          ),
                          child: Text(
                            category,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Featured Artisans Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Artisans',
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Artisans List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allArtisans.length,
                itemBuilder: (context, index) {
                  final artisan = allArtisans[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Artisan Image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.surfaceContainer,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    artisan['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.surfaceContainer,
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: AppColors.outlineVariant,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              // Artisan Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      artisan['name'],
                                      style: AppTypography.displaySmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      artisan['profession'],
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Wrap(
                                      spacing: 8,
                                      children: (artisan['skills'] as List<String>)
                                          .map((skill) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            skill,
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
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
                                    Icons.star,
                                    size: 16,
                                    color: const Color(0xFFFFA500),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${artisan['rating']}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                artisan['hourlyRate'],
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.artisanProfile,
                                    arguments: artisan,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.sm,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                                  ),
                                ),
                                child: Text(
                                  'Book Now',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
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
    );
  }
}
