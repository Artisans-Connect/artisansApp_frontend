import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/job_realtime_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/worker_tracking_map.dart';
import '../models/client_booking_stub.dart';
import '../navigation/client_navigation.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const LiveTrackingScreen({
    super.key,
    this.job,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final JobsService _jobsService = JobsService();
  final JobRealtimeService _realtime = JobRealtimeService();
  Map<String, dynamic>? _job;
  bool _loading = true;
  String? _loadError;
  int _currentStep = 0;
  String _etaLabel = 'Calculating ETA…';

  List<Map<String, dynamic>> get _steps => <Map<String, dynamic>>[
        {
          'title': 'Confirmed',
          'description': 'Job accepted by artisan',
          'icon': PhosphorIcons.checkCircle,
        },
        {
          'title': 'On the Way',
          'description': 'Artisan is heading to your location',
          'icon': PhosphorIcons.navigationArrow,
        },
        {
          'title': 'Arrived',
          'description': 'Artisan has arrived at your location',
          'icon': PhosphorIcons.mapPin,
        },
        {
          'title': 'Work in Progress',
          'description': 'Artisan is working on your job',
          'icon': PhosphorIcons.wrench,
        },
        {
          'title': 'Completed',
          'description': 'Job is done. Awaiting your approval',
          'icon': PhosphorIcons.checks,
        },
      ];

  @override
  void initState() {
    super.initState();
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
        fullJob = <String, dynamic>{...? _job, ...job};
      }
    }

    final ClientBooking booking = ClientBooking.fromApiJob(fullJob);
    if (!mounted) return;
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
      'matched' => 1,
      'in_progress' => 3,
      'completed' => 4,
      _ => 0,
    };
    setState(() => _currentStep = step);
  }

  @override
  void dispose() {
    _realtime.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job = _job ?? <String, dynamic>{
      'title': 'Your job',
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
    final bool canRate = status == 'completed';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Live Tracking',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_loadError != null) ...<Widget>[
                      Text(
                        _loadError!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _buildJobInfoCard(job),
                    const SizedBox(height: AppSpacing.lg),
                    if (workerId != null && jobLat != null && jobLng != null)
                      WorkerTrackingMap(
                        workerId: workerId,
                        jobLat: jobLat,
                        jobLng: jobLng,
                        onEtaChanged: (eta) => setState(() => _etaLabel = eta),
                      )
                    else
                      Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: Text(
                          'Waiting for artisan location…',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Job Progress',
                      style: AppTypography.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildProgressTimeline(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildArtisanDetailCard(job),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: job['phone'] != null
                                ? () => ClientNavigation.callPhone(
                                      context,
                                      job['phone'] as String,
                                    )
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(PhosphorIcons.phone, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Call',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: jobUuid != null
                                ? () => ClientNavigation.openChat(
                                      context,
                                      conversationId: jobUuid,
                                      counterpartUserId:
                                          job['counterpartUserId'] as String? ??
                                              workerId ??
                                              '',
                                      counterpartName:
                                          job['artisan'] as String? ?? 'Artisan',
                                      jobId: jobUuid,
                                      jobTitle: job['title'] as String?,
                                    )
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(PhosphorIcons.chatTeardrop, size: 18),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Message',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: canRate
                          ? 'Rate completed job'
                          : 'Waiting for worker completion',
                      isEnabled: canRate,
                      onPressed: () {
                        if (!canRate) return;
                        Navigator.pushNamed(
                          context,
                          AppRoutes.rateService,
                          arguments: _job,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () => ClientNavigation.goToBookingsTab(context),
                        child: Text(
                          'View all bookings',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildJobInfoCard(Map<String, dynamic> job) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            job['title'] as String? ?? 'Your job',
            style: AppTypography.labelLarge.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'ETA',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    job['eta'] as String? ?? _etaLabel,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                ),
                child: Text(
                  'In Progress',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    return Column(
      children: List.generate(_steps.length, (int index) {
        final Map<String, dynamic> step = _steps[index];
        final bool isCompleted = index <= _currentStep;
        final bool isCurrent = index == _currentStep;

        return Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: isCompleted ? Colors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        step['title'] as String,
                        style: AppTypography.labelLarge.copyWith(
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        step['description'] as String,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index < _steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                child: Container(
                  height: 40,
                  width: 2,
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildArtisanDetailCard(Map<String, dynamic> job) {
    final String? imageUrl = job['imageUrl'] as String?;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: imageUrl != null && imageUrl.startsWith('http')
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        PhosphorIcons.user,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  )
                : Icon(PhosphorIcons.user, color: AppColors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  job['artisan'] as String? ?? 'Artisan',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  job['profession'] as String? ?? 'Service provider',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (job['phone'] != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    job['phone'] as String,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
