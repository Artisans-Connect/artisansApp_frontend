import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../models/worker_job.dart';
import 'package:artisans_app/core/theme/index.dart';

class TimingEstimateRow extends StatelessWidget {
  const TimingEstimateRow({super.key, required this.job});

  final WorkerJob job;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            label: 'TIMING',
            icon: PhosphorIcons.lightning,
            value: job.urgency == JobUrgency.asap ? 'ASAP' : job.urgencyLabel,
            valueColor: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _InfoCard(
            label: 'ESTIMATE',
            icon: PhosphorIcons.money,
            value: job.estimateDisplay,
            valueColor: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final IconData icon;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 9)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.titleMd.copyWith(
                    color: valueColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
