import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/features/worker/presentation/models/worker_stats.dart';

class PerformanceOverviewCard extends StatelessWidget {
  const PerformanceOverviewCard({
    super.key,
    required this.stats,
    required this.totalEarnings,
    required this.isLoading,
  });

  final WorkerStats? stats;
  final double? totalEarnings;
  final bool isLoading;

  String _formatCurrency(double? amount) {
    if (amount == null) return 'GH₵ 0.00';
    return 'GH₵ ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final double rating = stats?.rating ?? 0.0;
    final int reviewCount = stats?.reviewCount ?? 0;
    final int totalJobs = stats?.totalJobs ?? 0;
    final String responseLabel = stats?.responseLabel ?? '--';
    final String earningsText = _formatCurrency(totalEarnings);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.lg),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _CleanStatTile(
                  label: 'Total Earnings',
                  value: earningsText,
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: DesignTokens.md),
              Expanded(
                child: _CleanStatTile(
                  label: 'Jobs Completed',
                  value: '$totalJobs',
                  icon: Icons.work_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _CleanStatTile(
                  label: 'Average Rating',
                  value: rating > 0 ? '${rating.toStringAsFixed(1)} ★' : '--',
                  subtitle: reviewCount > 0 ? '$reviewCount reviews' : null,
                  icon: Icons.star_outline_rounded,
                ),
              ),
              const SizedBox(width: DesignTokens.md),
              Expanded(
                child: _CleanStatTile(
                  label: 'Response Time',
                  value: responseLabel,
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CleanStatTile extends StatelessWidget {
  const _CleanStatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: DesignTokens.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                color: DesignTokens.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
