import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';

class JobPostCategoryScreen extends StatefulWidget {
  const JobPostCategoryScreen({Key? key, Map<String, dynamic>? jobData}) : super(key: key);

  @override
  State<JobPostCategoryScreen> createState() => _JobPostCategoryScreenState();
}

class _JobPostCategoryScreenState extends State<JobPostCategoryScreen> {
  String? _selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'plumbing',
      'name': 'Plumbing',
      'icon': Icons.plumbing,
      'description': 'Repairs, installation, maintenance',
      'color': Color(0xFF4648D4),
    },
    {
      'id': 'electrical',
      'name': 'Electrical',
      'icon': Icons.flash_on,
      'description': 'Wiring, repairs, installations',
      'color': Color(0xFF0058BE),
    },
    {
      'id': 'carpentry',
      'name': 'Carpentry',
      'icon': Icons.handyman,
      'description': 'Furniture, repairs, custom work',
      'color': Color(0xFFB55D00),
    },
    {
      'id': 'cleaning',
      'name': 'Cleaning',
      'icon': Icons.cleaning_services,
      'description': 'Home, office, deep cleaning',
      'color': Color(0xFF00E676),
    },
    {
      'id': 'painting',
      'name': 'Painting',
      'icon': Icons.palette,
      'description': 'Interior, exterior, decorative',
      'color': Color(0xFFF44336),
    },
    {
      'id': 'construction',
      'name': 'Construction',
      'icon': Icons.construction,
      'description': 'Building, renovation, repairs',
      'color': Color(0xFFFF9800),
    },
    {
      'id': 'hvac',
      'name': 'HVAC',
      'icon': Icons.ac_unit,
      'description': 'Cooling, heating, ventilation',
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'landscaping',
      'name': 'Landscaping',
      'icon': Icons.landscape,
      'description': 'Lawn, garden, outdoor design',
      'color': Color(0xFF4CAF50),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Select Service',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'What service do you need?',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose from popular services or browse all options',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['id'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        border: Border.all(
                          color: isSelected
                              ? category['color']
                              : AppColors.borderSubtle,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: category['color'].withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: category['color'].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  category['icon'],
                                  color: category['color'],
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                category['name'],
                                style: AppTypography.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                child: Text(
                                  category['description'],
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            Positioned(
                              top: AppSpacing.sm,
                              right: AppSpacing.sm,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: category['color'],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
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
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: PrimaryButton(
          label: 'Continue',
          isEnabled: _selectedCategory != null,
          onPressed: () {
            if (_selectedCategory != null) {
              Navigator.pushNamed(
                context,
                AppRoutes.jobPostSubcategory,
                arguments: {
                  'category': _selectedCategory,
                  'jobData': {'category': _selectedCategory},
                },
              );
            }
          },
        ),
      ),
    );
  }
}
