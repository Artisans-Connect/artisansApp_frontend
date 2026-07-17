import 'dart:async';

import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../shared/presentation/navigation/shared_route_args.dart';
import '../../../../shared/presentation/screens/chat_detail_screen.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/job_site_map.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/client_contact_row.dart';
import '../widgets/elapsed_timer_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/job_detail_card.dart';
import 'worker_completion_form_screen.dart';
class WorkerActiveInProgressScreen extends StatefulWidget {
  const WorkerActiveInProgressScreen({super.key, required this.job});
  final WorkerJob job;

  @override
  State<WorkerActiveInProgressScreen> createState() =>
      _WorkerActiveInProgressScreenState();
}

class _WorkerActiveInProgressScreenState extends State<WorkerActiveInProgressScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);
    final WorkerJob job = widget.job;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'In Progress',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElapsedTimerCard(startedAt: job.startedAt),
            const SizedBox(height: AppSpacing.md),
            JobDetailCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryFixed,
                    child: Text(
                      job.clientName.substring(0, 1),
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.clientName, style: AppTypography.titleLarge),
                        Text(
                          'Residential Client',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  ClientContactRow(
                    onMessage: () => _openMessage(context, job),
                    onCall: () => _callClient(context, job),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (job.hasServiceLocation) ...[
              JobSiteMap(
                latitude: job.latitude,
                longitude: job.longitude,
                label: job.addressLabel,
                height: 220,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            JobDetailCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: PhosphorIcons.mapPin,
                    label: 'BOOKING LOCATION',
                    value: job.addressLabel,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _DetailRow(
                    icon: PhosphorIcons.fileText,
                    label: 'REQUEST DETAILS',
                    value: job.description,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: 'Mark as Complete',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkerCompletionFormScreen(
                      job: job,
                      onCompletionSubmitted: () {
                        unawaited(session.loadActiveJob());
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: _isCancelling ? null : () => _confirmCancel(context, session, job),
              icon: _isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(PhosphorIcons.xCircle, size: 18),
              label: Text(
                _isCancelling ? 'Cancelling booking...' : 'Cancel booking',
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
  void _openMessage(BuildContext context, WorkerJob job) {
    final String clientId = job.clientId ?? '';
    if (clientId.isEmpty) {
      AppToast.showInfo(context, 'Client chat is not available for this booking.');
      return;
    }
    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: ChatDetailArgs(
        conversationId: job.id,
        jobId: job.id,
        counterpartUserId: clientId,
        counterpartName: job.clientName,
        counterpartPhone: job.clientPhone,
        jobTitle: job.title,
      ),
    );
  }
  Future<void> _callClient(BuildContext context, WorkerJob job) async {
    final String phone =
        job.clientPhone?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '';
    if (phone.isEmpty) {
      AppToast.showInfo(context, 'Client phone number is not available yet.');
      return;
    }
    final bool launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!launched && context.mounted) {
      AppToast.showInfo(context, 'Could not start the call.');
    }
  }

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
      if (!context.mounted) return;
      session.cancelActiveJob();
      AppToast.showInfo(context, 'Booking cancelled. The client was notified.');
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, e, fallback: 'Could not cancel booking.');
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines,
  });
  final IconData icon;
  final String label;
  final String value;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 9)),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
