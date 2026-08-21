import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';

import 'package:artisans_app/shared/models/worker_job.dart';
import 'package:artisans_app/features/worker/presentation/widgets/job_detail_card.dart';
import 'package:artisans_app/shared/widgets/custom_back_button.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/report_submission_bottom_sheet.dart';
import 'package:artisans_app/features/worker/presentation/screens/rate_client_screen.dart';
import 'package:artisans_app/core/services/reviews_service.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WorkerBookingDetailScreen extends StatefulWidget {
  const WorkerBookingDetailScreen({super.key, required this.job});

  final WorkerJob job;

  @override
  State<WorkerBookingDetailScreen> createState() =>
      _WorkerBookingDetailScreenState();
}

class _WorkerBookingDetailScreenState extends State<WorkerBookingDetailScreen> {
  final ReviewsService _reviewsService = ReviewsService();
  bool _hasReviewed = false;
  bool _checkingReview = true;

  @override
  void initState() {
    super.initState();
    _checkReviewStatus();
  }

  Future<void> _checkReviewStatus() async {
    if (widget.job.historyStatus != HistoryStatus.completed) {
      if (mounted) setState(() => _checkingReview = false);
      return;
    }
    final bool reviewed =
        await _reviewsService.hasReviewedClientForJob(widget.job.id);
    if (mounted) {
      setState(() {
        _hasReviewed = reviewed;
        _checkingReview = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool completed = widget.job.historyStatus == HistoryStatus.completed;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Booking Details',
          style: AppTypography.titleLarge.copyWith(color: AppColors.onSurface),
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
                      Expanded(child: Text(widget.job.title, style: AppTypography.titleLarge)),
                      _StatusPill(completed: completed),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Client: ${widget.job.clientName}', style: AppTypography.bodyLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(widget.job.addressLabel, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(widget.job.estimateDisplay, style: AppTypography.bodyMedium),
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
                    widget.job.description.isEmpty
                        ? 'No request details provided.'
                        : widget.job.description,
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
                      value: widget.job.completionHours == null
                          ? 'Not provided'
                          : '${widget.job.completionHours!.toStringAsFixed(1)} hours',
                    ),
                    _DetailRow(
                      label: 'Materials',
                      value: _blankAsFallback(
                        widget.job.completionMaterials,
                        'No materials recorded',
                      ),
                    ),
                    _DetailRow(
                      label: 'Notes',
                      value: _blankAsFallback(
                        widget.job.completionNotes,
                        'No notes recorded',
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.job.completionPhotoUrls.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text('COMPLETION PHOTOS', style: AppTypography.labelCaps),
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.job.completionPhotoUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                  ),
                  itemBuilder: (_, int index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.job.completionPhotoUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              // Rate Client button — only for completed jobs, hidden if already reviewed
              if (!_checkingReview && !_hasReviewed) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: () async {
                    final bool? submitted = await Navigator.of(context).push(
                      MaterialPageRoute<bool>(
                        builder: (_) => RateClientScreen(
                          jobId: widget.job.id,
                          clientId: widget.job.clientId ?? '',
                          clientName: widget.job.clientName,
                          clientAvatarUrl: widget.job.clientAvatarUrl,
                          jobTitle: widget.job.title,
                          onReviewSubmitted: () {
                            if (mounted) setState(() => _hasReviewed = true);
                          },
                        ),
                      ),
                    );
                    // Also hide button if user submitted via the screen's pop(true)
                    if (submitted == true && mounted) {
                      setState(() => _hasReviewed = true);
                    }
                  },
                  icon: Icon(PhosphorIcons.star, color: AppColors.primary),
                  label: Text(
                    'Rate Client',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                ReportSubmissionBottomSheet.show(
                  context,
                  bookingId: widget.job.id,
                  reportedId: widget.job.clientId,
                  reportedName: widget.job.clientName,
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
