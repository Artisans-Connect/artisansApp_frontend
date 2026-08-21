import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';

import 'package:artisans_app/shared/models/worker_job.dart';
import 'package:artisans_app/features/worker/presentation/widgets/job_detail_card.dart';
import 'package:artisans_app/shared/widgets/custom_back_button.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/report_submission_bottom_sheet.dart';

class WorkerBookingDetailScreen extends StatelessWidget {
  const WorkerBookingDetailScreen({super.key, required this.job});

  final WorkerJob job;

  @override
  Widget build(BuildContext context) {
    final bool completed = job.historyStatus == HistoryStatus.completed;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Booking Details',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: Text(job.title, style: AppTypography.titleLarge)),
                      _StatusPill(completed: completed),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Client: ${job.clientName}', style: AppTypography.bodyLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(job.addressLabel, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(job.estimateDisplay, style: AppTypography.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Request', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    job.description.isEmpty
                        ? 'No request details provided.'
                        : job.description,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            if (completed) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              JobDetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Completion Details', style: AppTypography.labelCaps),
                    const SizedBox(height: AppSpacing.md),
                    _DetailRow(
                      label: 'Time spent',
                      value: job.completionHours == null
                          ? 'Not provided'
                          : '${job.completionHours!.toStringAsFixed(1)} hours',
                    ),
                    _DetailRow(
                      label: 'Materials',
                      value: _blankAsFallback(
                        job.completionMaterials,
                        'No materials recorded',
                      ),
                    ),
                    _DetailRow(
                      label: 'Notes',
                      value: _blankAsFallback(
                        job.completionNotes,
                        'No notes recorded',
                      ),
                    ),
                  ],
                ),
              ),
              if (job.completionPhotoUrls.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text('COMPLETION PHOTOS', style: AppTypography.labelCaps),
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: job.completionPhotoUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                  ),
                  itemBuilder: (_, int index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      job.completionPhotoUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                ReportSubmissionBottomSheet.show(
                  context,
                  bookingId: job.id,
                  reportedId: job.clientId,
                  reportedName: job.clientName,
                );
              },
              icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              label: const Text('Report Concern / Issue', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _blankAsFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTypography.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        completed ? 'Completed' : 'Cancelled',
        style: AppTypography.labelSmall.copyWith(
          color: completed ? AppColors.success : AppColors.error,
          fontSize: 10,
        ),
      ),
    );
  }
}
