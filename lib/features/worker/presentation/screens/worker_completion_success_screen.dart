import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/shared/models/worker_job.dart';
import 'package:artisans_app/core/theme/index.dart';
import 'package:artisans_app/features/worker/presentation/utils/worker_formatters.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_gradient_button.dart';
import 'package:artisans_app/shared/widgets/custom_back_button.dart';

class WorkerCompletionSuccessScreen extends StatelessWidget {
  const WorkerCompletionSuccessScreen({
    super.key,
    required this.job,
    required this.onDone,
  });

  final WorkerJob job;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final double clientCharge = job.grossAmount ??
        job.applicationTotalQuote ??
        job.earnedAmount ??
        job.artisanPayout ??
        0;
    final double? platformFee = job.platformFee;
    final double? payout = job.artisanPayout ?? job.earnedAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: CustomBackButton(
          onPressed: () => _goHome(context),
        ),
        title: Text(
          'CraftMatch',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.checkCircle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Booking Completed!', style: AppTypography.displayMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your completion report and final amount have been sent to the client for approval.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SENT FOR APPROVAL', style: AppTypography.labelCaps),
                      Text(
                        formatCedis(clientCharge),
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.success,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'This is the amount the client will review before the booking is closed.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (platformFee != null || payout != null) ...[
                    const Divider(height: AppSpacing.lg),
                    if (platformFee != null)
                      _AmountRow(
                        label: 'Platform fee',
                        amount: platformFee,
                      ),
                    if (payout != null)
                      _AmountRow(
                        label: 'Estimated payout after approval',
                        amount: payout,
                        highlight: true,
                      ),
                  ],
                  const Divider(height: AppSpacing.lg),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryFixed,
                        child: Text(
                          job.clientName.substring(0, 1),
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.clientName,
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              job.title.toUpperCase(),
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            WorkerGradientButton(
              label: 'Back to Requests',
              onPressed: () => _goHome(context),
            ),
          ],
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    onDone();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  final String label;
  final double amount;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            formatCedis(amount),
            style: AppTypography.bodyMedium.copyWith(
              color: highlight ? AppColors.success : AppColors.textPrimary,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
