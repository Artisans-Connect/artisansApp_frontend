import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../core/utils/color_mapper.dart';
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
  bool _showAllCategories = false;
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
      if (!mounted) return;
      setState(() {
        _categories = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? get _selectedCategory {
    if (_selectedCategoryId == null) return null;
    for (final c in _categories) {
      if (c is Map && c['id'] == _selectedCategoryId) {
        return Map<String, dynamic>.from(c);
      }
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
      if (cat['subcategories'] is List)
        'categorySubcategories': cat['subcategories'],
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostSubcategory,
      arguments: _draft.toMap(),
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> category) {
    final String id = (category['id'] ?? '').toString();
    final bool isSelected = _selectedCategoryId == id;
    final String name = (category['name'] ?? 'Unknown').toString();
    final Color color = ColorMapper.fromHex(category['color_hex']?.toString());
    final IconData icon = PhosphorIconMapper.fromString(
      category['icon_name']?.toString(),
    );

    return GestureDetector(
      onTap: id.isEmpty ? null : () => setState(() => _selectedCategoryId = id),
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> visibleCategories =
        _showAllCategories ? _categories : _categories.take(8).toList();

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
            Column(
              children: <Widget>[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: visibleCategories.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> category =
                        Map<String, dynamic>.from(visibleCategories[index] as Map);
                    return _buildCategoryTile(category);
                  },
                ),
                if (_categories.length > 8) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => setState(
                      () => _showAllCategories = !_showAllCategories,
                    ),
                    icon: Icon(
                      _showAllCategories
                          ? PhosphorIcons.caretUp
                          : PhosphorIcons.caretDown,
                    ),
                    label: Text(
                      _showAllCategories
                          ? 'See fewer categories'
                          : 'See more categories',
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
