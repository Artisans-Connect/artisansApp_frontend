import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artisans_app/core/services/negotiation_service.dart';
import 'package:artisans_app/core/services/negotiation_realtime_service.dart';
import 'package:artisans_app/core/services/payment_service.dart';
import 'package:artisans_app/core/session/app_user_session.dart';
import 'package:artisans_app/shared/models/negotiation.dart';
import 'package:artisans_app/shared/widgets/negotiation_chat_sheet.dart';
import 'dart:async';
import 'package:artisans_app/features/client/presentation/screens/payment_checkout_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisans_app/core/errors/error_messages.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/services/job_realtime_service.dart';
import 'package:artisans_app/core/services/jobs_service.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/features/client/presentation/models/client_booking.dart';
import 'package:artisans_app/features/client/presentation/navigation/client_navigation.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';

import 'package:artisans_app/features/client/presentation/widgets/live_tracking/tracking_atoms.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/job_info_card.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/worker_cancellation_card.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/tracking_map_card.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/progress_timeline.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/artisan_detail_card.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/settlement_details_card.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/cancel_section.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/completion_actions.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/safety_help_bottom_sheet.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/dialogs/reopen_completion_dialog.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/dialogs/confirm_work_done_dialog.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/dialogs/cancel_job_dialog.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/dialogs/request_termination_dialog.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/dialogs/extra_charge_alert_dialog.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/extra_charge_card.dart';
import 'package:artisans_app/features/client/presentation/widgets/live_tracking/action_buttons_row.dart';

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

class LiveTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const LiveTrackingScreen({
    super.key,
    this.job,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  final JobsService _jobsService = JobsService();
  final JobRealtimeService _realtime = JobRealtimeService();

  Map<String, dynamic>? _job;
  Map<String, dynamic>? _activeExtraCharge;
  RealtimeChannel? _extraChargeChannel;
  String? _hasShownExtraChargeAlertId;
  bool _isModalOpen = false;
  bool _loading = true;
  bool _requestingAnotherWorker = false;
  bool _isReopeningCompletion = false;
  bool _isCancelling = false;
  bool _isRequestingTermination = false;
  bool _isConfirmingWorkDone = false;
  bool _suppressRealtimeRefresh = false;
  bool _hasNavigatedAway = false;
  String? _loadError;
  int _currentStep = 0;
  String _etaLabel = 'Calculating ETA…';

  // Animation for timeline step transitions
  late AnimationController _stepPulse;

  List<Map<String, dynamic>> get _steps => <Map<String, dynamic>>[
        {
          'title': 'Confirmed',
          'description': 'Job accepted by artisan',
          'icon': Icons.check_circle_rounded,
        },
        {
          'title': 'On the Way',
          'description': 'Artisan is heading to your location',
          'icon': Icons.directions_bike_rounded,
        },
        {
          'title': 'Arrived',
          'description': 'Artisan has arrived at your location',
          'icon': Icons.location_on_rounded,
        },
        {
          'title': 'Work in Progress',
          'description': 'Artisan is working on your job',
          'icon': Icons.settings_rounded,
        },
        {
          'title': 'Completed',
          'description': 'Job is done. Awaiting your approval',
          'icon': Icons.celebration_rounded,
        },
      ];

  @override
  void initState() {
    super.initState();
    _stepPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    _job = widget.job != null ? Map<String, dynamic>.from(widget.job!) : null;
    _applyStepFromStatus(_job?['status'] as String?);
    _loadJobDetails();
    final String? jobId = _currentJobId;
    if (jobId != null && jobId.isNotEmpty) {
      _realtime.subscribeToJob(jobId, onUpdate: _handleJobUpdate);
      _fetchExtraCharge(jobId);
      _subscribeExtraCharge(jobId);
    }
  }

  String? get _currentJobId =>
      _job?['job_id'] as String? ??
      _job?['jobId'] as String? ??
      _job?['id'] as String?;

  Future<void> _loadJobDetails() async {
    final String? jobId = _currentJobId;
    if (jobId == null || jobId.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = 'Job details unavailable or invalid job ID.';
      });
      return;
    }
    try {
      final dynamic raw = await _jobsService.getJobById(jobId);
      if (!mounted) return;
      if (raw is Map<String, dynamic>) {
        final ClientBooking booking = ClientBooking.fromApiJob(raw);
        final String status = (booking.backendStatus ?? '').toLowerCase();
        if (status == 'matching' || status == 'searching') {
          if (_hasNavigatedAway) return;
          _hasNavigatedAway = true;
          _realtime.unsubscribe();
          unawaited(Navigator.pushReplacementNamed(
            context,
            AppRoutes.findingArtisan,
            arguments: <String, dynamic>{
              'jobData': raw,
            },
          ));
          return;
        }
        setState(() {
          _job = booking.toTrackingMap();
          _loading = false;
          _loadError = null;
          _currentStep = _stepForStatus(booking.backendStatus);
        });
      } else {
        setState(() {
          _loading = false;
          _loadError = 'Could not retrieve details for this job.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = userMessageFor(e, fallback: 'Could not load job details.');
      });
    }
  }

  void _handleJobUpdate(Map<String, dynamic> job) {
    if (_suppressRealtimeRefresh) return;
    unawaited(_refreshFromRealtimeJob(job));
  }

  Future<void> _refreshFromRealtimeJob(Map<String, dynamic> job) async {
    Map<String, dynamic> fullJob = job;
    final String? jobId = job['id'] as String?;
    if (jobId != null && jobId.isNotEmpty) {
      try {
        final dynamic fetched = await _jobsService.getJobById(jobId);
        if (fetched is Map<String, dynamic>) {
          fullJob = fetched;
        }
      } catch (_) {
        fullJob = <String, dynamic>{...?_job, ...job};
      }
    }
    final ClientBooking booking = ClientBooking.fromApiJob(fullJob);
    if (!mounted) return;
    final String status = (booking.backendStatus ?? '').toLowerCase();
    if (status == 'matching' || status == 'searching') {
      if (_hasNavigatedAway) return;
      _hasNavigatedAway = true;
      _realtime.unsubscribe();
      unawaited(Navigator.pushReplacementNamed(
        context,
        AppRoutes.findingArtisan,
        arguments: <String, dynamic>{
          'jobData': fullJob,
        },
      ));
      return;
    }
    setState(() {
      _job = booking.toTrackingMap();
      _loading = false;
      _loadError = null;
      _currentStep = _stepForStatus(booking.backendStatus);
    });
  }

  int _stepForStatus(String? statusRaw) {
    final String status = (statusRaw ?? '').toLowerCase();
    return switch (status) {
      'scheduled_confirmed' => 0,
      'matched' => 0,
      'on_the_way' => 1,
      'arrived' => 2,
      'in_progress' => 3,
      'termination_requested' => 3,
      'pending_client_approval' => 4,
      'completed' => 4,
      _ => 0,
    };
  }

  String? _hasOpenedLiveBargainingSheetKey;
  final NegotiationRealtimeService _negotiationRealtime = NegotiationRealtimeService();

  Future<void> _fetchExtraCharge(String jobId) async {
    try {
      final List<Negotiation> negs = await NegotiationService.instance.getJobNegotiations(jobId);
      
      // 1. Strictly look for extra charge negotiations for summary tracking
      final Negotiation? extraChargeNeg = negs.cast<Negotiation?>().firstWhere(
        (n) => n?.type == NegotiationType.extraCharge && (n?.status == NegotiationStatus.open || n?.status == NegotiationStatus.accepted || n?.status == NegotiationStatus.paid),
        orElse: () => null,
      );

      // 2. Look for ANY open negotiation (extra charge, completion adjustment, or quote) for live sync
      final Negotiation? openNeg = negs.cast<Negotiation?>().firstWhere(
        (n) => n?.status == NegotiationStatus.open,
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          _activeExtraCharge = extraChargeNeg != null ? {
            'id': extraChargeNeg.id,
            'status': extraChargeNeg.status.name,
            'requested_amount': extraChargeNeg.agreedAmount ?? extraChargeNeg.initialAmount,
            'description': extraChargeNeg.description,
            'negotiation': extraChargeNeg,
          } : null;
        });

        // ONLY trigger extra charge alert modal if it's strictly an extra_charge proposal that is OPEN
        if (extraChargeNeg != null && 
            extraChargeNeg.type == NegotiationType.extraCharge && 
            extraChargeNeg.status == NegotiationStatus.open && 
            _hasShownExtraChargeAlertId != extraChargeNeg.id) {
          _hasShownExtraChargeAlertId = extraChargeNeg.id;
          final double amt = extraChargeNeg.agreedAmount ?? extraChargeNeg.initialAmount;
          _showExtraChargeAlertModal(extraChargeNeg, amt, extraChargeNeg.description ?? '');
        }
        final String currentUserId = AppUserSession.instance.currentUser?.id ?? '';
        final NegotiationRound? lastRound = openNeg?.rounds.isNotEmpty == true ? openNeg!.rounds.last : null;
        final bool isCounterpartyTurnToRespond = lastRound != null && lastRound.proposedBy != currentUserId;

        // Auto-popup live bargaining sheet when any negotiation is open or has a new round from counterparty
        if (openNeg != null && openNeg.status == NegotiationStatus.open && isCounterpartyTurnToRespond) {
          final String currentKey = '${openNeg.id}_${openNeg.rounds.length}';
          if (_hasOpenedLiveBargainingSheetKey != currentKey) {
            _hasOpenedLiveBargainingSheetKey = currentKey;
            _showLiveBargainingSheet(openNeg);
          }
        }
      }
    } catch (_) {
      // Silent catch
    }
  }

  void _showLiveBargainingSheet(Negotiation negotiation) {
    if (_isModalOpen) return;
    setState(() => _isModalOpen = true);
    NegotiationChatSheet.show(
      context,
      negotiation: negotiation,
      onStatusChanged: () {
        if (_currentJobId != null) _fetchExtraCharge(_currentJobId!);
      },
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isModalOpen = false);
    });
  }

  void _showExtraChargeAlertModal(Negotiation negotiation, double amount, String desc) {
    if (_isModalOpen) return;
    setState(() => _isModalOpen = true);
    showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext ctx) {
        return ExtraChargeAlertDialog(
          amount: amount,
          description: desc,
        );
      },
    ).then((bool? bargain) async {
      if (mounted) setState(() => _isModalOpen = false);
      if (bargain == true && mounted) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          NegotiationChatSheet.show(
            context,
            negotiation: negotiation,
            onStatusChanged: () {
              if (_currentJobId != null) _fetchExtraCharge(_currentJobId!);
            },
          );
        }
      }
    });
  }

  void _subscribeExtraCharge(String jobId) {
    _negotiationRealtime.subscribeToJobNegotiations(
      jobId,
      onUpdate: () {
        _fetchExtraCharge(jobId);
      },
    );
  }

  Widget _buildExtraChargeWidget() {
    if (_activeExtraCharge == null) return const SizedBox.shrink();
    final Negotiation? neg = _activeExtraCharge!['negotiation'] as Negotiation?;
    return ExtraChargeCard(
      activeExtraCharge: _activeExtraCharge,
      onNegotiate: neg != null ? () => _showLiveBargainingSheet(neg) : null,
    );
  }

  void _applyStepFromStatus(String? statusRaw) {
    if (!mounted) return;
    final int newStep = _stepForStatus(statusRaw);
    if (newStep != _currentStep) {
      HapticFeedback.mediumImpact();
    }
    setState(() => _currentStep = newStep);
  }

  @override
  void dispose() {
    _stepPulse.dispose();
    _realtime.unsubscribe();
    _negotiationRealtime.unsubscribeJob();
    _extraChargeChannel?.unsubscribe();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Action handlers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _ratingPayload() {
    final Map<String, dynamic> job = _job ?? <String, dynamic>{};
    return <String, dynamic>{
      'job_id': job['job_id'] ?? job['jobId'] ?? job['id'],
      'jobId': job['jobId'] ?? job['job_id'] ?? job['id'],
      'id': job['id'],
      'worker_id':
          job['worker_id'] ?? job['workerId'] ?? job['counterpartUserId'],
      'workerId':
          job['workerId'] ?? job['worker_id'] ?? job['counterpartUserId'],
      'counterpartUserId':
          job['counterpartUserId'] ?? job['worker_id'] ?? job['workerId'],
      'artisan': job['artisan'] ?? 'Artisan',
      'profession': job['profession'] ?? 'Service provider',
      'title': job['title'] ?? 'Service',
      'imageUrl': job['imageUrl'],
      'status': job['status'],
    };
  }

  Future<void> _requestAnotherWorker(String? jobUuid) async {
    if (_requestingAnotherWorker || jobUuid == null || jobUuid.isEmpty) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Continue searching?'),
        content: const Text(
          'We\'ll search for another available artisan for this same job. '
          'Your payment stays safely held in escrow.\n\n'
          'The artisan who just cancelled will not be contacted again.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _requestingAnotherWorker = true);
    try {
      final dynamic reopened = await _jobsService.requestAnotherWorker(jobUuid);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Searching for a new worker...');
      unawaited(Navigator.pushReplacementNamed(
        context,
        AppRoutes.findingArtisan,
        arguments: <String, dynamic>{
          'jobData': Map<String, dynamic>.from(reopened as Map),
        },
      ));
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not request another worker.',
      );
    } finally {
      if (mounted) setState(() => _requestingAnotherWorker = false);
    }
  }

  /// Client confirms the work is finished. Stops the settlement clock on the
  /// backend without changing job status (the worker still submits details).
  Future<void> _confirmWorkDone() async {
    final String? jobUuid = _currentJobId;
    if (_isConfirmingWorkDone || jobUuid == null || jobUuid.isEmpty) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmWorkDoneDialog(),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isConfirmingWorkDone = true);
    try {
      await _jobsService.confirmWorkDone(jobUuid);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      AppToast.showSuccess(
        context,
        'Marked as finished. The artisan will submit the completion details.',
      );
      await _loadJobDetails();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not confirm the work as finished.',
      );
    } finally {
      if (mounted) setState(() => _isConfirmingWorkDone = false);
    }
  }

  Future<void> _reopenCompletion() async {    final String? jobUuid = _currentJobId;
    if (_isReopeningCompletion || jobUuid == null || jobUuid.isEmpty) return;

    final String? note = await showDialog<String>(
      context: context,
      builder: (_) => const ReopenCompletionDialog(),
    );
    if (note == null || !mounted) return;

    setState(() {
      _isReopeningCompletion = true;
      _suppressRealtimeRefresh = true;
    });
    try {
      await _jobsService.reopenJob(
        jobUuid,
        body: <String, dynamic>{
          if (note.isNotEmpty) 'note': note,
        },
      );
      if (!mounted) return;
      await _loadJobDetails();
      if (!mounted) return;
      AppToast.showSuccess(context, 'Job reopened for the artisan.');
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not reopen this job.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isReopeningCompletion = false;
          _suppressRealtimeRefresh = false;
        });
      }
    }
  }

  Future<void> _handleCancelJob() async {
    final String? jobUuid = _currentJobId;
    if (_isCancelling || jobUuid == null || jobUuid.isEmpty) return;

    setState(() => _isCancelling = true);
    try {
      final dynamic preview =
          await _jobsService.getCancellationPreview(jobUuid);
      if (!mounted) return;

      if (preview is! Map<String, dynamic>) {
        setState(() => _isCancelling = false);
        return;
      }

      final bool canCancel = preview['can_cancel'] as bool? ?? false;
      if (!canCancel) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(preview['warning_message'] as String? ??
                  'Cannot cancel this job.')),
        );
        return;
      }

      final double fee = (preview['fee_amount'] as num?)?.toDouble() ?? 0;
      final String warningTitle =
          preview['warning_title'] as String? ?? 'Cancel this job?';
      final String warningMessage =
          preview['warning_message'] as String? ?? 'Are you sure?';

      final String? reason = await showDialog<String>(
        context: context,
        builder: (BuildContext ctx) {
          return CancelJobDialog(
            fee: fee,
            warningTitle: warningTitle,
            warningMessage: warningMessage,
          );
        },
      );

      if (reason == null || !mounted) {
        setState(() => _isCancelling = false);
        return;
      }

      await _jobsService.cancelJobWithReason(
        jobUuid,
        reason: reason.isNotEmpty ? reason : null,
      );
      if (!mounted) return;

      String snackMessage = 'Job cancelled.';
      if (fee > 0) {
        snackMessage =
            'Job cancelled. Please pay GH\u20B5 ${fee.toStringAsFixed(2)} to the artisan.';
      }

      AppToast.showInfo(context, snackMessage);
      ClientNavigation.goToBookingsTab(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not cancel this job.',
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _handleRequestTermination() async {
    final String? jobUuid = _currentJobId;
    if (_isRequestingTermination || jobUuid == null || jobUuid.isEmpty) return;

    final String? reason = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return const RequestTerminationDialog();
      },
    );

    if (reason == null || !mounted) {
      return;
    }

    setState(() => _isRequestingTermination = true);
    try {
      await _jobsService.requestTermination(
        jobUuid,
        reason: reason.isNotEmpty ? reason : null,
      );
      if (!mounted) return;
      AppToast.showSuccess(context, 'Termination request sent to the artisan.');
      await _loadJobDetails();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not send termination request.',
      );
    } finally {
      if (mounted) setState(() => _isRequestingTermination = false);
    }
  }

  Future<void> _handleApproveAndSettlement() async {
    final String? jobId = _currentJobId;
    if (jobId == null || jobId.isEmpty) return;

    setState(() => _loading = true);
    try {
      final res = await PaymentService.instance.calculateSettlement(jobId);
      final double outstanding = double.tryParse(res['outstanding_balance']?.toString() ?? '0') ?? 0.0;

      setState(() => _loading = false);
      if (!mounted) return;

      if (outstanding > 0) {
        // Must pay outstanding balance first
        final bool? paid = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentCheckoutScreen(
              jobId: jobId,
              amount: outstanding,
            ),
          ),
        );
        if (paid == true && mounted) {
          final String jobStatus = (_job?['status'] ?? '').toString();
          final bool isFinalCompletion = jobStatus == 'pending_completion' || jobStatus == 'completed' || jobStatus == 'pending_client_approval';

          if (isFinalCompletion) {
            setState(() => _loading = true);
            await PaymentService.instance.checkoutSettlement(jobId);
            setState(() => _loading = false);
            if (!mounted) return;
            AppToast.showEscrow(context, 'Escrow Funds Released! Payment completed & transferred to artisan.');
            unawaited(Navigator.pushNamed(
              context,
              AppRoutes.rateService,
              arguments: _ratingPayload(),
            ));
          } else {
            AppToast.showEscrow(context, '⚡ Extra charge payment confirmed! Held safely in Escrow.');
            await _loadJobDetails();
          }
        }
      } else {
        // No outstanding balance, release escrow directly
        setState(() => _loading = true);
        await PaymentService.instance.checkoutSettlement(jobId);
        setState(() => _loading = false);
        if (!mounted) return;
        AppToast.showEscrow(context, 'Escrow Funds Released! Payment completed & transferred to artisan.');
        unawaited(Navigator.pushNamed(
          context,
          AppRoutes.rateService,
          arguments: _ratingPayload(),
        ));
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not complete settlement.');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job = _job ??
        <String, dynamic>{
          'title': 'Your Job',
          'artisan': 'Artisan',
          'profession': 'Service provider',
          'eta': _etaLabel,
        };
    job['eta'] = _etaLabel;

    final String? workerId = job['worker_id'] as String?;
    final double? jobLat = (job['location_lat'] as num?)?.toDouble();
    final double? jobLng = (job['location_lng'] as num?)?.toDouble();
    final String? jobUuid = job['job_id'] as String? ??
        job['jobId'] as String? ??
        job['id'] as String?;
    final String status = (job['status'] as String? ?? '').toLowerCase();
    final bool hasReviewed = job['client_review_rating'] != null;
    final bool canRate =
        !hasReviewed &&
        (status == 'pending_client_approval' || status == 'completed');
    final bool pendingApproval = status == 'pending_client_approval';
    final bool recoverableServiceInterruption = status == 'cancelled' &&
        (((job['cancelled_by'] as String?) ?? '').toLowerCase() == 'worker' ||
            (((job['cancellation_stage'] as String?) ?? '').toLowerCase() ==
                'termination_requested'));

    if (!_loading && recoverableServiceInterruption) {
      return Scaffold(
        backgroundColor: DesignTokens.surfaceBase,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_loadError != null) _buildErrorBanner(),
                MiniHero(
                  height: 112,
                  child: heroForStep(0, status: 'cancelled'),
                ),
                const SizedBox(height: 16),
                TrackingJobInfoCard(job: job, etaLabel: _etaLabel),
                const SizedBox(height: 20),
                WorkerCancellationCard(
                  job: job,
                  jobUuid: jobUuid,
                  isLoading: _requestingAnotherWorker,
                  onRequestAnother: _requestAnotherWorker,
                  onCancelJob: () => _handleCancelJob(),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => ClientNavigation.goToBookingsTab(context),
                    child: Text(
                      'Back to bookings',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primary,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            DesignTokens.primary.withAlpha((0.4 * 255).round()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      appBar: _buildAppBar(context),
      body: _loading
          ? _buildLoader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_loadError != null) _buildErrorBanner(),
                    MiniHero(
                      height: 112,
                      child: heroForStep(_currentStep, status: status),
                    ),
                    const SizedBox(height: 16),
                    TrackingJobInfoCard(job: job, etaLabel: _etaLabel),
                    const SizedBox(height: 20),
                    _buildExtraChargeWidget(),
                    if (workerId != null && jobLat != null && jobLng != null)
                      AbsorbPointer(
                        absorbing: _isModalOpen,
                        child: TrackingMapCard(
                          workerId: workerId,
                          jobLat: jobLat,
                          jobLng: jobLng,
                          onEtaChanged: (eta) => setState(() => _etaLabel = eta),
                        ),
                      )
                    else
                      const TrackingMapPlaceholder(),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Job Progress'),
                    const SizedBox(height: 14),
                    ProgressTimeline(
                      steps: _steps,
                      currentStep: _currentStep,
                      pulseAnimation: _stepPulse,
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Your Artisan'),
                    const SizedBox(height: 14),
                    ArtisanDetailCard(job: job),
                    const SizedBox(height: 20),
                    _buildActionRow(job, jobUuid, workerId),
                    if (status != 'pending_client_approval' && job['work_ended_at'] == null)
                      CancelSection(
                        status: status,
                        isCancelling: _isCancelling,
                        isRequestingTermination: _isRequestingTermination,
                        onCancelJob: _handleCancelJob,
                        onRequestTermination: _handleRequestTermination,
                      ),
                    if (status == 'in_progress' &&
                        job['work_ended_at'] == null) ...<Widget>[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isConfirmingWorkDone ? null : _confirmWorkDone,
                          icon: _isConfirmingWorkDone
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Confirm job is done'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (pendingApproval) SettlementDetailsCard(
                      job: job,
                      onSettled: _loadJobDetails,
                    ),
                    CompletionActions(
                      canRate: canRate,
                      pendingApproval: pendingApproval,
                      isReopeningCompletion: _isReopeningCompletion,
                      hasPendingAgreement: _activeExtraCharge != null && _activeExtraCharge!['status'] == 'open',
                      onRate: _handleApproveAndSettlement,
                      onReopen: _reopenCompletion,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            ClientNavigation.goToBookingsTab(context),
                        child: Text(
                          'View all bookings',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: DesignTokens.primary
                                .withAlpha((0.4 * 255).round()),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Small helpers that stay in the shell
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          color: DesignTokens.surfaceBase,
          border:
              Border(bottom: BorderSide(color: Color(0x12000000), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: DesignTokens.shadowDeep,
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: DesignTokens.textPrimary),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Live Tracking',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: DesignTokens.successGreen
                        .withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: DesignTokens.successGreen
                            .withAlpha((0.3 * 255).round()),
                        width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: DesignTokens.successGreen,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.shield_outlined, color: DesignTokens.primary),
                  tooltip: 'Safety & Support',
                  onPressed: () {
                    final jobData = _job ?? widget.job;
                    SafetyHelpBottomSheet.show(
                      context,
                      bookingId: _currentJobId,
                      otherUserId: jobData?['worker_id'] as String?,
                      otherUserName: jobData?['artisan'] as String?,
                      jobTitle: jobData?['title'] as String?,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: DesignTokens.primary,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 14),
          Text(
            'Loading tracking info…',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.error.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: DesignTokens.error.withAlpha((0.2 * 255).round())),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: DesignTokens.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: DesignTokens.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
      Map<String, dynamic> job, String? jobUuid, String? workerId) {
    return ActionButtonsRow(
      job: job,
      jobUuid: jobUuid,
      workerId: workerId,
    );
  }
}
