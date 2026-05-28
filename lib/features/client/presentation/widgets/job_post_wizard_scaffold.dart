import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../models/job_post_wizard_step.dart';

/// Shared layout for all job post wizard steps: progress, scroll body, pinned CTAs.
class JobPostWizardScaffold extends StatelessWidget {
  const JobPostWizardScaffold({
    super.key,
    required this.step,
    required this.headline,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
    this.onBack,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryEnabled = true,
    this.appBarTitle = 'Post a Job',
    this.showDiscardOnBack = false,
    this.onDiscard,
  });

  final JobPostWizardStep step;
  final String headline;
  final Widget child;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool primaryEnabled;
  final VoidCallback? onBack;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool secondaryEnabled;
  final String appBarTitle;
  final bool showDiscardOnBack;
  final VoidCallback? onDiscard;

  Future<bool> _confirmDiscard(BuildContext context) async {
    if (!showDiscardOnBack || onDiscard == null) return true;
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Discard job post?'),
        content: const Text(
          'Your progress will be lost if you leave now.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true) {
      onDiscard!();
    }
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !showDiscardOnBack,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool leave = await _confirmDiscard(context);
        if (leave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: CustomAppBar(
          title: appBarTitle,
          onBackPressed: () async {
            if (onBack != null) {
              onBack!();
              return;
            }
            if (showDiscardOnBack && onDiscard != null) {
              final bool leave = await _confirmDiscard(context);
              if (leave && context.mounted) {
                Navigator.pop(context);
              }
            } else if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WizardProgressHeader(step: step),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      headline,
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    child,
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.sm,
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                ),
                child: Row(
                  children: [
                    if (secondaryLabel != null) ...[
                      Expanded(
                        child: SecondaryButton(
                          label: secondaryLabel!,
                          onPressed: onSecondary ?? () {},
                          isEnabled:
                              secondaryEnabled && onSecondary != null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      flex: secondaryLabel != null ? 2 : 1,
                      child: PrimaryButton(
                        label: primaryLabel,
                        onPressed: onPrimary,
                        isEnabled: primaryEnabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WizardProgressHeader extends StatelessWidget {
  const _WizardProgressHeader({required this.step});

  final JobPostWizardStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              step.stepLabel,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
              ),
              child: Text(
                '${step.percentComplete}% complete',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          child: LinearProgressIndicator(
            value: step.progress,
            minHeight: 6,
            backgroundColor: AppColors.outlineVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
