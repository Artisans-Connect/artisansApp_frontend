import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';

class TipsCard extends StatelessWidget {
  const TipsCard({super.key, required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.lg),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: DesignTokens.shadowMid,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tips for Better Visibility',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.sm),
          Text(
            tip,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
