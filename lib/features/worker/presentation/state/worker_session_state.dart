import 'package:flutter/widgets.dart';

import '../../../../core/location/worker_location_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/services/workers_service.dart';
import '../models/worker_job.dart';
import '../models/worker_ui_contracts.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/worker_bottom_nav.dart';

import '../../../../core/services/job_realtime_service.dart';

enum WorkerJobPhase {
  none,
  accepted,
  onTheWay,
  arrived,
  inProgress,
  terminationRequested,
  pendingApproval,
}

enum WorkerProfilePage { earnings, stats, history }

class WorkerSessionState extends ChangeNotifier {
  final WorkersService _workersService = WorkersService();
  final JobsService _jobsService = JobsService();
  final JobRealtimeService _realtimeService = JobRealtimeService();

  WorkerNavTab currentTab = WorkerNavTab.explore;
  WorkerProfilePage profilePage = WorkerProfilePage.earnings;

  bool isAvailable = false;
  bool isAvailabilityLoading = true;
  int _availabilityChangeVersion = 0;
  WorkerJob? activeJob;
  WorkerJobPhase jobPhase = WorkerJobPhase.none;

  bool get hasActiveJob => activeJob != null && jobPhase != WorkerJobPhase.none;

  WorkerAvailabilityStatus get availabilityStatus => isAvailable
      ? WorkerAvailabilityStatus.online
      : WorkerAvailabilityStatus.offline;

  Future<bool> setAvailable(bool value) async {
    if (isAvailabilityLoading) return false;
    _availabilityChangeVersion++;
    isAvailable = value;
    notifyListeners();
    try {
      await _workersService.toggleAvailability(value);
      if (value) {
        await WorkerLocationService.instance.start();
      } else {
        await WorkerLocationService.instance.stop();
      }
      return true;
    } catch (_) {
      isAvailable = !value;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAvailability() async {
    final int versionAtStart = _availabilityChangeVersion;
    try {
      final bool savedAvailability = await _workersService.getAvailability();
      if (versionAtStart != _availabilityChangeVersion) return;
      isAvailable = savedAvailability;
      if (savedAvailability) {
        await WorkerLocationService.instance.start();
      } else {
        await WorkerLocationService.instance.stop();
      }
    } catch (_) {
      // Keep the toggle usable if availability could not be refreshed.
    } finally {
      isAvailabilityLoading = false;
      notifyListeners();
    }
  }

  String? pendingCancellationMessage;

  void clearCancellationMessage() {
    pendingCancellationMessage = null;
  }

  Future<void> loadActiveJob() async {
    try {
      final dynamic data = await _workersService.getActiveJob();
      if (data is! Map<String, dynamic>) {
        if (activeJob != null) {
          final String previousJobId = activeJob!.id;
          try {
            final dynamic jobData = await _jobsService.getJobById(previousJobId);
            if (jobData is Map<String, dynamic>) {
              final String status = (jobData['status'] as String? ?? '').toLowerCase();
              if (status == 'cancelled' || status == 'client_cancelled') {
                pendingCancellationMessage = 'The client has cancelled this booking.';
              }
            }
          } catch (_) {
            // Avoid false cancellation notification if status check fails
          }
        }
        _realtimeService.unsubscribe();
        activeJob = null;
        jobPhase = WorkerJobPhase.none;
        notifyListeners();
        return;
      }

      final String status = (data['status'] as String? ?? '').toLowerCase();
      if (status == 'cancelled' || status == 'client_cancelled') {
        if (activeJob != null) {
          pendingCancellationMessage = 'The client has cancelled this booking.';
        }
        _realtimeService.unsubscribe();
        activeJob = null;
        jobPhase = WorkerJobPhase.none;
        notifyListeners();
        return;
      }

      activeJob = workerJobFromApi(data);
      jobPhase = _phaseForStatus(status);
      currentTab = WorkerNavTab.bookings;
      notifyListeners();

      _realtimeService.subscribeToJob(
        activeJob!.id,
        onUpdate: (_) => loadActiveJob(),
      );
    } catch (_) {
      // Keep shell usable; request/booking screens still expose retry states.
    }
  }

  @override
  void dispose() {
    _realtimeService.unsubscribe();
    super.dispose();
  }

  void setTab(WorkerNavTab tab) {
    currentTab = tab;
    notifyListeners();
  }

  void setProfilePage(WorkerProfilePage page) {
    profilePage = page;
    notifyListeners();
  }

  void acceptJob(WorkerJob job) {
    activeJob = job;
    jobPhase = WorkerJobPhase.accepted;
    currentTab = WorkerNavTab.bookings;
    notifyListeners();
  }

  void acceptJobFromApi(Map<String, dynamic> job) {
    activeJob = workerJobFromApi(job);
    jobPhase = _phaseForStatus((job['status'] as String? ?? '').toLowerCase());
    currentTab = WorkerNavTab.bookings;
    notifyListeners();
  }

  void updateActiveJobFromApi(Map<String, dynamic> job) {
    activeJob = workerJobFromApi(job);
    jobPhase = _phaseForStatus((job['status'] as String? ?? '').toLowerCase());
    currentTab = WorkerNavTab.bookings;
    notifyListeners();
  }

  void markOnTheWay() {
    if (activeJob == null) return;
    jobPhase = WorkerJobPhase.onTheWay;
    notifyListeners();
  }

  void markArrived() {
    if (activeJob == null) return;
    jobPhase = WorkerJobPhase.arrived;
    notifyListeners();
  }

  void markJobStarted() {
    if (activeJob == null) return;
    jobPhase = WorkerJobPhase.inProgress;
    notifyListeners();
  }

  void cancelActiveJob() {
    _realtimeService.unsubscribe();
    activeJob = null;
    jobPhase = WorkerJobPhase.none;
    currentTab = WorkerNavTab.bookings;
    notifyListeners();
  }

  void completeJob() {
    if (activeJob == null) return;
    jobPhase = WorkerJobPhase.pendingApproval;
    currentTab = WorkerNavTab.bookings;
    notifyListeners();
  }

  void goToExplore() {
    currentTab = WorkerNavTab.explore;
    notifyListeners();
  }

  WorkerJobPhase _phaseForStatus(String status) {
    return switch (status) {
      'on_the_way' => WorkerJobPhase.onTheWay,
      'arrived' => WorkerJobPhase.arrived,
      'in_progress' => WorkerJobPhase.inProgress,
      'termination_requested' => WorkerJobPhase.terminationRequested,
      'pending_client_approval' => WorkerJobPhase.pendingApproval,
      'matched' => WorkerJobPhase.accepted,
      // A confirmed scheduled job is not an active booking yet: it activates
      // (becomes matched) near the scheduled time. Showing on-the-way/arrive
      // actions before then would be wrong.
      'scheduled_confirmed' => WorkerJobPhase.none,
      'completed' => WorkerJobPhase.none,
      'cancelled' => WorkerJobPhase.none,
      _ => WorkerJobPhase.accepted,
    };
  }
}

class WorkerScope extends InheritedNotifier<WorkerSessionState> {
  const WorkerScope({
    super.key,
    required WorkerSessionState super.notifier,
    required super.child,
  });

  static WorkerSessionState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WorkerScope>();
    assert(scope != null, 'WorkerScope not found');
    return scope!.notifier!;
  }

  static WorkerSessionState read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<WorkerScope>();
    assert(element != null, 'WorkerScope not found');
    return (element!.widget as WorkerScope).notifier!;
  }
}
