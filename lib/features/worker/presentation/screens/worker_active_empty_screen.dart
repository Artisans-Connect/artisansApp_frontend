import 'package:flutter/material.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
import '../widgets/gradient_button.dart';

class WorkerActiveEmptyScreen extends StatelessWidget {
  const WorkerActiveEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);

    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: WorkerColors.primary,
          onPressed: () {},
        ),
        title: Text(
          'Active Job',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.primary),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: WorkerSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: WorkerColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: WorkerColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'ONLINE',
                  style: WorkerTextStyles.badge.copyWith(
                    color: WorkerColors.successDark,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WorkerSpacing.gutter),
        child: Column(
          children: [
            const SizedBox(height: WorkerSpacing.lg),
            Container(
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
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: WorkerColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.handyman_outlined, size: 48),
                    ),
                  ),
                  const SizedBox(height: WorkerSpacing.md),
                  Icon(
                    Icons.work_off_outlined,
                    size: 40,
                    color: WorkerColors.primary.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.xl),
            Text('No active job', style: WorkerTextStyles.titleMd),
            const SizedBox(height: WorkerSpacing.sm),
            Text(
              'When you accept a request, it will appear here. Keep your status online to receive new opportunities.',
              style: WorkerTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WorkerSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: 'Browse Requests  →',
                onPressed: session.goToExplore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
