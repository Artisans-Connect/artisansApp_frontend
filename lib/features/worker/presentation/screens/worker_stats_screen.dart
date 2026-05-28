import 'package:flutter/material.dart';
import '../../../../shared/presentation/screens/settings_screen.dart';
import '../models/mock_worker_data.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class WorkerStatsScreen extends StatelessWidget {
  const WorkerStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: WorkerColors.primary,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
              return;
            }
            WorkerScope.of(context).setProfilePage(WorkerProfilePage.earnings);
          },
        ),
        title: Text(
          'Your Stats',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WorkerSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Performance Overview', style: WorkerTextStyles.titleMd),
            const SizedBox(height: 4),
            Text(
              'Track your professional growth as an artisan.',
              style: WorkerTextStyles.bodyMd,
            ),
            const SizedBox(height: WorkerSpacing.lg),
            Row(
              children: [
                _StatCard(
                  icon: Icons.check_circle,
                  value: '${MockWorkerData.totalJobs}',
                  label: 'JOBS',
                  iconColor: WorkerColors.primary,
                ),
                const SizedBox(width: WorkerSpacing.sm),
                _StatCard(
                  icon: Icons.star_outline,
                  value: '0.0',
                  label: 'RATING',
                ),
                const SizedBox(width: WorkerSpacing.sm),
                _StatCard(
                  icon: Icons.timer_outlined,
                  value: MockWorkerData.responseHoursLabel,
                  label: 'RESPONSE',
                  iconColor: WorkerColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: WorkerSpacing.lg),
            Row(
              children: [
                Text('Recent Reviews', style: WorkerTextStyles.titleMd),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: WorkerColors.primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'New',
                    style: WorkerTextStyles.badge.copyWith(
                      color: WorkerColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: WorkerSpacing.md),
            Container(
              padding: const EdgeInsets.all(WorkerSpacing.xl),
              decoration: BoxDecoration(
                color: WorkerColors.surface,
                borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.engineering_outlined,
                    size: 64,
                    color: WorkerColors.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: WorkerSpacing.md),
                  Text('No reviews yet.', style: WorkerTextStyles.titleMd),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your first few jobs to receive feedback from your clients and build your profile.',
                    style: WorkerTextStyles.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            OutlinedButton(
              onPressed: () {
                WorkerScope.of(context).setProfilePage(WorkerProfilePage.history);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('View all jobs  >'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(WorkerSpacing.md),
        decoration: BoxDecoration(
          color: WorkerColors.surface,
          borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? WorkerColors.outline),
            const SizedBox(height: WorkerSpacing.sm),
            Text(value, style: WorkerTextStyles.titleMd.copyWith(fontSize: 18)),
            Text(label, style: WorkerTextStyles.labelCaps.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
