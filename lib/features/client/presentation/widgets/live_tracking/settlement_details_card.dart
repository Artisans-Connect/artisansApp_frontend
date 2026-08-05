import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// SettlementDetailsCard – cost breakdown shown for pending-approval jobs
// ---------------------------------------------------------------------------

class SettlementDetailsCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const SettlementDetailsCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> comp =
        (job['completion_details'] as Map<String, dynamic>?) ??
            (job['completionDetails'] as Map<String, dynamic>?) ??
            job;
    final double? baseRate = (comp['base_rate'] as num?)?.toDouble() ??
        (job['base_rate'] as num?)?.toDouble();
    final double? distanceCost = (comp['distance_cost'] as num?)?.toDouble() ??
        (job['distance_cost'] as num?)?.toDouble();
    final double? urgencyPremium =
        (comp['urgency_premium'] as num?)?.toDouble() ??
            (job['urgency_premium'] as num?)?.toDouble();
    final double? grossAmount = (comp['gross_amount'] as num?)?.toDouble() ??
        (job['gross_amount'] as num?)?.toDouble();

    if (grossAmount == null || grossAmount == 0) {
      return const SizedBox.shrink();
    }

    Widget rowItem(String label, double amount, {bool isTotal = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
                color: isTotal ? DesignTokens.textPrimary : DesignTokens.textSecondary,
              ),
            ),
            Text(
              'GHS ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
                color: isTotal ? DesignTokens.primary : DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: DesignTokens.shadowMid,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: DesignTokens.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Settlement Summary',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: DesignTokens.borderSubtle, height: 1),
          const SizedBox(height: 8),
          if (baseRate != null && baseRate > 0)
            rowItem('Base Service Fee', baseRate),
          if (distanceCost != null && distanceCost > 0)
            rowItem('Travel Cost', distanceCost),
          if (urgencyPremium != null && urgencyPremium > 0)
            rowItem('Urgency Premium', urgencyPremium),
          const SizedBox(height: 8),
          const Divider(color: DesignTokens.borderSubtle, height: 1),
          const SizedBox(height: 8),
          rowItem(
            job['status'] == 'pending_client_approval' ? 'Final Proposed Charge' : 'Total Estimate',
            grossAmount,
            isTotal: true,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DesignTokens.primary.withAlpha((0.05 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job['status'] == 'pending_client_approval'
                        ? 'Please review and accept this final charge proposed by the artisan.'
                        : '*Estimate only. Final price settled directly.',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
