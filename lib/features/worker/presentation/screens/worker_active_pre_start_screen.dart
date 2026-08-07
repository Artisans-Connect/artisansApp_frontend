import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/workers_service.dart';
import '../../../../core/theme/index.dart';
import '../../../../shared/presentation/navigation/shared_route_args.dart';
import '../../../../shared/presentation/screens/chat_detail_screen.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/job_site_map.dart';
import '../../../client/presentation/navigation/client_navigation.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/client_contact_row.dart';
import '../widgets/gradient_button.dart';
import '../widgets/worker_phase_stepper.dart';
import '../../../trust_safety/presentation/widgets/safety_help_bottom_sheet.dart';

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

  String _getPhaseBadgeLabel() {
    switch (widget.phase) {
      case WorkerJobPhase.accepted:
        return 'BOOKING CONFIRMED';
      case WorkerJobPhase.onTheWay:
        return 'EN ROUTE TO CLIENT';
      case WorkerJobPhase.arrived:
        return 'ARRIVED AT SITE';
      default:
        return 'ACTIVE BOOKING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
    final WorkerJob job = widget.job;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DesignTokens.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getPhaseBadgeLabel(),
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: DesignTokens.primary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              job.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: DesignTokens.primary),
            tooltip: 'Safety & Support',
            onPressed: () {
              SafetyHelpBottomSheet.show(
                context,
                bookingId: job.id,
                otherUserId: job.clientId,
                otherUserName: job.clientName,
                jobTitle: job.title,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Phase Stepper
              WorkerPhaseStepper(currentPhase: widget.phase),
              const SizedBox(height: DesignTokens.sm),

              // Interactive Map Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.gutter),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                  child: Stack(
                    children: <Widget>[
                      JobSiteMap(
                        latitude: job.latitude,
                        longitude: job.longitude,
                        label: job.addressLabel,
                        height: 200,
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _isOpeningDirections
                                ? null
                                : () => _openDirectionsWithLoading(job),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    PhosphorIcons.navigationArrow,
                                    size: 16,
                                    color: DesignTokens.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Directions',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: DesignTokens.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: DesignTokens.md),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Client Contact Card
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.md),
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceCard,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                        border: Border.all(color: DesignTokens.borderSubtle),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: DesignTokens.shadowMid,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: DesignTokens.primaryContainer,
                                child: Text(
                                  job.clientName.isNotEmpty
                                      ? job.clientName.substring(0, 1).toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: DesignTokens.primary,
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
                                    color: DesignTokens.successGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: DesignTokens.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        job.clientName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: AppTypography.displayFontFamily,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: DesignTokens.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      PhosphorIcons.sealCheckFill,
                                      size: 16,
                                      color: DesignTokens.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      PhosphorIcons.starFill,
                                      size: 14,
                                      color: Color(0xFFFFB800),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${job.clientRating} • Client',
                                      style: const TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 12,
                                        color: DesignTokens.textSecondary,
                                      ),
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

                    const SizedBox(height: DesignTokens.md),

                    // Booking Address & Details Card
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.lg),
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceCard,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                        border: Border.all(color: DesignTokens.borderSubtle),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: DesignTokens.shadow,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Address Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DesignTokens.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  PhosphorIcons.mapPin,
                                  size: 18,
                                  color: DesignTokens.primary,
                                ),
                              ),
                              const SizedBox(width: DesignTokens.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'SERVICE LOCATION',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: DesignTokens.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.addressLabel,
                                      style: const TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: DesignTokens.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: DesignTokens.md),
                            child: Divider(height: 1, color: DesignTokens.borderSubtle),
                          ),

                          // Description Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: DesignTokens.accentGold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  PhosphorIcons.fileText,
                                  size: 18,
                                  color: AppColors.secondaryContainer,
                                ),
                              ),
                              const SizedBox(width: DesignTokens.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'JOB DESCRIPTION',
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: DesignTokens.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      job.description.isNotEmpty
                                          ? job.description
                                          : 'No extra instructions provided.',
                                      style: const TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 13,
                                        color: DesignTokens.textSecondary,
                                        height: 1.4,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.md),

                    // Contextual Reassurance Guidance Banner
                    _PhaseHintBanner(phase: widget.phase),

                    const SizedBox(height: DesignTokens.lg),

                    // Phase Action Buttons
                    ..._buildPhaseActions(session, job),

                    const SizedBox(height: DesignTokens.sm),

                    // Safe Cancel Option
                    Center(
                      child: TextButton(
                        onPressed: _isCancelling || _isAdvancing || _isStarting
                            ? null
                            : () => _confirmCancel(session, job),
                        child: Text(
                          _isCancelling ? 'Cancelling...' : 'Cancel Booking',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.md),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMessage(BuildContext context, WorkerJob job) {
    final String clientId = job.clientId ?? '';
    if (clientId.isEmpty) {
      AppToast.showInfo(
        context,
        'Client chat is not available for this booking.',
      );
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
          GradientButton(
            label: "I'm on my way",
            isLoading: _isAdvancing,
            enabled: !busy,
            onPressed: () => _markOnTheWay(session, job),
          ),
          const SizedBox(height: DesignTokens.sm + 4),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: DesignTokens.borderSubtle),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              ),
            ),
            icon: const Icon(PhosphorIcons.navigationArrow, size: 18),
            label: const Text(
              'Open Navigation Maps',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimary,
              ),
            ),
            onPressed: busy ? null : () => _openDirectionsWithLoading(job),
          ),
        ];
      case WorkerJobPhase.onTheWay:
        return <Widget>[
          GradientButton(
            label: "I've arrived at site",
            isLoading: _isAdvancing,
            enabled: !busy,
            onPressed: () => _markArrived(session, job),
          ),
          const SizedBox(height: DesignTokens.sm + 4),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: DesignTokens.borderSubtle),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              ),
            ),
            icon: const Icon(PhosphorIcons.navigationArrow, size: 18),
            label: const Text(
              'Open Navigation Maps',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimary,
              ),
            ),
            onPressed: busy ? null : () => _openDirectionsWithLoading(job),
          ),
        ];
      case WorkerJobPhase.arrived:
        return <Widget>[
          GradientButton(
            label: 'Start Work Now',
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
        AppToast.showError(
          context,
          e,
          fallback: 'Could not update job status.',
        );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: DesignTokens.error),
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
    final String phone = job.clientPhone ?? '';
    await ClientNavigation.callPhone(context, phone);
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

class _PhaseHintBanner extends StatelessWidget {
  const _PhaseHintBanner({required this.phase});

  final WorkerJobPhase phase;

  @override
  Widget build(BuildContext context) {
    final String text = switch (phase) {
      WorkerJobPhase.accepted =>
        'Open navigation maps to preview the route, then tap "I\'m on my way" so the client receives live ETA updates.',
      WorkerJobPhase.onTheWay =>
        'Keep navigation active. Tap "I\'ve arrived at site" as soon as you arrive at the job location.',
      WorkerJobPhase.arrived =>
        'Meet the client and inspect the work site before tapping "Start Work Now".',
      WorkerJobPhase.inProgress => 'Work is in progress.',
      WorkerJobPhase.terminationRequested => '',
      WorkerJobPhase.pendingApproval => '',
      WorkerJobPhase.none => '',
    };

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: DesignTokens.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(
          color: DesignTokens.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            PhosphorIcons.info,
            size: 18,
            color: DesignTokens.primary,
          ),
          const SizedBox(width: DesignTokens.sm + 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                color: DesignTokens.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
