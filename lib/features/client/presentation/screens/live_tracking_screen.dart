import 'dart:async';
 
import 'package:flutter/material.dart';
 
import '../../../../core/errors/error_messages.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/job_realtime_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/client_booking.dart';
import '../navigation/client_navigation.dart';
import '../../../../core/theme/design_tokens.dart';

import '../widgets/live_tracking/tracking_atoms.dart';
import '../widgets/live_tracking/job_info_card.dart';
import '../widgets/live_tracking/worker_cancellation_card.dart';
import '../widgets/live_tracking/tracking_map_card.dart';
import '../widgets/live_tracking/progress_timeline.dart';
import '../widgets/live_tracking/artisan_detail_card.dart';
import '../widgets/live_tracking/settlement_details_card.dart';
import '../widgets/live_tracking/cancel_section.dart';
import '../widgets/live_tracking/completion_actions.dart';

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
  bool _loading = true;
  bool _requestingAnotherWorker = false;
  bool _isReopeningCompletion = false;
  bool _isCancelling = false;
  bool _isRequestingTermination = false;
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
    }
  }
 
  String? get _currentJobId =>
      _job?['job_id'] as String? ??
      _job?['jobId'] as String? ??
      _job?['id'] as String?;
 
  Future<void> _loadJobDetails() async {
    final String? jobId = _currentJobId;
    if (jobId == null || jobId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final dynamic raw = await _jobsService.getJobById(jobId);
      if (!mounted) return;
      if (raw is Map<String, dynamic>) {
        final ClientBooking booking = ClientBooking.fromApiJob(raw);
        final String status = (booking.backendStatus ?? '').toLowerCase();
        if (status == 'matching' || status == 'searching') {
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
        });
        _applyStepFromStatus(booking.backendStatus);
      } else {
        setState(() => _loading = false);
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
    });
    _applyStepFromStatus(booking.backendStatus);
  }
 
  void _applyStepFromStatus(String? statusRaw) {
    final String status = (statusRaw ?? '').toLowerCase();
    final int step = switch (status) {
      'matched' => 0,
      'on_the_way' => 1,
      'arrived' => 2,
      'in_progress' => 3,
      'termination_requested' => 3,
      'pending_client_approval' => 4,
      'completed' => 4,
      _ => 0,
    };
    setState(() => _currentStep = step);
  }
 
  @override
  void dispose() {
    _stepPulse.dispose();
    _realtime.unsubscribe();
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

  Future<void> _reopenCompletion() async {
    final String? jobUuid = _currentJobId;
    if (_isReopeningCompletion || jobUuid == null || jobUuid.isEmpty) return;

    final TextEditingController noteController = TextEditingController();
    final String? note = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Job not done?'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Tell the artisan what still needs attention.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, noteController.text.trim()),
              child: const Text('Reopen job'),
            ),
          ],
        );
      },
    );
    noteController.dispose();
    if (note == null || !mounted) return;

    setState(() => _isReopeningCompletion = true);
    try {
      final dynamic reopened = await _jobsService.reopenJob(
        jobUuid,
        body: <String, dynamic>{
          if (note.isNotEmpty) 'note': note,
        },
      );
      if (!mounted) return;
      if (reopened is Map<String, dynamic>) {
        final ClientBooking booking = ClientBooking.fromApiJob(reopened);
        setState(() => _job = booking.toTrackingMap());
        _applyStepFromStatus(booking.backendStatus);
      } else {
        await _loadJobDetails();
      }
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
      if (mounted) setState(() => _isReopeningCompletion = false);
    }
  }

  Future<void> _handleCancelJob() async {
    final String? jobUuid = _currentJobId;
    if (_isCancelling || jobUuid == null || jobUuid.isEmpty) return;

    setState(() => _isCancelling = true);
    try {
      final dynamic preview = await _jobsService.getCancellationPreview(jobUuid);
      if (!mounted) return;

      if (preview is! Map<String, dynamic>) {
        setState(() => _isCancelling = false);
        return;
      }

      final bool canCancel = preview['can_cancel'] as bool? ?? false;
      if (!canCancel) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(preview['warning_message'] as String? ?? 'Cannot cancel this job.')),
        );
        return;
      }

      final double fee = (preview['fee_amount'] as num?)?.toDouble() ?? 0;
      final String warningTitle = preview['warning_title'] as String? ?? 'Cancel this job?';
      final String warningMessage = preview['warning_message'] as String? ?? 'Are you sure?';

      final TextEditingController reasonCtrl = TextEditingController();
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  fee > 0 ? Icons.warning_amber_rounded : Icons.cancel_outlined,
                  color: fee > 0 ? DesignTokens.accentWarm : DesignTokens.error,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    warningTitle,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warningMessage,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                if (fee > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignTokens.accentWarm.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: DesignTokens.accentWarm.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_rounded, color: DesignTokens.accentWarm, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'GH\u20B5 ${fee.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.accentWarm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please pay this amount directly to the artisan.',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: DesignTokens.textSecondary.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Reason for cancellation (optional)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep Job'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: DesignTokens.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes, Cancel'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !mounted) {
        reasonCtrl.dispose();
        setState(() => _isCancelling = false);
        return;
      }

      final String reasonText = reasonCtrl.text.trim();
      reasonCtrl.dispose();

      await _jobsService.cancelJobWithReason(
        jobUuid,
        reason: reasonText.isNotEmpty ? reasonText : null,
      );
      if (!mounted) return;

      String snackMessage = 'Job cancelled.';
      if (fee > 0) {
        snackMessage = 'Job cancelled. Please pay GH\u20B5 ${fee.toStringAsFixed(2)} to the artisan.';
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

    final TextEditingController reasonCtrl = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.front_hand_rounded,
                color: DesignTokens.accentWarm,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Request Termination',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Work has already started. Your artisan will be notified and can accept or decline the termination.',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14,
                  color: DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.accentWarm.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Note: This is not an instant cancellation. The artisan must agree to stop work.',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Why do you want to terminate this job?',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep Job'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: DesignTokens.accentWarm),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Request Termination'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      reasonCtrl.dispose();
      return;
    }

    final String reasonText = reasonCtrl.text.trim();
    reasonCtrl.dispose();

    setState(() => _isRequestingTermination = true);
    try {
      await _jobsService.requestTermination(
        jobUuid,
        reason: reasonText.isNotEmpty ? reasonText : null,
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
 
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job = _job ?? <String, dynamic>{
      'title': 'Your Job',
      'artisan': 'Artisan',
      'profession': 'Service provider',
      'eta': _etaLabel,
    };
    job['eta'] = _etaLabel;
 
    final String? workerId = job['worker_id'] as String?;
    final double? jobLat = (job['location_lat'] as num?)?.toDouble();
    final double? jobLng = (job['location_lng'] as num?)?.toDouble();
    final String? jobUuid =
        job['job_id'] as String? ?? job['jobId'] as String? ?? job['id'] as String?;
    final String status = (job['status'] as String? ?? '').toLowerCase();
    final bool canRate =
        status == 'pending_client_approval' || status == 'completed';
    final bool pendingApproval = status == 'pending_client_approval';
    final bool workerCancelled =
        status == 'cancelled' && (job['cancelled_by'] as String?) == 'worker';

    if (!_loading && workerCancelled) {
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
                  child: heroForStep(0),
                ),
                const SizedBox(height: 16),
                TrackingJobInfoCard(job: job, etaLabel: _etaLabel),
                const SizedBox(height: 20),
                WorkerCancellationCard(
                  job: job,
                  jobUuid: jobUuid,
                  isLoading: _requestingAnotherWorker,
                  onRequestAnother: _requestAnotherWorker,
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
                        decorationColor: DesignTokens.primary.withAlpha((0.4 * 255).round()),
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
                      child: heroForStep(_currentStep),
                    ),
                    const SizedBox(height: 16),

                    TrackingJobInfoCard(job: job, etaLabel: _etaLabel),
                    const SizedBox(height: 20),

                    if (workerId != null && jobLat != null && jobLng != null)
                      TrackingMapCard(
                        workerId: workerId,
                        jobLat: jobLat,
                        jobLng: jobLng,
                        onEtaChanged: (eta) => setState(() => _etaLabel = eta),
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
                    const SizedBox(height: 12),

                    CancelSection(
                      status: status,
                      isCancelling: _isCancelling,
                      isRequestingTermination: _isRequestingTermination,
                      onCancelJob: _handleCancelJob,
                      onRequestTermination: _handleRequestTermination,
                    ),
                    const SizedBox(height: 16),

                    if (pendingApproval)
                      SettlementDetailsCard(job: job),

                    CompletionActions(
                      canRate: canRate,
                      pendingApproval: pendingApproval,
                      isReopeningCompletion: _isReopeningCompletion,
                      onRate: () => Navigator.pushNamed(
                        context,
                        AppRoutes.rateService,
                        arguments: _ratingPayload(),
                      ),
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
                            decorationColor: DesignTokens.primary.withAlpha((0.4 * 255).round()),
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
          border: Border(
              bottom: BorderSide(color: Color(0x12000000), width: 1)),
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
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: DesignTokens.successGreen.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: DesignTokens.successGreen.withAlpha((0.3 * 255).round()), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: DesignTokens.successGreen, shape: BoxShape.circle)),
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
        border: Border.all(color: DesignTokens.error.withAlpha((0.2 * 255).round())),
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
    return Row(
      children: <Widget>[
        Expanded(
          child: ActionButton(
            icon: Icons.phone_rounded,
            label: 'Call',
            isEnabled: job['phone'] != null,
            onTap: job['phone'] != null
                ? () => ClientNavigation.callPhone(
                    context, job['phone'] as String)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            icon: Icons.chat_bubble_rounded,
            label: 'Message',
            isEnabled: jobUuid != null,
            onTap: jobUuid != null
                ? () => ClientNavigation.openChat(
                      context,
                      conversationId: jobUuid,
                      counterpartUserId:
                          job['counterpartUserId'] as String? ?? workerId ?? '',
                      counterpartName:
                          job['artisan'] as String? ?? 'Artisan',
                      jobId: jobUuid,
                      jobTitle: job['title'] as String?,
                    )
                : null,
          ),
        ),
      ],
    );
  }
}