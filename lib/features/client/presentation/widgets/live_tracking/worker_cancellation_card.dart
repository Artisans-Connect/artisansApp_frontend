import 'package:flutter/material.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// WorkerCancellationCard
// ---------------------------------------------------------------------------

class WorkerCancellationCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final String? jobUuid;
  final bool isLoading;
  final ValueChanged<String?> onRequestAnother;

  const WorkerCancellationCard({
    super.key,
    required this.job,
    required this.jobUuid,
    required this.isLoading,
    required this.onRequestAnother,
  });

  @override
  Widget build(BuildContext context) {
    final String reason = (job['cancelled_reason'] as String? ?? '').trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DesignTokens.error.withAlpha((0.18 * 255).round())),
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
                backgroundColor: DesignTokens.error.withAlpha((0.12 * 255).round()),
                child: Icon(Icons.error_outline_rounded, color: DesignTokens.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'The worker cancelled this booking',
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
            style: AppTypography.bodyMedium.copyWith(color: DesignTokens.textSecondary),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Request another worker',
            isLoading: isLoading,
            isEnabled: !isLoading && jobUuid != null && jobUuid!.isNotEmpty,
            onPressed: () => onRequestAnother(jobUuid),
          ),
        ],
      ),
    );
  }
}
