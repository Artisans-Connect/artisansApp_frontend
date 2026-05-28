import 'package:flutter/material.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
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
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: WorkerColors.primary,
          onPressed: () => _goHome(context),
        ),
        title: Text(
          'Artisans',
          style: WorkerTextStyles.titleMd.copyWith(
            color: WorkerColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WorkerSpacing.gutter),
        child: Column(
          children: [
            const SizedBox(height: WorkerSpacing.lg),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: WorkerColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: WorkerColors.successDark,
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            Text('Booking Completed!', style: WorkerTextStyles.displayMd),
            const SizedBox(height: WorkerSpacing.sm),
            Text(
              'The client has been notified and will rate you shortly.',
              style: WorkerTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WorkerSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(WorkerSpacing.lg),
              decoration: BoxDecoration(
                color: WorkerColors.surface,
                borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
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
                      Text('EARNED TOTAL', style: WorkerTextStyles.labelCaps),
                      Text(
                        formatCedis(earned),
                        style: WorkerTextStyles.titleMd.copyWith(
                          color: WorkerColors.successDark,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: WorkerSpacing.lg),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: WorkerColors.primaryFixed,
                        child: Text(
                          job.clientName.substring(0, 1),
                          style: WorkerTextStyles.titleMd.copyWith(
                            color: WorkerColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: WorkerSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.clientName,
                              style: WorkerTextStyles.titleMd.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              job.title.toUpperCase(),
                              style: WorkerTextStyles.labelCaps.copyWith(
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
            const SizedBox(height: WorkerSpacing.xl),
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
              icon: const Icon(Icons.share_outlined, size: 18),
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
