import 'package:flutter/material.dart';
import '../models/mock_worker_job.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class TimingEstimateRow extends StatelessWidget {
  const TimingEstimateRow({super.key, required this.job});

  final MockWorkerJob job;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            label: 'TIMING',
            icon: Icons.bolt_rounded,
            value: job.urgency == JobUrgency.asap ? 'ASAP' : job.urgencyLabel,
            valueColor: WorkerColors.accentBlue,
          ),
        ),
        const SizedBox(width: WorkerSpacing.sm),
        Expanded(
          child: _InfoCard(
            label: 'ESTIMATE',
            icon: Icons.payments_outlined,
            value: job.estimateDisplay,
            valueColor: WorkerColors.onSurface,
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
      padding: const EdgeInsets.all(WorkerSpacing.md),
      decoration: BoxDecoration(
        color: WorkerColors.primaryFixed.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: WorkerTextStyles.labelCaps.copyWith(fontSize: 9)),
          const SizedBox(height: WorkerSpacing.sm),
          Row(
            children: [
              Icon(icon, size: 18, color: WorkerColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: WorkerTextStyles.titleMd.copyWith(
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
