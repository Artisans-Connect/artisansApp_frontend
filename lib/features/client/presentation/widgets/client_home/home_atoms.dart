import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';

BoxDecoration _card({
  Color color = DesignTokens.surfaceCard,
  double radius = DesignTokens.radiusXl,
  bool shadow = true,
}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: DesignTokens.borderSubtle),
      boxShadow: shadow
          ? const <BoxShadow>[
              BoxShadow(
                  color: DesignTokens.shadowDeep, blurRadius: 20, offset: Offset(0, 6)),
              BoxShadow(
                  color: DesignTokens.shadow, blurRadius: 4, offset: Offset(0, 2)),
            ]
          : null,
    );

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });
  
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: DesignTokens.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });
  
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 3,
              height: 16,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: DesignTokens.primary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: DesignTokens.primaryTint08,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
