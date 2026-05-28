import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';

class JobPostCategoryScreen extends StatefulWidget {
  const JobPostCategoryScreen({Key? key}) : super(key: key);

  @override
  State<JobPostCategoryScreen> createState() => _JobPostCategoryScreenState();
}

class _JobPostCategoryScreenState extends State<JobPostCategoryScreen> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'home_services',
      'name': 'Home Services',
      'icon': Icons.home_repair_service,
      'description': 'Cleaning, Repair, Plumbing',
      'color': Color(0xFF7C8EF8),
    },
    {
      'id': 'technical',
      'name': 'Technical',
      'icon': Icons.build,
      'description': 'IT, Software, Networking',
      'color': Color(0xFF7C8EF8),
    },
    {
      'id': 'creative',
      'name': 'Creative',
      'icon': Icons.palette,
      'description': 'Design, Copy, Multimedia',
      'color': Color(0xFF7C8EF8),
      'isSelected': true,
    },
    {
      'id': 'maintenance',
      'name': 'Maintenance',
      'icon': Icons.build_circle,
      'description': 'Industrial, Logistics, Auto',
      'color': Color(0xFFB8A484),
    },
  ];

  final List<Map<String, dynamic>> allCategories = [
    {'name': 'Personal Care', 'icon': Icons.person},
    {'name': 'Culinary', 'icon': Icons.restaurant},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Events', 'icon': Icons.event},
    {'name': 'Legal & Finance', 'icon': Icons.gavel},
    {'name': 'Health', 'icon': Icons.local_hospital},
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
          'Select Category',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              Text(
                'STEP 1 OF 7',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.14,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceContainerLow,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '14% COMPLETE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Heading and Description
              Text(
                'What do you need help with?',
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Choose the primary category that best describes your project.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category['id'] || category['isSelected'] == true;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['id'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                category['icon'],
                                color: AppColors.primary,
                                size: 32,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                category['name'],
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                category['description'],
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (isSelected)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // All Categories Section
              Text(
                'ALL CATEGORIES',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: allCategories.map((category) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          category['name'],
                          style: AppTypography.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Other Category Button
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '• • •  Other',
                    style: AppTypography.labelMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Save Draft',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD0D4E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCategory != null) {
                    Navigator.pushNamed(context, AppRoutes.jobPostSubcategory);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                  ),
                ),
                child: Text(
                  'Next Step',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
