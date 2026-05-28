import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';

class JobPostLocationScreen extends StatefulWidget {
  const JobPostLocationScreen({Key? key, required jobData}) : super(key: key);

  @override
  State<JobPostLocationScreen> createState() => _JobPostLocationScreenState();
}

class _JobPostLocationScreenState extends State<JobPostLocationScreen> {
  double _zoomLevel = 15;

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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Job Location',
                    style: AppTypography.displayLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    'STEP 5 OF 7',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: 0.71,
                minHeight: 6,
                backgroundColor: AppColors.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Map Container
              Container(
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Map Background
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                      child: Container(
                        color: Colors.grey[900],
                        child: Image.network(
                          'https://via.placeholder.com/400x500?text=Map',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: Icon(
                                Icons.map,
                                color: Colors.grey[700],
                                size: 100,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Zoom Buttons (Top Right)
                    Positioned(
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add, color: AppColors.primary),
                              onPressed: () {
                                setState(() {
                                  _zoomLevel += 1;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.remove, color: AppColors.primary),
                              onPressed: () {
                                setState(() {
                                  _zoomLevel = (_zoomLevel - 1).clamp(1, 20);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Marker with Location Pin
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background icon
                          Icon(
                            Icons.build,
                            color: AppColors.primary.withOpacity(0.3),
                            size: 100,
                          ),
                          // Location pin
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Artisans Text Overlay
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Artisans',
                              style: AppTypography.displayLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 40,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'ELITE CRAFTSMANSHIP ON DEMAND',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.grey[500],
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Service Address Card (Bottom)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppSpacing.radiusXLarge),
                            topRight: Radius.circular(AppSpacing.radiusXLarge),
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SERVICE ADDRESS',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '123 Osu St, Accra...',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: AppColors.textSecondary),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Text(
                        'Back',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.jobPostUrgency);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
