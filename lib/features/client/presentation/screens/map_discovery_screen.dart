import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class MapDiscoveryScreen extends StatefulWidget {
  const MapDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends State<MapDiscoveryScreen> {
  final List<Map<String, dynamic>> nearbyWorkers = [
    {
      'name': 'John Smith',
      'profession': 'Plumber',
      'lat': 40.7128,
      'lng': -74.0060,
      'distance': '0.5 km',
      'available': true,
    },
    {
      'name': 'Sarah Johnson',
      'profession': 'Electrician',
      'lat': 40.7200,
      'lng': -74.0080,
      'distance': '1.2 km',
      'available': true,
    },
    {
      'name': 'Mike Wilson',
      'profession': 'Carpenter',
      'lat': 40.7050,
      'lng': -74.0100,
      'distance': '2.1 km',
      'available': false,
    },
    {
      'name': 'Emma Davis',
      'profession': 'Cleaner',
      'lat': 40.7300,
      'lng': -74.0020,
      'distance': '1.8 km',
      'available': true,
    },
  ];

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
          // Map Placeholder
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            color: AppColors.surfaceContainer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.mapTrifold(),
                  size: 64,
                  color: AppColors.outlineVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Google Maps Integration',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Map view will be displayed here',
                  style: AppTypography.bodySmall,
                ),
              ],
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
                                          'location': worker['profession'],
                                          'imageUrl': 'https://via.placeholder.com/400?text=${worker['name']}',
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
                                              PhosphorIcons.user(),
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
                                                          PhosphorIcons.mapPin(),
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
                                            PhosphorIcons.caretRight(),
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
