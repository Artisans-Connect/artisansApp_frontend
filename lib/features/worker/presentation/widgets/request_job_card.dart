import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../models/worker_job.dart';
import 'package:artisans_app/core/theme/index.dart';
import '../utils/worker_formatters.dart';

class RequestJobCard extends StatelessWidget {
  const RequestJobCard({
    super.key,
    required this.job,
    required this.onAccept,
    this.onTap,
    this.isAcceptEnabled = true,
  });

  final WorkerJob job;
  final VoidCallback onAccept;
  final VoidCallback? onTap;
  final bool isAcceptEnabled;

  @override
  Widget build(BuildContext context) {
    final isAsap = job.urgency == JobUrgency.asap;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                    child: Text(job.title, style: AppTypography.titleLarge),
                  ),
                  _UrgencyPill(label: job.urgencyLabel, isAsap: isAsap),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.mapPin,
                    size: 16,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(job.locationLine, style: AppTypography.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryFixed,
                    child: Text(
                      job.clientName.substring(0, 1),
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.clientName,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.star,
                              size: 14,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${formatRating(job.clientRating)} (${job.reviewCount} reviews)',
                              style: AppTypography.bodyMedium.copyWith(
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
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEW CLIENT',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isAcceptEnabled ? onAccept : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isAcceptEnabled ? 'VIEW REQUEST' : 'GO ONLINE TO ACCEPT',
                    style: AppTypography.labelSmall.copyWith(
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
            : AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: isAsap ? const Color(0xFFB55D00) : AppColors.primary,
          fontSize: 10,
        ),
      ),
    );
  }
}
