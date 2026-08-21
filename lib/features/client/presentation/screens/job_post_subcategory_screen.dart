import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/services/categories_service.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/features/client/presentation/models/client_job_draft.dart';
import 'package:artisans_app/features/client/presentation/models/job_post_wizard_step.dart';
import 'package:artisans_app/features/client/presentation/widgets/job_post_wizard_scaffold.dart';

class JobPostSubcategoryScreen extends StatefulWidget {
  const JobPostSubcategoryScreen({
    super.key,
    this.jobData,
  });

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostSubcategoryScreen> createState() =>
      _JobPostSubcategoryScreenState();
}

class _JobPostSubcategoryScreenState extends State<JobPostSubcategoryScreen> {
  String _selectedSubcategoryId = '';
  late ClientJobDraft _draft;
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _subcategories = [];
  bool _isLoading = true;
  final CategoriesService _categoriesService = CategoriesService();

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _selectedSubcategoryId = _draft.subcategoryId ?? '';
    _searchController = TextEditingController();
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    try {
      final List<Map<String, dynamic>> carriedSubcategories =
          _normalizeSubcategories(_draft.categorySubcategories);
      final List<dynamic> subcategories = carriedSubcategories.isNotEmpty
          ? carriedSubcategories
          : await _categoriesService.getSubcategoriesFor(
              _draft.categorySlug ?? _draft.categoryId ?? _draft.categoryName,
            );

      if (!mounted) return;
      setState(() {
        _subcategories = _normalizeSubcategories(subcategories);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _normalizeSubcategories(List<dynamic> raw) {
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .where((Map<String, dynamic> item) =>
            (item['id'] ?? item['slug'] ?? '').toString().isNotEmpty)
        .map((Map<String, dynamic> item) {
      item['id'] = (item['id'] ?? item['slug']).toString();
      item['name'] = (item['name'] ?? 'Service type').toString();
      item['description'] = item['description']?.toString();
      return item;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final String q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _subcategories;
    return _subcategories
        .where(
          (Map<String, dynamic> sub) {
            final String name = (sub['name'] ?? '').toString().toLowerCase();
            final String description =
                (sub['description'] ?? '').toString().toLowerCase();
            return name.contains(q) || description.contains(q);
          },
        )
        .toList();
  }

  void _continue() {
    final List<Map<String, dynamic>> matches = _subcategories
        .where((Map<String, dynamic> s) => s['id'] == _selectedSubcategoryId)
        .toList();
    if (matches.isEmpty) return;
    final Map<String, dynamic> selected = matches.first;
    _draft.merge(<String, dynamic>{
      'subcategoryId': selected['id'],
      'subcategoryName': selected['name'],
      'subcategory': selected['name'],
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostDetails,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filtered = _filtered;

    return JobPostWizardScaffold(
      step: JobPostWizardStep.subcategory,
      headline: 'What type of ${_draft.displayCategory} work?',
      primaryLabel: 'Next',
      primaryEnabled: _selectedSubcategoryId.isNotEmpty,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick the option that best describes your job.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_subcategories.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                'No service types are available for this category yet.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search service types…',
                    prefixIcon: Icon(PhosphorIcons.magnifyingGlass),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...filtered.map((Map<String, dynamic> sub) {
                  final bool isSelected = _selectedSubcategoryId == sub['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedSubcategoryId =
                              (sub['id'] ?? '').toString()),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer.withValues(alpha: 0.3)
                              : AppColors.surfaceContainerLowest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLarge),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderSubtle,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (sub['name'] ?? 'Service type').toString(),
                              style: AppTypography.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              sub['description'] as String? ?? '',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}

