import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/worker_dispatch_realtime_service.dart';
import '../../../core/services/workers_service.dart';
import '../../../shared/presentation/screens/messages_list_screen.dart';
import '../../../shared/presentation/screens/user_profile_screen.dart';
import 'screens/worker_active_empty_screen.dart';
import 'screens/worker_active_in_progress_screen.dart';
import 'screens/worker_active_pre_start_screen.dart';
import 'screens/worker_booking_history_screen.dart';
import 'screens/worker_earnings_screen.dart';
import 'screens/worker_requests_screen.dart';
import 'screens/worker_stats_screen.dart';
import 'state/worker_session_state.dart';
import 'utils/worker_job_mapper.dart';
import 'widgets/worker_bottom_nav.dart';
import 'widgets/worker_job_alert_sheet.dart';

class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key, this.initialJobRequestId});

  static const String routeName = '/shared/worker-home';

  final String? initialJobRequestId;

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  late final WorkerSessionState _session;
  final WorkersService _workersService = WorkersService();
  final WorkerDispatchRealtimeService _dispatchRealtime =
      WorkerDispatchRealtimeService();
  final Set<String> _shownRequestIds = <String>{};

  @override
  void initState() {
    super.initState();
    _session = WorkerSessionState();
    _session.addListener(_onSessionChanged);
    _session.syncLocationTracking();
    _session.loadActiveJob();
    _subscribeToDispatches();
    if (widget.initialJobRequestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_openJobRequest(widget.initialJobRequestId!));
      });
    }
  }

  @override
  void dispose() {
    _dispatchRealtime.unsubscribe();
    _session.removeListener(_onSessionChanged);
    _session.dispose();
    super.dispose();
  }

  void _onSessionChanged() => setState(() {});

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
    if (!mounted || _shownRequestIds.contains(jobId)) return;
    _shownRequestIds.add(jobId);

    try {
      final dynamic data = await _workersService.getJobRequestById(jobId);
      if (!mounted) return;
      if (data is! Map<String, dynamic>) return;

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
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => WorkerJobAlertSheet(
          job: workerJobFromApi(data),
          initialSeconds: secondsLeft,
          onAccepted: (Map<String, dynamic> accepted) {
            _session.acceptJobFromApi(accepted);
          },
          onDeclined: () {
            _shownRequestIds.remove(jobId);
          },
        ),
      );
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
      case WorkerJobPhase.preStart:
        return WorkerActivePreStartScreen(job: job);
      case WorkerJobPhase.inProgress:
        return WorkerActiveInProgressScreen(job: job);
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
            const MessagesListScreen(embedInShell: true),
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
            ),
          ],
        ),
        bottomNavigationBar: WorkerBottomNav(
          currentTab: _session.currentTab,
          onTabSelected: _session.setTab,
        ),
      ),
    );
  }
}
