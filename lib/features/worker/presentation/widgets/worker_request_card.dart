import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/category_icon_badge.dart';
import '../models/worker_job.dart';

class RequestJobCard extends StatelessWidget {
  const RequestJobCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.onViewDetails,
    required this.onAccept,
    required this.isSelected,
  });
 
  final WorkerJob job;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;
  final VoidCallback onAccept;
  final bool isSelected;
 
  double? _parseAmount(String value) {
    final RegExp match = RegExp(r'[0-9]+(?:[.,][0-9]+)?');
    final RegExpMatch? result = match.firstMatch(value.replaceAll(' ', ''));
    if (result == null) return null;
    return double.tryParse(result.group(0)!.replaceAll(',', '.'));
  }
 
  @override
  Widget build(BuildContext context) {
    final double? quote = job.applicationTotalQuote;
    final double? estimate = _parseAmount(job.estimateDisplay);
    final double? difference = (estimate != null && quote != null) ? estimate - quote : null;
    final bool isUnderEstimate = difference != null && difference > 0;
    final Color diffColor = isUnderEstimate ? DesignTokens.successGreen : DesignTokens.textSecondary;

    return Material(
      color: isSelected ? DesignTokens.surfaceHighlight : DesignTokens.surfaceCard,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CategoryIconBadge(
                        iconName: job.categoryIconName,
                        colorHex: job.categoryColorHex,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    job.clientName,
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: DesignTokens.primary.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      'Selected',
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: DesignTokens.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                const Icon(Icons.star, size: 14, color: DesignTokens.accentGold),
                                const SizedBox(width: 4),
                                Text(
                                  job.clientRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: DesignTokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${job.reviewCount} jobs)',
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 12,
                                    color: DesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      _RequestBadge(label: job.urgencyLabel, isAccent: job.urgency == JobUrgency.asap || job.isUrgent),
                      const SizedBox(width: 8),
                      _RequestBadge(label: job.category, isAccent: false),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.locationLine,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            color: DesignTokens.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DesignTokens.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: DesignTokens.borderSubtle),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Client estimate',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 12,
                                      color: DesignTokens.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    job.estimateDisplay,
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Your quote',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 12,
                                      color: DesignTokens.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    quote != null ? 'GHS ${quote.toStringAsFixed(2)}' : '—',
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (difference != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Text(
                                isUnderEstimate ? '+GHS ${difference.toStringAsFixed(2)}' : 'GHS ${difference.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: diffColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isUnderEstimate ? 'saved for you' : 'above estimate',
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12,
                                  color: DesignTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Accept Job',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: DesignTokens.borderSubtle),
                      ),
                      child: const Text(
                        'View details',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyJobRequestFoundCard extends StatelessWidget {
  const NearbyJobRequestFoundCard({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onDecline,
  });
 
  final WorkerJob job;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CategoryIconBadge(
                iconName: job.categoryIconName,
                colorHex: job.categoryColorHex,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      job.clientName,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              JobTag(label: job.category),
              if (job.distanceKm != null) JobTag(label: job.distanceText, isDistance: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            job.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _Badge(label: 'Budget', value: job.estimateDisplay),
              const SizedBox(width: 10),
              _Badge(label: 'Arrival', value: job.urgencyLabel),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Decline Job'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Accept Job'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
class JobTag extends StatelessWidget {
  const JobTag({super.key, required this.label, this.isDistance = false});
  final String label;
  final bool isDistance;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDistance ? DesignTokens.warmTint : DesignTokens.surfaceBase,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(
          color: isDistance ? DesignTokens.warmBorder : DesignTokens.borderSubtle,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDistance ? DesignTokens.primaryDark : DesignTokens.textSecondary,
        ),
      ),
    );
  }
}

class _RequestBadge extends StatelessWidget {
  const _RequestBadge({required this.label, required this.isAccent});

  final String label;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent ? DesignTokens.primary.withValues(alpha: 0.14) : DesignTokens.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isAccent ? DesignTokens.primary : DesignTokens.textSecondary,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.value});
 
  final String label;
  final String value;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: DesignTokens.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
