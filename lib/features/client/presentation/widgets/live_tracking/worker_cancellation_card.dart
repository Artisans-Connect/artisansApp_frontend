import 'package:flutter/material.dart';

import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// WorkerCancellationCard
// ---------------------------------------------------------------------------

class WorkerCancellationCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final String? jobUuid;
  final bool isLoading;
  final ValueChanged<String?> onRequestAnother;
  final VoidCallback? onCancelJob;

  const WorkerCancellationCard({
    super.key,
    required this.job,
    required this.jobUuid,
    required this.isLoading,
    required this.onRequestAnother,
    this.onCancelJob,
  });

  @override
  Widget build(BuildContext context) {
    final String reason = (job['cancelled_reason'] as String? ?? '').trim();
    final bool terminationAccepted =
        ((job['cancellation_stage'] as String?) ?? '').toLowerCase() ==
            'termination_requested';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: DesignTokens.error.withAlpha((0.18 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor:
                    DesignTokens.error.withAlpha((0.12 * 255).round()),
                child: Icon(Icons.error_outline_rounded,
                    color: DesignTokens.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  terminationAccepted
                      ? 'This job was terminated'
                      : 'The worker cancelled this booking',
                  style: AppTypography.titleLarge.copyWith(
                    color: DesignTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reason.isNotEmpty
                ? reason
                : 'You can reopen this same job and we will search for another available worker.',
            style: AppTypography.bodyMedium
                .copyWith(color: DesignTokens.textSecondary),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Find another artisan',
            isLoading: isLoading,
            isEnabled: !isLoading && jobUuid != null && jobUuid!.isNotEmpty,
            onPressed: () => onRequestAnother(jobUuid),
          ),
          if (onCancelJob != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading ? null : onCancelJob,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: DesignTokens.textSecondary
                        .withAlpha((0.3 * 255).round()),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Cancel this job',
                  style: AppTypography.bodyMedium.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
