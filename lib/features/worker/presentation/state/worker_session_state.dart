import 'package:flutter/widgets.dart';

import '../../../../core/location/worker_location_service.dart';
import '../../../../core/services/workers_service.dart';
import '../models/worker_job.dart';
import '../models/worker_ui_contracts.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/worker_bottom_nav.dart';

enum WorkerJobPhase { none, accepted, onTheWay, arrived, inProgress }
enum WorkerProfilePage { earnings, stats, history }

class WorkerSessionState extends ChangeNotifier {
  final WorkersService _workersService = WorkersService();

  WorkerNavTab currentTab = WorkerNavTab.explore;
  WorkerProfilePage profilePage = WorkerProfilePage.earnings;

  bool isAvailable = false;
  WorkerJob? activeJob;
  WorkerJobPhase jobPhase = WorkerJobPhase.none;

  bool get hasActiveJob =>
      activeJob != null && jobPhase != WorkerJobPhase.none;

  WorkerAvailabilityStatus get availabilityStatus =>
      isAvailable
          ? WorkerAvailabilityStatus.online
          : WorkerAvailabilityStatus.offline;

  Future<bool> setAvailable(bool value) async {
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

  /// Call when worker shell mounts if already available.
  Future<void> syncLocationTracking() async {
    if (isAvailable) {
      await WorkerLocationService.instance.start();
    }
  }

  Future<void> loadActiveJob() async {
    try {
      final dynamic data = await _workersService.getActiveJob();
      if (data is! Map<String, dynamic>) {
        activeJob = null;
        jobPhase = WorkerJobPhase.none;
        notifyListeners();
        return;
      }
      activeJob = workerJobFromApi(data);
      final String status = (data['status'] as String? ?? '').toLowerCase();
      jobPhase = _phaseForStatus(status);
      currentTab = WorkerNavTab.bookings;
      notifyListeners();
    } catch (_) {
      // Keep shell usable; request/booking screens still expose retry states.
    }
  }

  @override
  void dispose() {
    WorkerLocationService.instance.stop();
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
    activeJob = null;
    jobPhase = WorkerJobPhase.none;
    currentTab = WorkerNavTab.bookings;
    notifyListeners();
  }

  void completeJob() {
    activeJob = null;
    jobPhase = WorkerJobPhase.none;
    currentTab = WorkerNavTab.explore;
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
      'matched' => WorkerJobPhase.accepted,
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
    final scope =
        context.dependOnInheritedWidgetOfExactType<WorkerScope>();
    assert(scope != null, 'WorkerScope not found');
    return scope!.notifier!;
  }
}
