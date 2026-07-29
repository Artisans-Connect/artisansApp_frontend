import 'dart:async';

import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/services/workers_service.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/job_detail_card.dart';
import 'worker_completion_form_screen.dart';

class WorkerPendingApprovalScreen extends StatefulWidget {
  const WorkerPendingApprovalScreen({super.key, required this.job});

  final WorkerJob job;

  @override
  State<WorkerPendingApprovalScreen> createState() => _WorkerPendingApprovalScreenState();
}

class _WorkerPendingApprovalScreenState extends State<WorkerPendingApprovalScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isCancelling = false;

  Future<void> _confirmCancel(
    BuildContext context,
    WorkerSessionState session,
    WorkerJob job,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text(
          'The client will be notified and can request another worker.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cancel booking',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isCancelling = true);
    try {
      await _workersService.cancelJob(job.id);
      if (!mounted) return;
      session.cancelActiveJob();
      AppToast.showInfo(context, 'Booking cancelled. The client was notified.');
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not cancel booking.');
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Awaiting Approval',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.md,
          AppSpacing.gutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        PhosphorIcons.clockCountdown,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.job.title,
                          style: AppTypography.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Your completion report has been sent to ${widget.job.clientName}. You can take another job after the client approves or reopens this booking.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('CLIENT', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.xs),
                  Text(widget.job.clientName, style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text('LOCATION', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.xs),
                  Text(widget.job.addressLabel, style: AppTypography.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.job.grossAmount != null || widget.job.earnedAmount != null) ...[
              JobDetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('PROPOSED PAYOUT', style: AppTypography.labelCaps),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'GH₵ ${(widget.job.earnedAmount ?? widget.job.grossAmount ?? 0).toStringAsFixed(2)}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.job.baseRate != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Base: GH₵ ${widget.job.baseRate!.toStringAsFixed(2)} • Distance: GH₵ ${(widget.job.distanceCost ?? 0).toStringAsFixed(2)}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkerCompletionFormScreen(
                      job: widget.job,
                      onCompletionSubmitted: () {
                        unawaited(WorkerScope.read(context).loadActiveJob());
                      },
                    ),
                  ),
                );
              },
              icon: Icon(PhosphorIcons.pencilSimple),
              label: const Text('Edit completion details'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _isCancelling ? null : () => _confirmCancel(context, session, widget.job),
              child: Text(
                _isCancelling ? 'Cancelling...' : 'Cancel Booking',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
