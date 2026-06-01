import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/categories_service.dart';
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
  String? _error;
  final CategoriesService _categoriesService = CategoriesService();

  final List<Map<String, dynamic>> categories = <Map<String, dynamic>>[
    {
      'id': 'plumbing',
      'name': 'Plumbing',
      'icon': PhosphorIcons.drop(),
      'description': 'Repairs, installation, maintenance',
      'color': Color(0xFF4648D4),
    },
    {
      'id': 'electrical',
      'name': 'Electrical',
      'icon': PhosphorIcons.lightning(),
      'description': 'Wiring, repairs, installations',
      'color': Color(0xFF0058BE),
    },
    {
      'id': 'carpentry',
      'name': 'Carpentry',
      'icon': PhosphorIcons.wrench(),
      'description': 'Furniture, repairs, custom work',
      'color': Color(0xFFB55D00),
    },
    {
      'id': 'cleaning',
      'name': 'Cleaning',
      'icon': PhosphorIcons.broom(),
      'description': 'Home, office, deep cleaning',
      'color': Color(0xFF00E676),
    },
    {
      'id': 'painting',
      'name': 'Painting',
      'icon': PhosphorIcons.palette(),
      'description': 'Interior, exterior, decorative',
      'color': Color(0xFFF44336),
    },
    {
      'id': 'construction',
      'name': 'Construction',
      'icon': PhosphorIcons.barricade(),
      'description': 'Building, renovation, repairs',
      'color': Color(0xFFFF9800),
    },
    {
      'id': 'hvac',
      'name': 'HVAC',
      'icon': PhosphorIcons.snowflake(),
      'description': 'Cooling, heating, ventilation',
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'landscaping',
      'name': 'Landscaping',
      'icon': PhosphorIcons.mountains(),
      'description': 'Lawn, garden, outdoor design',
      'color': Color(0xFF4CAF50),
    },
  ];

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
      setState(() {
        _error = userMessageFor(e, fallback: 'Could not load categories.');
        _isLoading = false;
      });
    }
  }

  IconData _getIconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('plumb')) return PhosphorIcons.drop();
    if (lower.contains('electr')) return PhosphorIcons.lightning();
    if (lower.contains('carp')) return PhosphorIcons.wrench();
    if (lower.contains('clean')) return PhosphorIcons.broom();
    if (lower.contains('paint')) return PhosphorIcons.palette();
    if (lower.contains('construct')) return PhosphorIcons.barricade();
    if (lower.contains('hvac')) return PhosphorIcons.snowflake();
    if (lower.contains('landscap')) return PhosphorIcons.mountains();
    return PhosphorIcons.squaresFour();
  }

  Color _getColorForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('plumb')) return const Color(0xFF4648D4);
    if (lower.contains('electr')) return const Color(0xFF0058BE);
    if (lower.contains('carp')) return const Color(0xFFB55D00);
    if (lower.contains('clean')) return const Color(0xFF00E676);
    if (lower.contains('paint')) return const Color(0xFFF44336);
    if (lower.contains('construct')) return const Color(0xFFFF9800);
    if (lower.contains('hvac')) return const Color(0xFF2196F3);
    if (lower.contains('landscap')) return const Color(0xFF4CAF50);
    return Colors.grey;
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
          else if (_error != null)
            ErrorStateView(
              message: _error!,
              title: 'Could not load categories',
              compact: true,
              onRetry: _fetchCategories,
            )
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
                final Color color = _getColorForCategory(name);
                final IconData icon = _getIconForCategory(name);

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
