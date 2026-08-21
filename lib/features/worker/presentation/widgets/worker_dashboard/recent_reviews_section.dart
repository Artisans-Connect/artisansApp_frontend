import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/features/worker/presentation/models/worker_stats.dart';

class RecentReviewsSection extends StatelessWidget {
  const RecentReviewsSection({
    super.key,
    required this.reviews,
    required this.onSeeAll,
  });

  final List<WorkerReviewSummary> reviews;
  final VoidCallback onSeeAll;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Recent Reviews',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See All →'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.md),
          if (reviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'No recent reviews yet. Complete jobs to receive feedback from clients.',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  color: DesignTokens.textSecondary,
                  height: 1.5,
                ),
              ),
            )
          else
            ...reviews.map(
              (WorkerReviewSummary review) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.md),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.star, size: 16, color: DesignTokens.primary),
                          const SizedBox(width: 6),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.reviewerName,
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 13,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (review.comment != null && review.comment!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          review.comment!,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            color: DesignTokens.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (review.createdAt != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          _formatDate(review.createdAt),
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11,
                            color: DesignTokens.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
