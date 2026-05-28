import 'package:flutter/material.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../navigation/client_navigation.dart';
import '../widgets/job_post_wizard_scaffold.dart';

class JobPostCategoryScreen extends StatefulWidget {
  const JobPostCategoryScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostCategoryScreen> createState() => _JobPostCategoryScreenState();
}

class _JobPostCategoryScreenState extends State<JobPostCategoryScreen> {
  String? _selectedCategoryId;
  late ClientJobDraft _draft;

  final List<Map<String, dynamic>> categories = <Map<String, dynamic>>[
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
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _selectedCategoryId = _draft.categoryId;
  }

  Map<String, dynamic>? get _selectedCategory {
    if (_selectedCategoryId == null) return null;
    for (final Map<String, dynamic> c in categories) {
      if (c['id'] == _selectedCategoryId) return c;
    }
    return null;
  }

  void _continue() {
    final Map<String, dynamic>? cat = _selectedCategory;
    if (cat == null) return;
    _draft.merge(<String, dynamic>{
      'categoryId': cat['id'],
      'categoryName': cat['name'],
      'category': cat['name'],
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostSubcategory,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobPostWizardScaffold(
      step: JobPostWizardStep.category,
      headline: 'What service do you need?',
      primaryLabel: 'Continue',
      primaryEnabled: _selectedCategoryId != null,
      onPrimary: _continue,
      showDiscardOnBack: _draft.hasAnyData,
      onDiscard: () => ClientNavigation.popToShell(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a category to match with skilled artisans near you.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> category = categories[index];
              final bool isSelected = _selectedCategoryId == category['id'];
              final Color color = category['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryId = category['id']),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                    border: Border.all(
                      color: isSelected ? color : AppColors.borderSubtle,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category['icon'] as IconData, color: color, size: 32),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        category['name'] as String,
                        style: AppTypography.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Text(
                          category['description'] as String,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
