import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(), size: 20),
          color: AppColors.primary,
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
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.gear()),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Performance Overview', style: AppTypography.titleMd),
            const SizedBox(height: 4),
            Text(
              'Track your professional growth as an artisan.',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _StatCard(
                  icon: PhosphorIcons.checkCircle(),
                  value: '${MockWorkerData.totalJobs}',
                  label: 'JOBS',
                  iconColor: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatCard(
                  icon: PhosphorIcons.star(),
                  value: '0.0',
                  label: 'RATING',
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatCard(
                  icon: PhosphorIcons.timer(),
                  value: MockWorkerData.responseHoursLabel,
                  label: 'RESPONSE',
                  iconColor: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text('Recent Reviews', style: AppTypography.titleMd),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'New',
                    style: AppTypography.badge.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppColors.cardRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.hardHat(),
                    size: 64,
                    color: AppColors.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('No reviews yet.', style: AppTypography.titleMd),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your first few jobs to receive feedback from your clients and build your profile.',
                    style: AppTypography.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? AppColors.outline),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: AppTypography.titleMd.copyWith(fontSize: 18)),
            Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
