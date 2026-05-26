import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../widgets/artisan_card.dart';
import '../widgets/category_chip.dart';
import '../../../../shared/widgets/search_bar.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';

  final List<Map<String, dynamic>> categories = [
    {'label': 'Plumbing', 'icon': Icons.plumbing},
    {'label': 'Electrical', 'icon': Icons.flash_on},
    {'label': 'Carpentry', 'icon': Icons.handyman},
    {'label': 'Cleaning', 'icon': Icons.cleaning_services},
    {'label': 'Painting', 'icon': Icons.palette},
  ];

  final List<Map<String, dynamic>> featuredArtisans = [
    {
      'name': 'John Smith',
      'profession': 'Professional Plumber',
      'rating': 4.8,
      'reviewCount': 342,
      'imageUrl': 'https://via.placeholder.com/200?text=John',
      'location': 'Downtown Area',
    },
    {
      'name': 'Sarah Johnson',
      'profession': 'Expert Electrician',
      'rating': 4.9,
      'reviewCount': 567,
      'imageUrl': 'https://via.placeholder.com/200?text=Sarah',
      'location': 'Central District',
    },
    {
      'name': 'Mike Wilson',
      'profession': 'Master Carpenter',
      'rating': 4.7,
      'reviewCount': 234,
      'imageUrl': 'https://via.placeholder.com/200?text=Mike',
      'location': 'Riverside',
    },
    {
      'name': 'Emma Davis',
      'profession': 'Professional Cleaner',
      'rating': 4.9,
      'reviewCount': 412,
      'imageUrl': 'https://via.placeholder.com/200?text=Emma',
      'location': 'North End',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Good Morning',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Welcome back, Client',
                style: AppTypography.displaySmall,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.notifications_none,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
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
                hintText: 'Search artisans or services...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Categories Section
              Text(
                'Categories',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category['label'];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: CategoryChip(
                        label: category['label'],
                        icon: category['icon'],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = isSelected ? '' : category['label'];
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Featured Artisans Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Artisans',
                    style: AppTypography.displaySmall,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.exploreArtisans);
                    },
                    child: Text(
                      'View All',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredArtisans.length,
                  itemBuilder: (context, index) {
                    final artisan = featuredArtisans[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: SizedBox(
                        width: 200,
                        child: ArtisanCard(
                          name: artisan['name'],
                          profession: artisan['profession'],
                          rating: artisan['rating'],
                          reviewCount: artisan['reviewCount'],
                          imageUrl: artisan['imageUrl'],
                          location: artisan['location'],
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.artisanProfile,
                              arguments: artisan,
                            );
                          },
                          onFavoriteTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to favorites'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.jobPostCategory);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppColors.onPrimary,
                              size: 32,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Post a Job',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.mapDiscovery);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.map,
                              color: AppColors.onSecondary,
                              size: 32,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Map View',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.bookingHistory);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking History',
                              style: AppTypography.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'View past and ongoing jobs',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
