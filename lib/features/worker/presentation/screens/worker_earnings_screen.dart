import 'package:flutter/material.dart';
import '../../../../shared/presentation/screens/user_profile_screen.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class WorkerEarningsScreen extends StatelessWidget {
  const WorkerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: WorkerColors.primary,
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          'Earnings',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.primary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: WorkerSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.pushNamed(context, UserProfileScreen.routeName);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: WorkerColors.primaryFixed,
                child: const Icon(Icons.person, color: WorkerColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WorkerSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(WorkerSpacing.lg),
              decoration: BoxDecoration(
                color: WorkerColors.surface,
                borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL EARNED (DEMO)', style: WorkerTextStyles.labelCaps),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₵0.00',
                        style: WorkerTextStyles.displayMd.copyWith(
                          color: WorkerColors.accentBlue,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Coming soon', style: WorkerTextStyles.bodyMd),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: WorkerColors.successDark,
                        size: 18,
                      ),
                      Text(
                        ' +0% this month',
                        style: WorkerTextStyles.bodyMd.copyWith(
                          color: WorkerColors.successDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.md),
            Container(
              padding: const EdgeInsets.all(WorkerSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFB55D00)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Artisans does not process payments. Agree payment directly with each client.',
                      style: WorkerTextStyles.bodyMd.copyWith(
                        color: const Color(0xFF5D4037),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            Container(
              padding: const EdgeInsets.all(WorkerSpacing.lg),
              decoration: BoxDecoration(
                color: WorkerColors.surface,
                borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Weekly activity preview',
                        style: WorkerTextStyles.titleMd.copyWith(fontSize: 16),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Weekly insights coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: WorkerSpacing.md),
                  SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Bar(height: 40, label: 'M'),
                        _Bar(height: 55, label: 'T'),
                        _Bar(height: 35, label: 'W'),
                        _Bar(height: 50, label: 'T'),
                        _Bar(height: 80, label: 'F', highlight: true),
                        _Bar(height: 45, label: 'S'),
                        _Bar(height: 30, label: 'S'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
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
              icon: const Icon(Icons.history),
              label: const Text('View history'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            Text(
              'Payment integration coming in a future update. We\'re working on making secure in-app payments available for all Artisans soon.',
              style: WorkerTextStyles.bodyMd.copyWith(
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

class _Bar extends StatelessWidget {
  const _Bar({
    required this.height,
    required this.label,
    this.highlight = false,
  });

  final double height;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: highlight
                ? WorkerColors.primaryFixed
                : WorkerColors.surfaceContainer,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: WorkerTextStyles.bodyMd.copyWith(fontSize: 11)),
      ],
    );
  }
}
