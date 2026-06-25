import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// CompletionActions – approve & rate, reopen, or waiting-for-completion
// ---------------------------------------------------------------------------

class CompletionActions extends StatelessWidget {
  final bool canRate;
  final bool pendingApproval;
  final bool isReopeningCompletion;
  final VoidCallback onRate;
  final VoidCallback onReopen;

  const CompletionActions({
    super.key,
    required this.canRate,
    required this.pendingApproval,
    required this.isReopeningCompletion,
    required this.onRate,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingApproval) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RateButton(
            enabled: true,
            label: 'Approve & Rate',
            icon: Icons.star_rounded,
            onTap: onRate,
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: isReopeningCompletion ? null : onReopen,
            child:
                Text(isReopeningCompletion ? 'Reopening...' : 'Job not done'),
          ),
        ],
      );
    }

    return RateButton(
      enabled: canRate,
      label: canRate ? 'Rate Your Experience' : 'Waiting for Completion',
      icon: canRate ? Icons.star_rounded : Icons.hourglass_top_rounded,
      onTap: canRate ? onRate : null,
    );
  }
}

// ---------------------------------------------------------------------------
// RateButton – gradient CTA button
// ---------------------------------------------------------------------------

class RateButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const RateButton({
    super.key,
    required this.enabled,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [DesignTokens.primary, DesignTokens.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : const Color(0xFFE8E0D8),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                      color: DesignTokens.primary.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled ? DesignTokens.accentGold : DesignTokens.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
