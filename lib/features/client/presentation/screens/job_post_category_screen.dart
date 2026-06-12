import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../core/utils/color_mapper.dart';
import '../../../../shared/widgets/error_state_view.dart';
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
  List<dynamic> _categories = [];
  bool _isLoading = true;
  final CategoriesService _categoriesService = CategoriesService();

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _selectedCategoryId = _draft.categoryId;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await _categoriesService.listCategories();
      setState(() {
        _categories = data;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback is used automatically by service
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? get _selectedCategory {
    if (_selectedCategoryId == null) return null;
    for (final c in _categories) {
      if (c['id'] == _selectedCategoryId) return c as Map<String, dynamic>;
    }
    return null;
  }

  void _continue() {
    final Map<String, dynamic>? cat = _selectedCategory;
    if (cat == null) return;
    _draft.merge(<String, dynamic>{
      'categoryId': cat['id'],
      'categorySlug': cat['slug'],
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.9,
              ),
              itemCount: _categories.length,
              itemBuilder: (BuildContext context, int index) {
                final category = _categories[index];
                final bool isSelected = _selectedCategoryId == category['id'];
                final String name = category['name'] ?? 'Unknown';
                final Color color = ColorMapper.fromHex(category['color_hex']);
                final IconData icon = PhosphorIconMapper.fromString(category['icon_name']);

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
                        Icon(icon, color: color, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          name,
                          style: AppTypography.labelLarge,
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            category['description'] ?? '',
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
