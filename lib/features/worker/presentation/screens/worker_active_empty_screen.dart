import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/worker_ui_contracts.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Active Booking',
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (_) {
              final isOnline = session.availabilityStatus.isOnline;
              final badgeColor = isOnline
                  ? AppColors.success
                  : AppColors.outline;
              final textColor = isOnline
                  ? AppColors.successDark
                  : AppColors.onSurfaceVariant;
              return Container(
                margin: const EdgeInsets.only(right: AppSpacing.md),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: AppTypography.badge.copyWith(
                        color: textColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppColors.cardRadius),
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
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(PhosphorIcons.wrench(), size: 48),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Icon(
                    PhosphorIcons.briefcase(),
                    size: 40,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('No active job', style: AppTypography.titleMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'When you accept a request, it will appear here. Keep your status online to receive new opportunities.',
              style: AppTypography.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
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
