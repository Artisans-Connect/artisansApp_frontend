import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../shared/presentation/navigation/shared_route_args.dart';
import '../../../../shared/presentation/screens/chat_detail_screen.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/client_contact_row.dart';
import '../widgets/gradient_button.dart';
import '../../../../shared/widgets/job_site_map.dart';

class WorkerActivePreStartScreen extends StatefulWidget {
  const WorkerActivePreStartScreen({
    super.key,
    required this.job,
    required this.phase,
  });
  final WorkerJob job;
  final WorkerJobPhase phase;
  @override
  State<WorkerActivePreStartScreen> createState() =>
      _WorkerActivePreStartScreenState();
}

class _WorkerActivePreStartScreenState
    extends State<WorkerActivePreStartScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isStarting = false;
  bool _isOpeningDirections = false;
  bool _isAdvancing = false;
  bool _isCancelling = false;
  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);
    final job = widget.job;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'ACTIVE BOOKING',
              style: AppTypography.labelCaps.copyWith(fontSize: 9),
            ),
            Text(
              job.title,
              style: AppTypography.titleLarge.copyWith(fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JobSiteMap(
              latitude: job.latitude,
              longitude: job.longitude,
              label: job.addressLabel,
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
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
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.clientName,
                                style: AppTypography.titleLarge),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.star,
                                  size: 14,
                                  color: Color(0xFFFFB800),
                                ),
                                Text(
                                  ' ${job.clientRating}',
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('BOOKING ADDRESS', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(PhosphorIcons.mapPin, color: AppColors.outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.addressLabel,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('REQUEST DETAILS', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    job.description,
                    style: AppTypography.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PhaseHint(phase: widget.phase),
                  const SizedBox(height: AppSpacing.lg),
                  ..._buildPhaseActions(session, job),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _isCancelling || _isAdvancing || _isStarting
                        ? null
                        : () => _confirmCancel(session, job),
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
          ],
        ),
      ),
    );
  }

  void _openMessage(BuildContext context, WorkerJob job) {
    final String clientId = job.clientId ?? '';
    if (clientId.isEmpty) {
      AppToast.showInfo(
          context, 'Client chat is not available for this booking.');
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

  List<Widget> _buildPhaseActions(
    WorkerSessionState session,
    WorkerJob job,
  ) {
    final bool busy =
        _isAdvancing || _isStarting || _isOpeningDirections || _isCancelling;
    switch (widget.phase) {
      case WorkerJobPhase.accepted:
        return <Widget>[
          OutlineButton(
            label: 'Open directions',
            onPressed: busy ? null : () => _openDirectionsWithLoading(job),
          ),
          const SizedBox(height: AppSpacing.md),
          GradientButton(
            label: "I'm on my way",
            isLoading: _isAdvancing,
            enabled: !busy,
            onPressed: () => _markOnTheWay(session, job),
          ),
        ];
      case WorkerJobPhase.onTheWay:
        return <Widget>[
          OutlineButton(
            label: 'Open directions',
            onPressed: busy ? null : () => _openDirectionsWithLoading(job),
          ),
          const SizedBox(height: AppSpacing.md),
          GradientButton(
            label: "I've arrived",
            isLoading: _isAdvancing,
            enabled: !busy,
            onPressed: () => _markArrived(session, job),
          ),
        ];
      case WorkerJobPhase.arrived:
        return <Widget>[
          GradientButton(
            label: 'Start work',
            isLoading: _isStarting,
            enabled: !busy,
            onPressed: () => _startWork(session, job),
          ),
        ];
      case WorkerJobPhase.inProgress:
      case WorkerJobPhase.terminationRequested:
      case WorkerJobPhase.pendingApproval:
      case WorkerJobPhase.none:
        return const <Widget>[];
    }
  }

  Future<void> _markOnTheWay(
    WorkerSessionState session,
    WorkerJob job,
  ) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _isAdvancing = true);
    try {
      final dynamic updated = await _workersService.markOnTheWay(job.id);
      if (!mounted) return;
      if (updated is Map<String, dynamic>) {
        session.updateActiveJobFromApi(updated);
      } else {
        session.markOnTheWay();
      }
      AppToast.showSuccess(context, 'Client notified that you are on the way.');
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e,
            fallback: 'Could not update job status.');
      }
    } finally {
      if (mounted) setState(() => _isAdvancing = false);
    }
  }

  Future<void> _markArrived(
    WorkerSessionState session,
    WorkerJob job,
  ) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _isAdvancing = true);
    try {
      final dynamic updated = await _workersService.markArrived(job.id);
      if (!mounted) return;
      if (updated is Map<String, dynamic>) {
        session.updateActiveJobFromApi(updated);
      } else {
        session.markArrived();
      }
      AppToast.showSuccess(context, 'Arrival confirmed.');
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not confirm arrival.');
      }
    } finally {
      if (mounted) setState(() => _isAdvancing = false);
    }
  }

  Future<void> _startWork(
    WorkerSessionState session,
    WorkerJob job,
  ) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _isStarting = true);
    try {
      final dynamic updated = await _workersService.startJob(job.id);
      if (!mounted) return;
      if (updated is Map<String, dynamic>) {
        session.updateActiveJobFromApi(updated);
      } else {
        session.markJobStarted();
      }
      AppToast.showSuccess(context, 'Work started!');
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Failed to start job.');
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _openDirectionsWithLoading(WorkerJob job) async {
    setState(() => _isOpeningDirections = true);
    try {
      await _openDirections(job);
    } finally {
      if (mounted) setState(() => _isOpeningDirections = false);
    }
  }

  Future<void> _confirmCancel(
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

  Future<void> _openDirections(WorkerJob job) async {
    if (!job.hasServiceLocation) {
      AppToast.showInfo(context, 'Job location is not available yet.');
      return;
    }
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${job.latitude},${job.longitude}',
    );
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      AppToast.showInfo(context, 'Could not open directions.');
    }
  }
}

class _PhaseHint extends StatelessWidget {
  const _PhaseHint({required this.phase});

  final WorkerJobPhase phase;

  @override
  Widget build(BuildContext context) {
    final String text = switch (phase) {
      WorkerJobPhase.accepted =>
        'Open directions, then tell the client when you are on the way.',
      WorkerJobPhase.onTheWay =>
        'Keep directions handy and confirm arrival when you reach the job site.',
      WorkerJobPhase.arrived =>
        'Only start work after you have met the client and are ready to begin.',
      WorkerJobPhase.inProgress => 'Work is already in progress.',
      WorkerJobPhase.terminationRequested => '',
      WorkerJobPhase.pendingApproval => '',
      WorkerJobPhase.none => '',
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}
