import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/applications_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../models/client_booking.dart';

class JobApplicantsScreen extends StatefulWidget {
  const JobApplicantsScreen({super.key, this.job});

  final Map<String, dynamic>? job;

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  final ApplicationsService _applicationsService = ApplicationsService();
  bool _isLoading = true;
  bool _isAccepting = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];

  String get _jobId =>
      (widget.job?['job_id'] ?? widget.job?['jobId'] ?? widget.job?['id'] ?? '')
          .toString();

  String get _title => (widget.job?['title'] ?? 'Job applicants').toString();

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    if (_jobId.isEmpty) {
      setState(() {
        _errorMessage = 'This job is missing its ID.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> data = await _applicationsService.listForJob(_jobId);
      if (!mounted) return;
      setState(() {
        _applications = data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            userMessageFor(e, fallback: 'Could not load interested artisans.');
        _isLoading = false;
      });
    }
  }

  Future<void> _accept(Map<String, dynamic> application) async {
    if (_isAccepting) return;
    final String applicationId = (application['id'] ?? '').toString();
    if (applicationId.isEmpty) return;

    setState(() => _isAccepting = true);
    try {
      final dynamic job = await _applicationsService.acceptApplication(
        jobId: _jobId,
        applicationId: applicationId,
      );
      if (!mounted) return;
      AppToast.showSuccess(context, 'Artisan selected for this job.');
      final Map<String, dynamic> jobMap = Map<String, dynamic>.from(job as Map);
      Navigator.pushNamed(
        context,
        AppRoutes.liveTracking,
        arguments: ClientBooking.fromApiJob(jobMap).toTrackingMap(),
      );
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not accept artisan.');
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Interested Artisans',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      ErrorStateView(
                        title: 'Could not load applicants',
                        message: _errorMessage!,
                        onRetry: _loadApplications,
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.gutter,
                      AppSpacing.gutter,
                      120,
                    ),
                    children: <Widget>[
                      Text(_title, style: AppTypography.displaySmall),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _applications.isEmpty
                            ? 'No artisans have applied yet.'
                            : '${_applications.length} artisan${_applications.length == 1 ? '' : 's'} want this job.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_applications.isEmpty)
                        _EmptyApplicants()
                      else
                        ..._applications.map(
                          (Map<String, dynamic> application) => _ApplicantCard(
                            application: application,
                            isAccepting: _isAccepting,
                            onAccept: () => _accept(application),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.application,
    required this.isAccepting,
    required this.onAccept,
  });

  final Map<String, dynamic> application;
  final bool isAccepting;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> worker =
        Map<String, dynamic>.from(application['worker'] as Map? ?? const {});
    final Map<String, dynamic> stats =
        Map<String, dynamic>.from(application['worker_stats'] as Map? ?? const {});
    final String name = (worker['full_name'] ?? 'Artisan').toString();
    final String avatarUrl = (worker['avatar_url'] ?? '').toString();
    final String status = (application['status'] ?? 'pending').toString();
    final double rating = (stats['rating'] as num?)?.toDouble() ?? 0;
    final int totalJobs = (stats['total_jobs'] as num?)?.toInt() ?? 0;
    final List<dynamic> skills = stats['skills'] as List<dynamic>? ?? <dynamic>[];
    final Object? rate = application['proposed_rate'];
    final String message = (application['message'] ?? '').toString();
    final bool canAccept = status == 'pending' && !isAccepting;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                ArtisanLogoAvatar(imageUrl: avatarUrl, size: 52),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(name, style: AppTypography.labelLarge),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Icon(PhosphorIcons.star,
                              size: 15, color: AppColors.accentGold),
                          const SizedBox(width: 4),
                          Text(
                            '${rating.toStringAsFixed(1)} · $totalJobs jobs',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: status),
              ],
            ),
            if (skills.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: skills
                    .take(3)
                    .map((dynamic skill) => Chip(label: Text(skill.toString())))
                    .toList(),
              ),
            ],
            if (rate != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text('Proposed rate: GHS $rate', style: AppTypography.bodyMedium),
            ],
            if (message.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: AppTypography.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: status == 'accepted' ? 'Accepted' : 'Accept Artisan',
              isLoading: isAccepting && status == 'pending',
              isEnabled: canAccept,
              onPressed: onAccept,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final bool accepted = status == 'accepted';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accepted
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        accepted ? 'Accepted' : status,
        style: AppTypography.labelSmall.copyWith(
          color: accepted ? AppColors.success : AppColors.primary,
        ),
      ),
    );
  }
}

class _EmptyApplicants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: <Widget>[
          Icon(PhosphorIcons.users, size: 36, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Waiting for artisans',
            style: AppTypography.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Interested artisans will appear here as they apply.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
