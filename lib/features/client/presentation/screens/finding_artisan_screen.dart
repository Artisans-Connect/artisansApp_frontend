import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../models/client_booking_stub.dart';
import '../navigation/client_navigation.dart';

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
  Timer? _pollTimer;
  String? _errorMessage;
  bool _isExpired = false;

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
    _startPolling();
  }

  String? get _jobId => widget.jobData?['id'] as String?;

  void _startPolling() {
    if (_jobId == null) {
      _scheduleFallbackMatch();
      return;
    }
    _pollJob();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _pollJob());
  }

  Future<void> _pollJob() async {
    if (_jobId == null || !mounted) return;
    try {
      final dynamic job = await _jobsService.getJobById(_jobId!);
      if (job is! Map<String, dynamic>) return;

      final String status = (job['status'] as String? ?? '').toLowerCase();
      if (status == 'matched' || status == 'in_progress') {
        _pollTimer?.cancel();
        if (!mounted) return;
        _openTracking(job);
      } else if (status == 'expired' || status == 'cancelled') {
        _pollTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _isExpired = true;
          _errorMessage = status == 'expired'
              ? 'No artisans were available right now. Try posting again or adjust your location.'
              : 'This job was cancelled.';
        });
      }
    } catch (_) {}
  }

  void _scheduleFallbackMatch() {
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted || _isExpired) return;
      final booking = ClientBooking.fromJobPost(
        jobData: widget.jobData ?? <String, dynamic>{},
        artisan: widget.artisan,
      );
      ClientNavigation.openLiveTrackingFromMatch(context, booking: booking);
    });
  }

  void _openTracking(Map<String, dynamic> job) {
    final booking = ClientBooking.fromJobPost(
      jobData: <String, dynamic>{
        ...?widget.jobData,
        'id': job['id'],
        'title': job['title'],
        'status': job['status'],
      },
      artisan: widget.artisan,
    );
    ClientNavigation.openLiveTrackingFromMatch(context, booking: booking);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
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
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _errorMessage != null
          ? ErrorStateView(
              message: _errorMessage!,
              title: _isExpired ? 'No match found' : 'Something went wrong',
              onRetry: _isExpired
                  ? () => Navigator.pop(context)
                  : () {
                      setState(() => _errorMessage = null);
                      _startPolling();
                    },
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
                        child: Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.primary, size: 48),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Finding the best artisan…',
                      style: AppTypography.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.jobData?['title'] as String? ?? 'Your job request',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'We are notifying nearby verified artisans. This usually takes a minute or two.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SecondaryButton(
                      label: 'Cancel search',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
