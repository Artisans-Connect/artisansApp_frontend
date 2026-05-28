import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';

class JobPostSubcategoryScreen extends StatefulWidget {
  const JobPostSubcategoryScreen({Key? key, required jobData}) : super(key: key);

  @override
  State<JobPostSubcategoryScreen> createState() => _JobPostSubcategoryScreenState();
}

class _JobPostSubcategoryScreenState extends State<JobPostSubcategoryScreen> {
  String? _selectedSubcategory;

  final List<Map<String, dynamic>> subcategories = [
    {
      'id': 'plumbing',
      'title': 'Plumbing',
      'description': 'Leaks, pipe installations, faucets, and drainage solutions.',
      'icon': Icons.build,
      'isPopular': true,
    },
    {
      'id': 'electrician',
      'title': 'Electrician',
      'description': 'Wiring, panels, lighting',
      'icon': Icons.electric_bolt,
      'isPopular': false,
    },
    {
      'id': 'carpenter',
      'title': 'Carpenter',
      'description': 'Furniture, frames, repair',
      'icon': Icons.handyman,
      'isPopular': false,
    },
    {
      'id': 'painter',
      'title': 'Painter',
      'description': 'Interior, exterior, touch-ups',
      'icon': Icons.palette,
      'isPopular': false,
    },
    {
      'id': 'cleaning',
      'title': 'Cleaning',
      'description': 'Deep clean, move-in/out',
      'icon': Icons.home_work,
      'isPopular': false,
    },
    {
      'id': 'roofing',
      'title': 'Roofing',
      'description': 'Repairs, shingles, gutters',
      'icon': Icons.home_repair_service,
      'isPopular': false,
    },
    {
      'id': 'hvac',
      'title': 'HVAC',
      'description': 'AC, heating systems',
      'icon': Icons.cloud_queue,
      'isPopular': false,
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Post a Job',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
            Text(
              'ConnectFlow',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
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
              // Progress Section
              Text(
                'STEP 2 OF 7',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.28,
                      minHeight: 6,
                      backgroundColor: AppColors.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '28% Complete',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Heading
              Text(
                'What do you need help with?',
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  'Select the specific home service category that best describes your project.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Search Bar
              TextField(
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search services (e.g. leaking pipe, rewiring...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Featured Service Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                  border: Border.all(
                    color: _selectedSubcategory == 'plumbing'
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: _selectedSubcategory == 'plumbing' ? 2 : 0.5,
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSubcategory = 'plumbing';
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            ),
                            child: Icon(
                              Icons.build,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plumbing',
                                  style: AppTypography.displaySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Leaks, pipe installations, faucets, and drainage solutions.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Popular Choice',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Subcategory Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.9,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index + 1];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSubcategory = subcategory['id'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        border: Border.all(
                          color: _selectedSubcategory == subcategory['id']
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          width: _selectedSubcategory == subcategory['id'] ? 2 : 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            ),
                            child: Icon(
                              subcategory['icon'],
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            subcategory['title'],
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subcategory['description'],
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // View All Subcategories Button
              Center(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all 42 subcategories',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.expand_more, color: AppColors.textPrimary),
                    ],
                  ),
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
                        Navigator.pushNamed(context, AppRoutes.jobPostTitle);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Text(
                        'Next Step',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
