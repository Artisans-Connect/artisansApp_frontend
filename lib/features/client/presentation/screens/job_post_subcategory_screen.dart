import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class JobPostSubcategoryScreen extends StatefulWidget {
  final String? selectedCategory;
  final Map<String, dynamic>? jobData;

  const JobPostSubcategoryScreen({
    Key? key,
    this.selectedCategory,
    this.jobData,
  }) : super(key: key);

  @override
  State<JobPostSubcategoryScreen> createState() =>
      _JobPostSubcategoryScreenState();
}

class _JobPostSubcategoryScreenState extends State<JobPostSubcategoryScreen> {
  late String _selectedSubcategory = '';
  late TextEditingController _searchController;

  final List<Map<String, dynamic>> subcategories = [
    {
      'id': 'plumbing_leaks',
      'name': 'Plumbing',
      'description': 'Leaks, pipe installations, faucets, and drainage solutions.',
      'icon': Icons.plumbing,
      'isPopular': true,
    },
    {
      'id': 'electrical_wiring',
      'name': 'Electrician',
      'description': 'Wiring, panels, lighting',
      'icon': Icons.flash_on,
    },
    {
      'id': 'carpentry',
      'name': 'Carpenter',
      'description': 'Furniture, frames, repair',
      'icon': Icons.handyman,
    },
    {
      'id': 'painting',
      'name': 'Painter',
      'description': 'Interior, exterior, touch-ups',
      'icon': Icons.palette,
    },
    {
      'id': 'cleaning',
      'name': 'Cleaning',
      'description': 'Deep clean, move-in/out',
      'icon': Icons.cleaning_services,
    },
    {
      'id': 'roofing',
      'name': 'Roofing',
      'description': 'Repairs, shingles, gutters',
      'icon': Icons.roofing,
    },
    {
      'id': 'hvac',
      'name': 'HVAC',
      'description': 'AC, heating systems',
      'icon': Icons.cloud,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSubcategories() {
    if (_searchController.text.isEmpty) {
      return subcategories;
    }
    return subcategories
        .where((sub) =>
            sub['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            sub['description']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredSubcategories();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Post a Job',
        onBackPressed: () => Navigator.pop(context),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 2 OF 7',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXLarge),
                    ),
                    child: Text(
                      '28% Complete',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: LinearProgressIndicator(
                  value: 0.28,
                  minHeight: 6,
                  backgroundColor: AppColors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'What do you need help\nwith?',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Select the specific home service category that best describes your project.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search services (e.g. leaking pipe, rewiring...)',
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Featured Category (if available)
              if (filtered.isNotEmpty)
                _buildFeaturedCategoryCard(filtered.first),
              const SizedBox(height: AppSpacing.lg),

              // Grid of Subcategories
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.75,
                ),
                itemCount: filtered.length > 1 ? filtered.length - 1 : 0,
                itemBuilder: (context, index) {
                  final subcategory = filtered[index + 1];
                  return _buildSubcategoryCard(subcategory);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // View all button
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusXLarge),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all 42 subcategories',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.expand_more,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Next Step',
                      onPressed: () {
                        if (_selectedSubcategory.isNotEmpty) {
                          final jobData = widget.jobData ?? {};
                          jobData['category'] = widget.selectedCategory;
                          jobData['subcategory'] = _selectedSubcategory;
                          Navigator.pushNamed(
                            context,
                            AppRoutes.jobPostTitle,
                            arguments: jobData,
                          );
                        }
                      },
                      isEnabled: _selectedSubcategory.isNotEmpty,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCategoryCard(Map<String, dynamic> category) {
    final isSelected = _selectedSubcategory == category['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubcategory = category['id'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Icon(
                    category['icon'],
                    color: AppColors.onPrimary,
                    size: AppSpacing.iconMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'],
                        style: AppTypography.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        category['description'],
                        style: AppTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Popular Choice ↗',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryCard(Map<String, dynamic> category) {
    final isSelected = _selectedSubcategory == category['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubcategory = category['id'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(
                category['icon'],
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.textSecondary,
                size: AppSpacing.iconMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              category['name'],
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category['description'],
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
