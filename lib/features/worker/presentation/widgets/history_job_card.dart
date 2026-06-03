import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../models/mock_worker_job.dart';
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
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
                child: Text(job.title, style: AppTypography.titleMd),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Finished' : 'Cancelled',
                  style: AppTypography.labelSmall.copyWith(
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Client: ${job.clientName}',
            style: AppTypography.bodyMd,
          ),
          if (job.historyRating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < job.historyRating!.round()
                        ? PhosphorIcons.star
                        : PhosphorIcons.star,
                    size: 16,
                    color: const Color(0xFFFFB800),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  job.historyRating!.toStringAsFixed(1),
                  style: AppTypography.bodyMd,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                PhosphorIcons.calendarBlank,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                job.historyDate ?? '—',
                style: AppTypography.bodyMd,
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
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.accentBlue,
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