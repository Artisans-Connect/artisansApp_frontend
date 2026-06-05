import 'package:flutter/material.dart';
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
import 'widgets/worker_bottom_nav.dart';

class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key});

  static const String routeName = '/shared/worker-home';

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  late final WorkerSessionState _session;

  @override
  void initState() {
    super.initState();
    _session = WorkerSessionState();
    _session.addListener(_onSessionChanged);
    _session.syncLocationTracking();
    _session.loadActiveJob();
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _session.dispose();
    super.dispose();
  }

  void _onSessionChanged() => setState(() {});

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
