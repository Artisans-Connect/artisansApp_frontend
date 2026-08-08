import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/widgets/category_icon_badge.dart';
import '../worker_request_card.dart'; // Ensure JobTag is available here

class PendingApplicationCard extends StatelessWidget {
  const PendingApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  final Map<String, dynamic> application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(application['job'] as Map? ?? const {});
    final dynamic category = job['categories'];
    final String categoryName = category is Map
        ? (category['name'] ?? 'Service').toString()
        : 'Service';
    final String status = (application['status'] ?? 'pending').toString();
    final bool accepted = status == 'accepted';
    final Object? clientEstimate = job['client_estimate'] ??
        job['budget_fixed'] ?? job['budget_min'] ?? job['budget_max'];
    final double? totalQuote = (application['total_quote'] as num?)?.toDouble() ??
        (application['proposed_rate'] as num?)?.toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.md),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          border: Border.all(color: DesignTokens.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CategoryIconBadge(
              iconName: category is Map ? category['icon_name']?.toString() : null,
              colorHex: category is Map ? category['color_hex']?.toString() : null,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (job['title'] ?? 'Job application').toString(),
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryName · ${job['address_label'] ?? 'Location pending'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                    ),
                  ),

                  if (clientEstimate != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Client estimate: GHS $clientEstimate',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                  if (totalQuote != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Your quote: GHS ${totalQuote.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            JobTag(label: accepted ? 'Accepted' : 'Pending'),
          ],
        ),
      ),
    );
  }
}
