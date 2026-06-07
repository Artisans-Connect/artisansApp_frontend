import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../shared/presentation/screens/user_profile_screen.dart';
import '../state/worker_session_state.dart';
class WorkerEarningsScreen extends StatelessWidget {
  const WorkerEarningsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(PhosphorIcons.caretLeft, size: 20),
                color: AppColors.primary,
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          'Earnings',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.pushNamed(context, UserProfileScreen.routeName);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryFixed,
                child: Icon(PhosphorIcons.user, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL EARNED (DEMO)', style: AppTypography.labelCaps),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₵0.00',
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.accentBlue,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Coming soon', style: AppTypography.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.trendUp,
                        color: AppColors.success,
                        size: 18,
                      ),
                      Text(
                        ' +0% this month',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(PhosphorIcons.info, color: Color(0xFFB55D00)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ArtisansConnect does not process payments. Agree payment directly with each client.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: const Color(0xFF5D4037),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () {
                WorkerScope.of(context).setProfilePage(WorkerProfilePage.stats);
              },
              child: const Text('View your stats'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                WorkerScope.of(context).setProfilePage(WorkerProfilePage.history);
              },
              icon: Icon(PhosphorIcons.clockCounterClockwise),
              label: const Text('View history'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Payment integration coming in a future update. We\'re working on making secure in-app payments available on ArtisansConnect soon.',
              style: AppTypography.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
