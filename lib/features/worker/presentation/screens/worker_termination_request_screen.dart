import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/workers_service.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/gradient_button.dart';
import '../widgets/job_detail_card.dart';

class WorkerTerminationRequestScreen extends StatefulWidget {
  const WorkerTerminationRequestScreen({super.key, required this.job});

  final WorkerJob job;

  @override
  State<WorkerTerminationRequestScreen> createState() =>
      _WorkerTerminationRequestScreenState();
}

class _WorkerTerminationRequestScreenState
    extends State<WorkerTerminationRequestScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isResponding = false;

  Future<void> _respond(bool accept) async {
    if (_isResponding) return;
    final WorkerSessionState session = WorkerScope.of(context);
    setState(() => _isResponding = true);
    try {
      final dynamic updated = await _workersService.respondToTermination(
        widget.job.id,
        accept: accept,
      );
      if (!mounted) return;
      if (accept) {
        session.cancelActiveJob();
        AppToast.showInfo(context, 'Termination accepted. Booking cancelled.');
      } else if (updated is Map<String, dynamic>) {
        session.updateActiveJobFromApi(updated);
        AppToast.showSuccess(
            context, 'Termination declined. Continue the job.');
      } else {
        session.markJobStarted();
        AppToast.showSuccess(
            context, 'Termination declined. Continue the job.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          e,
          fallback: 'Could not respond to termination request.',
        );
      }
    } finally {
      if (mounted) setState(() => _isResponding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final WorkerJob job = widget.job;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Termination Request',
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
                  Text(job.title, style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${job.clientName} wants to stop this job. Accept only if you agree the work should end now.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: 'Accept termination',
              enabled: !_isResponding,
              isLoading: _isResponding,
              onPressed: () => _respond(true),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: _isResponding ? null : () => _respond(false),
              child: const Text('Decline and continue work'),
            ),
          ],
        ),
      ),
    );
  }
}
