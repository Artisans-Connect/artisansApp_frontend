import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/shared/models/worker_job.dart';
class HistoryJobCard extends StatelessWidget {
  const HistoryJobCard({
    super.key,
    required this.job,
    this.onViewDetails,
  });
  final WorkerJob job;
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
            color: Colors.black.withValues(alpha: 0.04),
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
                child: Text(job.title, style: AppTypography.titleLarge),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.15)
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
          Row(
            children: [
              if (job.urgency == JobUrgency.asap) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flash_on, size: 11, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(
                        'ASAP',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Text(
                'Client: ${job.clientName}',
                style: AppTypography.bodyMedium,
              ),
            ],
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
                  style: AppTypography.bodyMedium,
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
                style: AppTypography.bodyMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewDetails,
                child: Text(
                  'View details >',
                  style: AppTypography.bodyLarge.copyWith(
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