import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class JobPostTitleScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const JobPostTitleScreen({
    Key? key,
    this.jobData,
  }) : super(key: key);

  @override
  State<JobPostTitleScreen> createState() => _JobPostTitleScreenState();
}

class _JobPostTitleScreenState extends State<JobPostTitleScreen> {
  late TextEditingController _titleController;
  int _titleLength = 0;
  final int _maxTitleLength = 80;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.jobData?['title'] ?? '',
    );
    _titleLength = _titleController.text.length;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'ConnectFlow',
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
                        'STEP 3 OF 7',
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
                      '42% Complete',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Title with Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Job Title',
                    style: AppTypography.displayMedium,
                  ),
                  Text(
                    '$_titleLength / $_maxTitleLength',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: LinearProgressIndicator(
                  value: 0.42,
                  minHeight: 6,
                  backgroundColor: AppColors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description
              Text(
                'What would you like to call your project?',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Keep it short and descriptive to attract the best artisans.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: _titleLength > 0
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _titleController,
                  maxLength: _maxTitleLength,
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g., Fix leaking kitchen...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    counterText: '',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _titleLength = value.length;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Examples Section
              _buildExampleCard(
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                title: 'Good Examples',
                examples: ['"Repair oak dining table leg"'],
              ),
              const SizedBox(height: AppSpacing.md),

              _buildExampleCard(
                icon: Icons.cancel,
                iconColor: AppColors.error,
                title: 'Avoid',
                examples: ['"URGENT HELP NEEDED!!!"'],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Promotional Cards
              _buildPromotionalCard(
                title: 'Artisan Matching',
                description:
                    'We use your title to find specialists in your specific job type, ensuring you get the most accurate quotes.',
                icon: Icons.people,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildPromotionalCard(
                title: 'Clarity is Key',
                description:
                    'A clear title results in 3x more engagement from top-level professionals in the first 24 hours.',
                icon: Icons.lightbulb,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildBrandCard(),
              const SizedBox(height: AppSpacing.lg),

              _buildPromotionalCard(
                title: 'Trusted Workflow',
                description:
                    'Our guided process ensures every detail of your request is captured perfectly for a smooth experience.',
                icon: Icons.check_circle,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Footer
              Center(
                child: Text(
                  'ConnectFlow',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Terms',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Privacy',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Support',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  '© 2024 ConnectFlow. All rights reserved.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
                      icon: Icons.arrow_back_ios,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Next Step',
                      icon: Icons.arrow_forward_ios,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      onPressed: () {
                        if (_titleLength <= 0) return;
                        final jobData = widget.jobData ?? {};
                        jobData['title'] = _titleController.text;
                        Navigator.pushNamed(
                          context,
                          AppRoutes.jobPostDescription,
                          arguments: jobData,
                        );
                      },
                      isEnabled: _titleLength > 0,
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

  Widget _buildExampleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: AppSpacing.iconMedium,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...examples
                    .map(
                      (example) => Text(
                        example,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a3f),
            const Color(0xFF2d1b69),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.star,
              color: Colors.purple,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Artisans',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'ELITE CRAFTSMANSHIP ON DEMAND',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
