import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({
    super.key,
    required this.onOpenEarnings,
    required this.onOpenReviews,
    required this.onOpenGallery,
    required this.onOpenHistory,
  });

  final VoidCallback onOpenEarnings;
  final VoidCallback onOpenReviews;
  final VoidCallback onOpenGallery;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final double itemWidth =
        (MediaQuery.of(context).size.width - DesignTokens.gutter * 2 - DesignTokens.md) /
            2;

    return Wrap(
      spacing: DesignTokens.md,
      runSpacing: DesignTokens.md,
      children: <Widget>[
        QuickAccessTile(
          icon: Icons.payments_rounded,
          label: 'Earnings',
          width: itemWidth,
          onTap: onOpenEarnings,
        ),
        QuickAccessTile(
          icon: Icons.rate_review,
          label: 'Reviews',
          width: itemWidth,
          onTap: onOpenReviews,
        ),
        QuickAccessTile(
          icon: Icons.photo_library,
          label: 'Gallery',
          width: itemWidth,
          onTap: onOpenGallery,
        ),
        QuickAccessTile(
          icon: Icons.history,
          label: 'History',
          width: itemWidth,
          onTap: onOpenHistory,
        ),
      ],
    );
  }
}

class QuickAccessTile extends StatelessWidget {
  const QuickAccessTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.width,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Open',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary.withAlpha(24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: DesignTokens.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
