import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/mock_worker_job.dart';
import 'package:artisans_app/core/theme/index.dart';
import '../utils/worker_formatters.dart';
import '../widgets/gradient_button.dart';

class WorkerCompletionSuccessScreen extends StatelessWidget {
  const WorkerCompletionSuccessScreen({
    super.key,
    required this.job,
    required this.onDone,
  });

  final MockWorkerJob job;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final earned = job.earnedAmount ?? 145;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(), size: 20),
          color: AppColors.primary,
          onPressed: () => _goHome(context),
        ),
        title: Text(
          'Artisans',
          style: AppTypography.titleMd.copyWith(
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
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.checkCircle(),
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Booking Completed!', style: AppTypography.displayMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'The client has been notified and will rate you shortly.',
              style: AppTypography.bodyMd,
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
                    color: Colors.black.withOpacity(0.05),
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
                        style: AppTypography.titleMd.copyWith(
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
                          style: AppTypography.titleMd.copyWith(
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
                              style: AppTypography.titleMd.copyWith(
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
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share — coming soon')),
                );
              },
              icon: Icon(PhosphorIcons.shareNetwork(), size: 18),
              label: const Text('Share this job to your portfolio'),
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
