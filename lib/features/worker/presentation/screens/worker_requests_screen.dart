import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/notification_service.dart';
import '../models/worker_job.dart';
import '../models/worker_stats.dart';
import '../state/worker_session_state.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/skeleton_box.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';

import 'job_request_detail_screen.dart';
import 'worker_application_detail_screen.dart';
import 'worker_booking_history_screen.dart';
import 'worker_earnings_screen.dart';
import 'worker_gallery_screen.dart';
import 'worker_reviews_screen.dart';
import '../utils/worker_application_navigation.dart';
import '../../../../core/theme/design_tokens.dart';
import '../widgets/worker_earnings_summary.dart';


import '../widgets/worker_dashboard/availability_card.dart';
import '../widgets/worker_dashboard/dashboard_header.dart';
import '../widgets/worker_dashboard/quick_access_section.dart';
import '../widgets/worker_dashboard/nearby_jobs_section.dart';
import '../widgets/worker_dashboard/recent_reviews_section.dart';
import '../widgets/worker_dashboard/tips_card.dart';
import '../widgets/worker_dashboard/pending_application_card.dart';
import '../widgets/worker_dashboard/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// View state
// ─────────────────────────────────────────────────────────────────────────────
enum RequestsViewState { loading, loaded, empty, error }
 
// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});
 
  @override
  State<WorkerRequestsScreen> createState() =>
      _WorkerRequestsScreenState();
}
 
class _WorkerRequestsScreenState extends State<WorkerRequestsScreen>
    with WidgetsBindingObserver {
  final WorkersService _workersService = WorkersService();
  final NotificationService _notificationService = NotificationService.instance;
  int _unreadNotifications = 0;

  RequestsViewState _viewState = RequestsViewState.loading;
  List<WorkerJob> _jobs = <WorkerJob>[];
  String? _selectedJobId;
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];
  String? _errorMessage;
  Timer? _refreshTimer;
  bool _isLoadingRequests = false;
  bool _isSilentRefreshing = false;
  DateTime? _lastCheckedAt;
  WorkerStats? _stats;
  double? _totalEarnings;
  bool _isLoadingOverview = true;
  final List<String> _tips = <String>[
    'Keep your availability ON during busy hours.',
    'Respond quickly to improve your response rate.',
    'Upload more portfolio photos.',
    'Complete jobs promptly to increase your recommendation score.',
    'Maintain a high customer rating.',
  ];
  late final String _tipOfTheDay;
 
  // ── Lifecycle ──────────────────────────────────────────────────────────────
 
  @override
  void initState() {
    super.initState();
    _tipOfTheDay = _tips[Random().nextInt(_tips.length)];
    WidgetsBinding.instance.addObserver(this);
    _load();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _load(silent: true),
    );
  }
 
  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
 
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(silent: true);
  }
 
  // ── Data loading ───────────────────────────────────────────────────────────
 
  Future<void> _load({bool silent = false}) async {
    if (_isLoadingRequests) return;
    _isLoadingRequests = true;
 
    if (!silent) {
      setState(() {
        _viewState = RequestsViewState.loading;
        _errorMessage = null;
        _isSilentRefreshing = false;
      });
    } else if (mounted) {
      setState(() => _isSilentRefreshing = true);
    }
 
    if (mounted) {
      try {
        final session = WorkerScope.read(context);
        unawaited(session.loadAvailability());
      } catch (_) {}
    }

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _workersService.getJobRequests(),
        _workersService.getApplications(),
      ]);
      final List<dynamic> data = results[0] as List<dynamic>;
      final List<dynamic> applications = results[1] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _jobs = data
            .map((dynamic item) =>
                workerJobFromApi(item as Map<String, dynamic>))
            .toList();
        _selectedJobId = _jobs.isNotEmpty
            ? (_selectedJobId != null && _jobs.any((job) => job.id == _selectedJobId)
                ? _selectedJobId
                : _jobs.first.id)
            : null;
        _applications = applications
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
            .toList();
        _viewState = _jobs.isEmpty && _applications.isEmpty
            ? RequestsViewState.empty
            : RequestsViewState.loaded;
        _lastCheckedAt = DateTime.now();
        _isSilentRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) {
        setState(() => _isSilentRefreshing = false);
      } else {
        setState(() {
          _errorMessage =
              userMessageFor(e, fallback: 'Failed to load requests.');
          _viewState = RequestsViewState.error;
        });
      }
    } finally {
      _isLoadingRequests = false;
    }

    if (!silent) {
      await Future.wait<dynamic>([
        _loadOverview(),
        _loadUnreadNotifications(),
      ]);
    } else {
      unawaited(_loadOverview(silent: true));
      unawaited(_loadUnreadNotifications());
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final int count = await _notificationService.getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadNotifications = count);
    } catch (_) {
      if (!mounted) return;
      setState(() => _unreadNotifications = 0);
    }
  }

  Future<void> _loadOverview({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoadingOverview = true;
      });
    }

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _workersService.getStats(),
        _workersService.getEarnings(),
      ]);
      final Map<String, dynamic> statsData =
          Map<String, dynamic>.from(results[0] as Map);
      final Map<String, dynamic> earningsData =
          Map<String, dynamic>.from(results[1] as Map);

      if (!mounted) return;
      setState(() {
        _stats = WorkerStats.fromMap(statsData);
        _totalEarnings = (earningsData['total_earned'] as num?)?.toDouble();
      });
    } catch (_) {
      // Keep the dashboard visible even if overview data fails.
    } finally {
      if (!silent && mounted) {
        setState(() {
          _isLoadingOverview = false;
        });
      }
    }
  }
 
  // ── Navigation ─────────────────────────────────────────────────────────────
 
  void _openDetail(WorkerJob job) {
    _selectJob(job.id);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobRequestDetailScreen(
          job: job,
          onAcceptRequest: (accepted) {
            _load();
          },
          onAcceptResponse: (accepted) {
            _load();
          },
          onDeclineRequest: () {
            if (mounted) {
              WorkerScope.of(context).declineJobId(job.id);
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleQuickAccept(WorkerJob job) async {
    _selectJob(job.id);
    final String budgetStr = job.rateLabel ?? job.estimatedBudgetLabel ?? 'this job';
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Apply for ${job.title}?'),
        content: Text(
          'Do you want to send an application to client ${job.clientName} ($budgetStr)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: DesignTokens.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _workersService.applyToJob(job.id);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Application submitted successfully.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not submit application.');
    }
  }

  void _selectJob(String jobId) {
    if (!mounted) return;
    setState(() {
      if (_jobs.any((job) => job.id == jobId)) {
        _selectedJobId = jobId;
      }
    });
  }

  Future<void> _openApplication(Map<String, dynamic> application) async {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(application['job'] as Map? ?? const {});
    final WorkerApplicationDestination destination =
        workerApplicationDestination(
      (application['status'] ?? '').toString(),
      (job['status'] ?? '').toString(),
    );

    if (destination == WorkerApplicationDestination.activeBooking) {
      final WorkerSessionState session = WorkerScope.of(context);
      await session.loadActiveJob();
      if (session.hasActiveJob || !mounted) return;
    } else if (destination == WorkerApplicationDestination.history) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const WorkerBookingHistoryScreen(),
        ),
      );
      return;
    }

    if (!mounted) return;
    final dynamic updated = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => WorkerApplicationDetailScreen(
          application: application,
        ),
      ),
    );
    if (updated == true && mounted) {
      _load();
    }
  }


 
  // ── Build ──────────────────────────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
 
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          // Slim silent-refresh progress bar at the very top
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            child: _isSilentRefreshing
                ? LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: DesignTokens.surfaceBase,
                    color: DesignTokens.primary.withAlpha((0.45 * 255).round()),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: DesignTokens.primary,
              backgroundColor: DesignTokens.surfaceCard,
              onRefresh: _load,
              child: _buildBody(session),
            ),
          ),
        ],
      ),
    );
  }
 
  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Job Requests',
      showBackButton: false,
      actions: <Widget>[
        GestureDetector(
          onTap: () async {
            await Navigator.pushNamed(context, AppRoutes.notifications);
            if (mounted) unawaited(_loadUnreadNotifications());
          },
          child: Container(
            margin: const EdgeInsets.only(right: DesignTokens.gutter),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: DesignTokens.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: DesignTokens.borderSubtle),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: DesignTokens.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Icon(
                  Icons.notifications_outlined,
                  color: DesignTokens.textPrimary,
                  size: 20,
                ),
                if (_unreadNotifications > 0)
                  Positioned(
                    top: 5,
                    right: 4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DesignTokens.surfaceCard,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _unreadNotifications > 99
                            ? '99+'
                            : '$_unreadNotifications',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
 
  // ── Body ───────────────────────────────────────────────────────────────────
 
  Widget _buildBody(WorkerSessionState session) {
    if (_viewState == RequestsViewState.loading) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.gutter),
        children: const <Widget>[
          SkeletonBox(height: 112),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 145),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 170),
        ],
      );
    }

    if (_viewState == RequestsViewState.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.gutter,
          DesignTokens.md,
          DesignTokens.gutter,
          DesignTokens.gutter,
        ),
        children: <Widget>[
          ErrorStateView(
            message: _errorMessage!,
            title: 'Could not load requests',
            onRetry: _load,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.gutter,
        DesignTokens.md,
        DesignTokens.gutter,
        DesignTokens.gutter,
      ),
      children: <Widget>[
        const DashboardHeader(),
        const SizedBox(height: DesignTokens.md),
        AvailabilityCard(
          isAvailable: session.isAvailable,
          isAvailabilityLoading: session.isAvailabilityLoading,
          lastCheckedAt: _lastCheckedAt,
          isSilentRefreshing: _isSilentRefreshing,
          onChanged: (bool value) async {
            if (value) {
              final bool hasLoc =
                  await DeviceLocationService.requestPermissionInteractive(context);
              if (!hasLoc) return;
            }
            final bool ok = await session.setAvailable(value);
            if (ok && mounted) {
              await _load();
            }
            if (!ok && mounted) {
              AppToast.showError(
                context,
                Exception('Could not update availability.'),
                fallback: 'Could not update availability.',
              );
            }
          },
        ),
        const SizedBox(height: DesignTokens.lg),
        NearbyJobsSection(
          isOnline: session.isAvailable,
          isSearching: _isLoadingRequests,
          jobs: _jobs,
          selectedJobId: _selectedJobId,
          lastCheckedAt: _lastCheckedAt,
          onGoOnline: () async {
            if (await DeviceLocationService.requestPermissionInteractive(context)) {
              final bool ok = await session.setAvailable(true);
              if (ok && mounted) {
                await _load();
              }
              if (!ok && mounted) {
                AppToast.showError(
                  context,
                  Exception('Could not update availability.'),
                  fallback: 'Could not update availability.',
                );
              }
            }
          },
          onStartMatching: _load,
          onSelectJob: _selectJob,
          onOpenJob: _openDetail,
          onViewDetails: _openDetail,
          onAccept: _handleQuickAccept,
        ),
        const SizedBox(height: DesignTokens.lg),
        if (_applications.isNotEmpty) ...<Widget>[
          SectionHeader(
            label: 'Pending applications',
            count: _applications.length,
          ),
          const SizedBox(height: DesignTokens.md),
          ..._applications.map(
            (Map<String, dynamic> application) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.md),
              child: PendingApplicationCard(
                application: application,
                onTap: () => _openApplication(application),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.sm),
        ],
        QuickAccessSection(
          onOpenEarnings: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerEarningsScreen(),
              ),
            );
          },
          onOpenReviews: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerReviewsScreen(),
              ),
            );
          },
          onOpenGallery: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerGalleryScreen(),
              ),
            );
          },
          onOpenHistory: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerBookingHistoryScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: DesignTokens.lg),
        PerformanceOverviewCard(
          stats: _stats,
          totalEarnings: _totalEarnings,
          isLoading: _isLoadingOverview,
        ),


        const SizedBox(height: DesignTokens.lg),
        RecentReviewsSection(
          reviews: _stats?.recentReviews ?? const <WorkerReviewSummary>[],
          onSeeAll: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerReviewsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: DesignTokens.lg),
        TipsCard(tip: _tipOfTheDay),
      ],
    );
  }
}

