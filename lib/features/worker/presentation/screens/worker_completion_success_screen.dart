import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../models/worker_job.dart';
import 'package:artisans_app/core/theme/index.dart';
import '../utils/worker_formatters.dart';
import '../widgets/gradient_button.dart';
import '../../../../shared/widgets/custom_back_button.dart';

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
    final earned = job.earnedAmount ?? 145;

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
              'The client has been notified and will rate you shortly.',
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
                      Text('EARNED TOTAL', style: AppTypography.labelCaps),
                      Text(
                        formatCedis(earned),
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.success,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
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
            GradientButton(
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
