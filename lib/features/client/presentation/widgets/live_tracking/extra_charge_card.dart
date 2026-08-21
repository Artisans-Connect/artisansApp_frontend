import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/shared/models/negotiation.dart';

class ExtraChargeCard extends StatelessWidget {
  final Map<String, dynamic>? activeExtraCharge;
  final VoidCallback? onNegotiate;

  const ExtraChargeCard({
    super.key,
    this.activeExtraCharge,
    this.onNegotiate,
  });

  @override
  Widget build(BuildContext context) {
    if (activeExtraCharge == null) return const SizedBox.shrink();
    final String status = activeExtraCharge!['status'] as String? ?? '';
    final double amount = (activeExtraCharge!['requested_amount'] as num?)?.toDouble() ?? 0.0;
    final String desc = activeExtraCharge!['description'] as String? ?? '';
    final Negotiation? neg = activeExtraCharge!['negotiation'] as Negotiation?;

    final bool isOpen = status == 'open';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOpen ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isOpen ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isOpen ? const Color(0xFFB45309) : const Color(0xFF047857),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOpen
                      ? '⚡ Pending Extra Charge Request (+GHS ${amount.toStringAsFixed(2)})'
                      : '✓ Agreed Extra Charge (+GHS ${amount.toStringAsFixed(2)})',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? const Color(0xFFB45309) : const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          if (desc.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              'Reason: $desc',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: DesignTokens.textPrimary,
              ),
            ),
          ],
          if (isOpen && neg != null && onNegotiate != null) ...<Widget>[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onNegotiate,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text(
                'Review & Negotiate Extra Charge',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
