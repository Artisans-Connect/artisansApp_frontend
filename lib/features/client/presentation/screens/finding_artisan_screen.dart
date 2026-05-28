import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../models/client_booking_stub.dart';
import '../navigation/client_navigation.dart';

class FindingArtisanScreen extends StatefulWidget {
  const FindingArtisanScreen({
    super.key,
    this.jobData,
    this.artisan,
  });

  final Map<String, dynamic>? jobData;
  final Map<String, dynamic>? artisan;

  @override
  State<FindingArtisanScreen> createState() => _FindingArtisanScreenState();
}

class _FindingArtisanScreenState extends State<FindingArtisanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final booking = ClientBooking.fromJobPost(
        jobData: widget.jobData ?? <String, dynamic>{},
        artisan: widget.artisan,
      );
      ClientNavigation.openLiveTrackingFromMatch(context, booking: booking);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artisan matched — track your job live.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Finding Artisan',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _animationController,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: Tween<double>(begin: 1, end: 0)
                          .animate(_animationController),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_search,
                        color: AppColors.onPrimary,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Text(
                'Finding the Perfect Match',
                style: AppTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We\'re searching for the best artisan\nmatching your requirements...',
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Column(
                children: [
                  _buildProgressStep(
                    number: '1',
                    title: 'Job Details',
                    subtitle: 'Analyzing your requirements',
                    isCompleted: true,
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: AppColors.primary.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  _buildProgressStep(
                    number: '2',
                    title: 'Matching',
                    subtitle: 'Finding suitable artisans',
                    isActive: true,
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: AppColors.outlineVariant,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  _buildProgressStep(
                    number: '3',
                    title: 'Confirmation',
                    subtitle: 'Awaiting artisan acceptance',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated Wait Time',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '2-3 minutes',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: SecondaryButton(
          label: 'Cancel Search',
          onPressed: () => ClientNavigation.popToShell(context),
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required String number,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primary
                : isActive
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainer,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: AppColors.onPrimary,
                    size: 24,
                  )
                : Text(
                    number,
                    style: AppTypography.displaySmall.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
