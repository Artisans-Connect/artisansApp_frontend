import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/services/job_realtime_service.dart';
import 'package:artisans_app/core/services/jobs_service.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/custom_app_bar.dart';
import 'package:artisans_app/shared/widgets/error_state_view.dart';
import 'package:artisans_app/shared/widgets/primary_button.dart';
import 'package:artisans_app/shared/widgets/secondary_button.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/features/client/presentation/models/client_booking.dart';
import 'package:artisans_app/features/client/presentation/navigation/client_navigation.dart';
import 'package:artisans_app/features/client/presentation/screens/job_applicants_screen.dart';

class FindingArtisanScreen extends StatefulWidget {
  const FindingArtisanScreen({
    super.key,
    this.jobData,
    this.artisan,
  });

  final Map<String, dynamic>? jobData;
  final Map<String, dynamic>? artisan;

  @override
  State<FindingArtisanScreen> createState() => _FindingArtisanScreenState();
}

class _FindingArtisanScreenState extends State<FindingArtisanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _curvedTurns;
  final JobsService _jobsService = JobsService();
  final JobRealtimeService _realtime = JobRealtimeService();
  String? _errorMessage;
  bool _isExpired = false;
  bool _isContinuing = false;
  bool _isCancelling = false;
  Timer? _progressTimer;
  String _progressHeadline = 'Checking nearby artisans';
  String _progressDetail = 'Preparing your request...';
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _curvedTurns = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _startWatching();
  }

  String? get _jobId => widget.jobData?['id'] as String?;

  void _startWatching() {
    if (_jobId == null) return;

    _jobsService.getJobById(_jobId!).then((job) {
      if (job is Map<String, dynamic>) _handleJobUpdate(job);
    }).catchError((_) {});

    _realtime.subscribeToJob(_jobId!, onUpdate: _handleJobUpdate);
    _loadProgress();
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _loadProgress(),
    );
  }

  Future<void> _loadProgress() async {
    if (_jobId == null) return;
    try {
      final dynamic response = await _jobsService.getMatchingProgress(_jobId!);
      if (!mounted || response is! Map<String, dynamic>) return;
      final int round = (response['current_round'] as num?)?.toInt() ?? 1;
      final int maxRounds = (response['max_rounds'] as num?)?.toInt() ?? 3;
      final double radius =
          (response['active_radius_km'] as num?)?.toDouble() ?? 5;
      final int dispatched =
          (response['dispatched_count'] as num?)?.toInt() ?? 0;
      final bool targeted = response['is_targeted'] == true;
      final String radiusText = radius == radius.truncateToDouble()
          ? radius.toStringAsFixed(0)
          : radius.toStringAsFixed(1);
      setState(() {
        _progressHeadline = targeted
            ? 'Waiting for this worker'
            : 'Checking artisans within $radiusText km';
        _progressDetail = dispatched > 0
            ? 'Round $round of $maxRounds - $dispatched request${dispatched == 1 ? '' : 's'} sent'
            : round > 1
                ? 'Trying another round and expanding the search'
                : 'Looking for available workers now';
      });
    } catch (_) {}

    try {
      final dynamic appsResponse = await _jobsService.getJobApplications(_jobId!);
      if (mounted && appsResponse is List) {
        setState(() {
          _applications = appsResponse.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {}
  }

  void _handleJobUpdate(Map<String, dynamic> job) {
    if (!mounted) return;
    final String status = (job['status'] as String? ?? '').toLowerCase();
    if (status == 'matched' ||
        status == 'on_the_way' ||
        status == 'arrived' ||
        status == 'in_progress' ||
        status == 'termination_requested' ||
        status == 'pending_client_approval') {
      _realtime.unsubscribe();
      _progressTimer?.cancel();
      _openTracking(job);
    } else if (status == 'expired' || status == 'cancelled') {
      _realtime.unsubscribe();
      _progressTimer?.cancel();
      setState(() {
        _isExpired = true;
        _errorMessage = status == 'expired'
            ? 'No artisans were available right now. Try posting again or adjust your location.'
            : 'This job was cancelled.';
      });
    }
  }

  void _openTracking(Map<String, dynamic> job) {
    final booking = ClientBooking.fromJobPost(
      jobData: <String, dynamic>{
        ...?widget.jobData,
        'id': job['id'],
        'title': job['title'],
        'status': job['status'],
        'worker_id': job['worker_id'],
        'location_lat': job['location_lat'],
        'location_lng': job['location_lng'],
        'budget_fixed': job['budget_fixed'],
        'budget_min': job['budget_min'],
        'budget_max': job['budget_max'],
      },
      artisan: widget.artisan,
    );
    ClientNavigation.openLiveTrackingFromMatch(context, booking: booking);
  }

  void _continueBrowsing() {
    if (_isContinuing) return;
    setState(() => _isContinuing = true);
    _realtime.unsubscribe();
    _progressTimer?.cancel();
    // Navigate back to the shell and select the Bookings tab so the user
    // can track matching progress there.
    ClientNavigation.replaceWithBookingsTab(context);
  }

  void _openBookings() {
    _realtime.unsubscribe();
    _progressTimer?.cancel();
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => JobApplicantsScreen(job: widget.jobData),
      ),
    ).then((_) {
      if (mounted) _startWatching();
    });
  }

  Future<void> _cancelSearch() async {
    if (_isCancelling) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Cancel search?'),
        content: const Text(
          'Are you sure you want to cancel? The artisan search will stop and your job post will be removed.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep searching'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    _realtime.unsubscribe();
    _progressTimer?.cancel();

    if (_jobId != null) {
      try {
        await _jobsService.cancelJob(_jobId!);
      } catch (_) {}
    }

    if (mounted) {
      AppToast.showInfo(context, 'Search cancelled.');
      ClientNavigation.replaceWithBookingsTab(context);
    }
  }

  @override
  void dispose() {
    _realtime.unsubscribe();
    _progressTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Finding Artisan',
        showBackButton: true,
        onBackPressed: _continueBrowsing,
        actions: <Widget>[
          if (_applications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openBookings,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_applications.length} ${_applications.length == 1 ? "Artisan" : "Artisans"} Applied',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _errorMessage != null
          ? ErrorStateView(
              message: _errorMessage!,
              title: _isExpired ? 'No match found' : 'Something went wrong',
              onRetry: _isExpired
                  ? () => ClientNavigation.replaceWithBookingsTab(context)
                  : () {
                      setState(() => _errorMessage = null);
                      _startWatching();
                    },
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    RotationTransition(
                      turns: _curvedTurns,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          PhosphorIcons.magnifyingGlass,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Finding the best artisan...',
                      style: AppTypography.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _progressHeadline,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _progressDetail,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'Continue browsing',
                      isLoading: _isContinuing,
                      onPressed: _continueBrowsing,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SecondaryButton(
                      label: 'Cancel search',
                      isLoading: _isCancelling,
                      isEnabled: !_isCancelling,
                      onPressed: _cancelSearch,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

