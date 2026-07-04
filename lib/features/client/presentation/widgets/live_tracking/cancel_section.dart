import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// CancelSection – cancel button, termination request, or waiting banner
// ---------------------------------------------------------------------------

class CancelSection extends StatelessWidget {
  final String status;
  final bool isCancelling;
  final bool isRequestingTermination;
  final VoidCallback onCancelJob;
  final VoidCallback onRequestTermination;

  const CancelSection({
    super.key,
    required this.status,
    required this.isCancelling,
    required this.isRequestingTermination,
    required this.onCancelJob,
    required this.onRequestTermination,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'termination_requested') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: DesignTokens.accentWarm.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignTokens.accentWarm.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: DesignTokens.accentWarm, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Waiting for artisan to respond to your termination request\u2026',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  color: DesignTokens.accentWarm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool showCancel = status == 'matched' || status == 'on_the_way' || status == 'arrived';
    final bool showTermination = status == 'in_progress';

    if (!showCancel && !showTermination) return const SizedBox.shrink();

    if (showTermination) {
      return OutlinedButton.icon(
        onPressed: isRequestingTermination ? null : onRequestTermination,
        icon: isRequestingTermination
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.front_hand_rounded, size: 16),
        label: Text(isRequestingTermination ? 'Sending\u2026' : 'Request Termination'),
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.accentWarm,
          side: BorderSide(color: DesignTokens.accentWarm.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    // Cancel button
    return OutlinedButton.icon(
      onPressed: isCancelling ? null : onCancelJob,
      icon: isCancelling
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cancel_outlined, size: 16),
      label: Text(isCancelling ? 'Cancelling\u2026' : 'Cancel Job'),
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.error,
        side: BorderSide(color: DesignTokens.error.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
