import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class JobPostSummaryScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const JobPostSummaryScreen({
    Key? key,
    this.jobData,
  }) : super(key: key);

  @override
  State<JobPostSummaryScreen> createState() => _JobPostSummaryScreenState();
}

class _JobPostSummaryScreenState extends State<JobPostSummaryScreen> {
  late bool _isVerified = true;
  late bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _isVerified = widget.jobData?['isVerified'] ?? true;
    _agreeToTerms = widget.jobData?['agreeToTerms'] ?? false;
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final jobTitle = widget.jobData?['title'] ?? 'Senior Full-Stack Architect for AI Platform';
    final description = widget.jobData?['description'] ??
        'We are seeking a visionary Full-Stack Architect to lead the development of our next-generation AI flow platform. You will be responsible for designing high-performance distributed systems, mentoring senior engineers, and ensuring the seamless integration of LLM endpoints into our core UI components. The ideal candidate has 8+ years of experience and a passion for glossy, fluid user interfaces.';
    final budgetMin = widget.jobData?['budgetMin'] ?? 140000.0;
    final budgetMax = widget.jobData?['budgetMax'] ?? 180000.0;
    final category = widget.jobData?['category'] ?? 'Engineering & Tech';
    final location = widget.jobData?['address'] ?? 'Remote, San Francisco';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Review & Post',
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
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
                  Text(
                    'STEP 7 OF 7',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXLarge),
                    ),
                    child: Text(
                      'COMPLETION: 100%',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress Bar (Full)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: const LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 6,
                  backgroundColor: AppColors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Job Summary Card
              _buildJobSummaryCard(
                jobTitle: jobTitle,
                category: category,
                location: location,
                description: description,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Budget Range Card
              _buildBudgetCard(budgetMin, budgetMax),
              const SizedBox(height: AppSpacing.lg),

              // Company Preview Card
              _buildCompanyPreviewCard(),
              const SizedBox(height: AppSpacing.lg),

              // Verification Badge
              _buildVerificationBadge(),
              const SizedBox(height: AppSpacing.lg),

              // Terms Agreement
              _buildTermsCheckbox(),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Save as Draft',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job saved as draft'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Post Job',
                      icon: Icons.check,
                      mainAxisAlignment: MainAxisAlignment.center,
                      isEnabled: _agreeToTerms,
                      onPressed: () {
                        if (!_agreeToTerms) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job posted successfully!'),
                          ),
                        );
                        // Navigate back to home
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.clientHome,
                          (route) => false,
                        );
                      },
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

  Widget _buildJobSummaryCard({
    required String jobTitle,
    required String category,
    required String location,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Summary',
                style: AppTypography.displaySmall,
              ),
              Icon(
                Icons.edit,
                color: AppColors.textSecondary,
                size: AppSpacing.iconMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // TITLE Section
          Text(
            'TITLE',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            jobTitle,
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Category and Location Chips
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _buildChip(Icons.category, category),
              _buildChip(Icons.location_on, location),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // DESCRIPTION Section
          Text(
            'DESCRIPTION',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.iconSmall,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(double min, double max) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUDGET RANGE',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                _formatCurrency(min),
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '-',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatCurrency(max),
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '/ yr',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Full-time • Equity included',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Card
          Container(
            width: double.infinity,
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
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Company Preview',
            style: AppTypography.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your post will be featured on the main explorer tab with this aesthetic.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: AppSpacing.iconMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Launch',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Verified by ConnectFlow AI',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: 'Terms & Conditions',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' and confirm that all information is accurate.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
