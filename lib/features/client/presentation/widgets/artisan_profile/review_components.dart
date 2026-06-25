import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';
import 'profile_atoms.dart';

/// Rating summary bar row (e.g. the 5-star breakdown on the Reviews tab).
class RatingBarRow extends StatelessWidget {
  const RatingBarRow({super.key, required this.star, required this.fraction});
  final int star;
  final double fraction; // 0.0 – 1.0
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '$star',
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            color: DesignTokens.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              backgroundColor: DesignTokens.warmTint,
              color: DesignTokens.primary,
            ),
          ),
        ),
      ],
    );
  }
}
 
/// A single review card.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});
  final Map<String, dynamic> review;
 
  String _relativeDate(String? raw) {
    if (raw == null) return '';
    try {
      final DateTime dt = DateTime.parse(raw);
      final Duration diff = DateTime.now().difference(dt);
      if (diff.inDays < 1) return 'Today';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (_) {
      return '';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final String reviewerName =
        review['profiles']?['full_name']?.toString() ?? 'Client';
    final int rating = (review['rating'] as int?) ?? 0;
    final String comment =
        (review['comment'] as String?) ?? 'No comment provided.';
    final String dateLabel = _relativeDate(review['created_at'] as String?);
 
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.md),
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                reviewerName,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textPrimary,
                ),
              ),
              Row(
                children: <Widget>[
                  StarRow(rating: rating, size: 13),
                  if (dateLabel.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11,
                        color: DesignTokens.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.sm),
          Text(
            comment,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
