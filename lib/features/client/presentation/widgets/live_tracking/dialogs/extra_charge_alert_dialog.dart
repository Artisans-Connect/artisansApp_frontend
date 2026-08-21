import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';

class ExtraChargeAlertDialog extends StatelessWidget {
  final double amount;
  final String description;

  const ExtraChargeAlertDialog({
    super.key,
    required this.amount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: DesignTokens.accentWarm, size: 24),
          SizedBox(width: 8),
          Text(
            'Extra Charge Requested',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'The artisan requested an additional extra charge of +GHS ${amount.toStringAsFixed(2)} for this job.',
            style: const TextStyle(fontFamily: 'Satoshi', fontSize: 13, color: DesignTokens.textSecondary),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignTokens.warmSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DesignTokens.warmBorder),
              ),
              child: Text(
                'Reason: $description',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Dismiss'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignTokens.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Review & Bargain',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
