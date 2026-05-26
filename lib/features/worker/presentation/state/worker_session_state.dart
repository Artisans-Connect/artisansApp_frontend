import 'package:flutter/widgets.dart';
import '../models/mock_worker_job.dart';
import '../widgets/worker_bottom_nav.dart';

enum WorkerJobPhase { none, preStart, inProgress }

enum WorkerProfilePage { earnings, stats, history }

class WorkerSessionState extends ChangeNotifier {
  WorkerNavTab currentTab = WorkerNavTab.explore;
  WorkerProfilePage profilePage = WorkerProfilePage.earnings;

  bool isAvailable = true;
  MockWorkerJob? activeJob;
  WorkerJobPhase jobPhase = WorkerJobPhase.none;

  bool get hasActiveJob =>
      activeJob != null && jobPhase != WorkerJobPhase.none;

  void setAvailable(bool value) {
    isAvailable = value;
    notifyListeners();
  }

  void setTab(WorkerNavTab tab) {
    currentTab = tab;
    notifyListeners();
  }

  void setProfilePage(WorkerProfilePage page) {
    profilePage = page;
    notifyListeners();
  }

  void acceptJob(MockWorkerJob job) {
    activeJob = job;
    jobPhase = WorkerJobPhase.preStart;
    currentTab = WorkerNavTab.bookings;
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
