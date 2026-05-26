import 'package:flutter/material.dart';
import '../models/mock_worker_job.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
import '../utils/worker_formatters.dart';

class RequestJobCard extends StatelessWidget {
  const RequestJobCard({
    super.key,
    required this.job,
    required this.onAccept,
    this.onTap,
  });

  final MockWorkerJob job;
  final VoidCallback onAccept;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAsap = job.urgency == JobUrgency.asap;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
        child: Ink(
          padding: const EdgeInsets.all(WorkerSpacing.md),
          decoration: BoxDecoration(
            color: WorkerColors.surface,
            borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(job.title, style: WorkerTextStyles.titleMd),
                  ),
                  _UrgencyPill(label: job.urgencyLabel, isAsap: isAsap),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: WorkerColors.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(job.locationLine, style: WorkerTextStyles.bodyMd),
                  ),
                ],
              ),
              const SizedBox(height: WorkerSpacing.md),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: WorkerColors.primaryFixed,
                    child: Text(
                      job.clientName.substring(0, 1),
                      style: WorkerTextStyles.titleMd.copyWith(
                        color: WorkerColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: WorkerSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.clientName,
                          style: WorkerTextStyles.bodyLg.copyWith(
                            color: WorkerColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${formatRating(job.clientRating)} (${job.reviewCount} reviews)',
                              style: WorkerTextStyles.bodyMd.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (job.isNewClient)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: WorkerColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEW CLIENT',
                        style: WorkerTextStyles.badge.copyWith(
                          color: WorkerColors.successDark,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: WorkerSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: WorkerColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'ACCEPT',
                    style: WorkerTextStyles.badge.copyWith(
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrgencyPill extends StatelessWidget {
  const _UrgencyPill({required this.label, required this.isAsap});

  final String label;
  final bool isAsap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAsap
            ? const Color(0xFFFFE4D6)
            : WorkerColors.primaryFixed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: WorkerTextStyles.badge.copyWith(
          color: isAsap ? const Color(0xFFB55D00) : WorkerColors.primary,
          fontSize: 10,
        ),
      ),
    );
  }
}
