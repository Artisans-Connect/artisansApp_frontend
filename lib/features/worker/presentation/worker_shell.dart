import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artisans_app/core/services/worker_dispatch_realtime_service.dart';
import 'package:artisans_app/core/services/workers_service.dart';
import 'package:artisans_app/shared/presentation/screens/messages_list_screen.dart';
import 'package:artisans_app/shared/presentation/screens/user_profile_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/job_request_detail_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_active_empty_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_active_in_progress_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_active_pre_start_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_booking_history_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_earnings_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_pending_approval_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_requests_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_termination_request_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_stats_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_reviews_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_gallery_screen.dart';
import 'package:artisans_app/features/worker/presentation/state/worker_session_state.dart';
import 'package:artisans_app/features/worker/presentation/utils/worker_job_mapper.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_bottom_nav.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_job_alert_sheet.dart';
import 'package:artisans_app/core/session/app_user_session.dart';

class WorkerShell extends StatefulWidget {
  const WorkerShell({
    super.key,
    this.initialJobRequestId,
    this.initialTab = WorkerNavTab.explore,
  });

  static const String routeName = '/shared/worker-home';

  final String? initialJobRequestId;
  final WorkerNavTab initialTab;

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> with WidgetsBindingObserver {
  late final WorkerSessionState _session;
  final WorkersService _workersService = WorkersService();
  final WorkerDispatchRealtimeService _dispatchRealtime =
      WorkerDispatchRealtimeService();
  final Set<String> _shownRequestIds = <String>{};
  int _messagesRefreshSignal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = WorkerSessionState();
    _session.currentTab = widget.initialTab;
    _session.addListener(_onSessionChanged);
    _session.loadAvailability();
    _session.loadActiveJob();
    AppUserSession.instance.updateActiveMode('worker');
    _subscribeToDispatches();
    if (widget.initialJobRequestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_openJobRequest(widget.initialJobRequestId!));
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dispatchRealtime.unsubscribe();
    _session.removeListener(_onSessionChanged);
    _session.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _session.loadActiveJob();
      setState(() {
        _messagesRefreshSignal++;
      });
    }
  }

  void _onSessionChanged() {
    if (mounted) {
      setState(() {});
      _checkCancellationNotice();
    }
  }

  void _checkCancellationNotice() {
    final msg = _session.pendingCancellationMessage;
    if (msg != null && mounted) {
      _session.clearCancellationMessage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                SizedBox(width: 8),
                Text(
                  'Booking Cancelled',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Text(
              msg,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _selectTab(WorkerNavTab tab) {
    if (tab == WorkerNavTab.messages) {
      _messagesRefreshSignal++;
    }
    if (tab == WorkerNavTab.bookings) {
      unawaited(_session.loadActiveJob());
    }
    _session.setTab(tab);
  }

  void _subscribeToDispatches() {
    final workerId = Supabase.instance.client.auth.currentUser?.id;
    if (workerId == null) return;
    _dispatchRealtime.subscribe(
      workerId: workerId,
      onDispatch: (String jobId, DateTime? expiresAt) {
        unawaited(_openJobRequest(jobId, expiresAt: expiresAt));
      },
      onClosed: (String jobId) {
        _shownRequestIds.remove(jobId);
      },
    );
  }

  Future<void> _openJobRequest(
    String jobId, {
    DateTime? expiresAt,
  }) async {
    if (!mounted ||
        _shownRequestIds.contains(jobId) ||
        _session.declinedJobIds.contains(jobId)) return;
    _shownRequestIds.add(jobId);

    try {
      final dynamic data = await _workersService.getJobRequestById(jobId);
      if (!mounted) return;
      if (data is! Map<String, dynamic>) {
        _shownRequestIds.remove(jobId);
        return;
      }

      final String status = (data['status'] as String? ?? '').toLowerCase();
      if (status == 'cancelled' ||
          status == 'client_cancelled' ||
          status == 'completed' ||
          status == 'in_progress' ||
          status == 'assigned') {
        _shownRequestIds.remove(jobId);
        return;
      }

      final secondsLeft = expiresAt == null
          ? 90
          : expiresAt
              .difference(DateTime.now().toUtc())
              .inSeconds
              .clamp(1, 90)
              .toInt();

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => WorkerJobAlertSheet(
          job: workerJobFromApi(data),
          initialSeconds: secondsLeft,
          onAccepted: (Map<String, dynamic> application) {
            _session.declineJobId(jobId);
            _shownRequestIds.remove(application['job_id']?.toString() ?? jobId);
          },
          onDeclined: () {
            _session.declineJobId(jobId);
          },
          onViewDetails: (job) {
            _session.declineJobId(jobId);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => JobRequestDetailScreen(
                  job: job,
                  onAcceptRequest: (_) => _session.loadActiveJob(),
                  onDeclineRequest: () => _session.declineJobId(jobId),
                ),
              ),
            );
          },
        ),
      );
      _session.declineJobId(jobId);
    } catch (_) {
      _shownRequestIds.remove(jobId);
    }
  }

  Widget _bookingsTab() {
    if (!_session.hasActiveJob) {
      return const WorkerActiveEmptyScreen();
    }
    final job = _session.activeJob!;
    switch (_session.jobPhase) {
      case WorkerJobPhase.accepted:
      case WorkerJobPhase.onTheWay:
      case WorkerJobPhase.arrived:
        return WorkerActivePreStartScreen(job: job, phase: _session.jobPhase);
      case WorkerJobPhase.inProgress:
        return WorkerActiveInProgressScreen(job: job);
      case WorkerJobPhase.terminationRequested:
        return WorkerTerminationRequestScreen(job: job);
      case WorkerJobPhase.pendingApproval:
        return WorkerPendingApprovalScreen(job: job);
      case WorkerJobPhase.none:
        return const WorkerActiveEmptyScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkerScope(
      notifier: _session,
      child: Scaffold(
        body: IndexedStack(
          index: _session.currentTab.index,
          children: [
            const WorkerRequestsScreen(),
            _bookingsTab(),
            MessagesListScreen(
              embedInShell: true,
              refreshSignal: _messagesRefreshSignal,
            ),
            UserProfileScreen(
              embedInShell: true,
              onOpenWorkerEarnings: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkerEarningsScreen(),
                  ),
                );
              },
              onOpenWorkerStats: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkerStatsScreen(),
                  ),
                );
              },
              onOpenWorkerHistory: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkerBookingHistoryScreen(),
                  ),
                );
              },
              onOpenWorkerReviews: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkerReviewsScreen(),
                  ),
                );
              },
              onOpenWorkerGallery: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkerGalleryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: WorkerBottomNav(
          currentTab: _session.currentTab,
          onTabSelected: _selectTab,
        ),
      ),
    );
  }
}
