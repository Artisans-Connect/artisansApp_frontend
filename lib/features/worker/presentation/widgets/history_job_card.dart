import 'package:flutter/material.dart';
import '../models/mock_worker_job.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class HistoryJobCard extends StatelessWidget {
  const HistoryJobCard({
    super.key,
    required this.job,
    this.onViewDetails,
  });

  final MockWorkerJob job;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final isCompleted = job.historyStatus == HistoryStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: WorkerSpacing.md),
      padding: const EdgeInsets.all(WorkerSpacing.md),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(job.title, style: WorkerTextStyles.titleMd),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? WorkerColors.success.withOpacity(0.15)
                      : WorkerColors.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Finished' : 'Cancelled',
                  style: WorkerTextStyles.badge.copyWith(
                    color: isCompleted
                        ? WorkerColors.successDark
                        : WorkerColors.error,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Client: ${job.clientName}',
            style: WorkerTextStyles.bodyMd,
          ),
          if (job.historyRating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < job.historyRating!.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: const Color(0xFFFFB800),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  job.historyRating!.toStringAsFixed(1),
                  style: WorkerTextStyles.bodyMd,
                ),
              ],
            ),
          ],
          const SizedBox(height: WorkerSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: WorkerColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                job.historyDate ?? '—',
                style: WorkerTextStyles.bodyMd,
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewDetails ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Details — coming soon')),
                      );
                    },
                child: Text(
                  'View details >',
                  style: WorkerTextStyles.bodyLg.copyWith(
                    color: WorkerColors.accentBlue,
                    fontSize: 13,
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
