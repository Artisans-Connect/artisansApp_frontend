import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/applications_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../models/client_booking.dart';
import 'payment_checkout_screen.dart';

class JobApplicantsScreen extends StatefulWidget {
  const JobApplicantsScreen({super.key, this.job});

  final Map<String, dynamic>? job;

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  final ApplicationsService _applicationsService = ApplicationsService();
  final JobsService _jobsService = JobsService();
  bool _isLoading = true;
  bool _isAccepting = false;
  bool _isCancelling = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];

  String get _jobId =>
      (widget.job?['job_id'] ?? widget.job?['jobId'] ?? widget.job?['id'] ?? '')
          .toString();

  String get _title => (widget.job?['title'] ?? 'Job applicants').toString();

  bool get _canCancelSearch {
    final String status =
        (widget.job?['backendStatus'] ?? widget.job?['status'] ?? '')
            .toString()
            .toLowerCase();
    return _jobId.isNotEmpty &&
        (status.isEmpty ||
            status == 'requested' ||
            status == 'searching' ||
            status == 'matching');
  }

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
            .map(
                (Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
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

  /// Accept the application at the quoted price → backend moves job to awaiting_payment → client pays
  Future<void> _accept(Map<String, dynamic> application) async {
    if (_isAccepting) return;
    final String applicationId = (application['id'] ?? '').toString();
    if (applicationId.isEmpty) return;

    setState(() => _isAccepting = true);
    try {
      // Step 1: Accept the application if it's not already accepted (backend sets status to awaiting_payment)
      final String appStatus = (application['status'] ?? '').toString().toLowerCase();
      if (appStatus != 'accepted') {
        await _applicationsService.acceptApplication(
          jobId: _jobId,
          applicationId: applicationId,
        );
      }

      if (!mounted) return;

      // Step 2: Navigate to payment checkout
      final double totalQuote = double.tryParse((application['total_quote'] ?? '').toString()) ?? 100.00;
      final double deposit = totalQuote * 0.20;

      final bool? paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (BuildContext context) => PaymentCheckoutScreen(
            jobId: _jobId,
            applicationId: applicationId,
            amount: deposit,
          ),
        ),
      );

      if (!mounted) return;
      if (paid == true) {
        final List<dynamic> jobs = await JobsService().getMyJobs(forceRefresh: true);
        final Iterable<Map<String, dynamic>> matches = jobs
            .whereType<Map<String, dynamic>>()
            .where((j) => j['id'].toString() == _jobId);
        final Map<String, dynamic>? updatedJob = matches.isNotEmpty ? matches.first : null;

        if (updatedJob != null && mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.liveTracking,
            arguments: ClientBooking.fromApiJob(updatedJob).toTrackingMap(),
          );
        } else if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not accept artisan.');
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  /// Show dialog for client to propose a counter-offer
  Future<void> _counterOffer(Map<String, dynamic> application) async {
    final String applicationId = (application['id'] ?? '').toString();
    if (applicationId.isEmpty) return;

    final double? currentQuote = double.tryParse(
      (application['total_quote'] ?? application['proposed_rate'] ?? '').toString(),
    );

    final double? counterRate = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        final TextEditingController controller = TextEditingController(
          text: currentQuote != null ? currentQuote.toStringAsFixed(0) : '',
        );
        return AlertDialog(
          title: const Text('Counter Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (currentQuote != null)
                Text(
                  'Artisan quoted: GHS ${currentQuote.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              if (currentQuote != null) const SizedBox(height: 12),
              const Text(
                'Enter your proposed amount:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  prefixText: 'GHS ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: '0.00',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final double? val = double.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  Navigator.pop(dialogContext, val);
                }
              },
              child: const Text('Send Counter'),
            ),
          ],
        );
      },
    );

    if (counterRate == null || !mounted) return;

    try {
      await _applicationsService.counterApplication(
        jobId: _jobId,
        applicationId: applicationId,
        counterRate: counterRate,
      );
      if (!mounted) return;
      AppToast.showSuccess(
        context,
        'Counter-offer of GHS ${counterRate.toStringAsFixed(2)} sent.',
      );
      _loadApplications(); // Refresh the list
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not send counter-offer.');
      }
    }
  }

  Future<void> _cancelSearch() async {
    if (_isCancelling || !_canCancelSearch) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Cancel job search?'),
        content: const Text(
          'This will stop artisans from applying to this job.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep searching'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel search'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await _jobsService.cancelJob(_jobId);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Job search cancelled.');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e,
            fallback: 'Could not cancel job search.');
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _openApplicantProfile(Map<String, dynamic> application) {
    final Map<String, dynamic> worker =
        Map<String, dynamic>.from(application['worker'] as Map? ?? const {});
    final Map<String, dynamic> stats = Map<String, dynamic>.from(
        application['worker_stats'] as Map? ?? const {});
    final String workerId =
        (application['worker_id'] ?? worker['id'] ?? '').toString();
    Navigator.pushNamed(
      context,
      AppRoutes.artisanProfile,
      arguments: <String, dynamic>{
        'id': workerId,
        'worker_id': workerId,
        'profiles': <String, dynamic>{
          ...worker,
          if (worker['id'] == null) 'id': workerId,
        },
        'worker': stats,
        if (stats['skills'] != null) 'skills': stats['skills'],
        if (stats['rating'] != null) 'rating': stats['rating'],
        if (stats['total_jobs'] != null) 'totalJobs': stats['total_jobs'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Interested Artisans',
        onBackPressed: () => Navigator.pop(context),
        actions: <Widget>[
          if (_canCancelSearch)
            TextButton.icon(
              onPressed: _isCancelling ? null : _cancelSearch,
              icon: _isCancelling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(PhosphorIcons.xCircle),
              label: const Text('Cancel'),
            ),
          const SizedBox(width: 8),
        ],
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
                            onCounter: () => _counterOffer(application),
                            onViewProfile: () =>
                                _openApplicantProfile(application),
                            isAwaitingPayment: (widget.job?['backendStatus'] ?? widget.job?['status'] ?? '').toString().toLowerCase() == 'awaiting_payment',
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
    required this.onCounter,
    required this.onViewProfile,
    required this.isAwaitingPayment,
  });

  final Map<String, dynamic> application;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onCounter;
  final VoidCallback onViewProfile;
  final bool isAwaitingPayment;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> worker =
        Map<String, dynamic>.from(application['worker'] as Map? ?? const {});
    final Map<String, dynamic> stats = Map<String, dynamic>.from(
        application['worker_stats'] as Map? ?? const {});
    final String name = (worker['full_name'] ?? 'Artisan').toString();
    final String avatarUrl = (worker['avatar_url'] ?? '').toString();
    final String status = (application['status'] ?? 'pending').toString();
    final double rating = (stats['rating'] as num?)?.toDouble() ?? 0;
    final int totalJobs = (stats['total_jobs'] as num?)?.toInt() ?? 0;
    final List<dynamic> skills =
        stats['skills'] as List<dynamic>? ?? <dynamic>[];
    final double? proposedRate =
        (application['proposed_rate'] as num?)?.toDouble();
    final double? totalQuote =
        (application['total_quote'] as num?)?.toDouble() ?? proposedRate;
    final bool hasCustomProposal = proposedRate != null;
    final double? distanceKm = (application['distance_km'] as num?)?.toDouble();
    final double? distanceCost =
        (application['distance_cost'] as num?)?.toDouble();
    final double? baseServiceFee =
        (application['base_service_fee'] as num?)?.toDouble();
    final double? urgencyPremium =
        (application['urgency_premium'] as num?)?.toDouble();
    final String message = (application['message'] ?? '').toString();
    final String lastProposedBy = (application['last_proposed_by'] ?? '').toString();
    final double? counterRate = (application['counter_rate'] as num?)?.toDouble();
    final bool hasActiveCounter = lastProposedBy.isNotEmpty;
    final bool canAccept = (status == 'pending' || (status == 'accepted' && isAwaitingPayment)) && !isAccepting;
    final bool canCounter = status == 'pending' && !isAccepting;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onViewProfile,
        borderRadius: BorderRadius.circular(12),
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
                      .map((dynamic skill) =>
                          Chip(label: Text(skill.toString())))
                      .toList(),
                ),
              ],
              if (totalQuote != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                _ApplicantQuote(
                  totalQuote: totalQuote,
                  distanceKm: distanceKm,
                  distanceCost: distanceCost,
                  baseServiceFee: baseServiceFee,
                  urgencyPremium: urgencyPremium,
                  hasCustomProposal: hasCustomProposal,
                ),
              ],
              if (message.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(message, style: AppTypography.bodyMedium),
              ],
              // Negotiation status banner
              if (hasActiveCounter) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: lastProposedBy == 'client'
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        PhosphorIcons.arrowsLeftRight,
                        size: 16,
                        color: lastProposedBy == 'client'
                            ? AppColors.primary
                            : AppColors.accentGold,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lastProposedBy == 'client'
                              ? 'You offered GHS ${counterRate?.toStringAsFixed(2) ?? '—'} · Waiting for artisan'
                              : 'Artisan countered with GHS ${counterRate?.toStringAsFixed(2) ?? '—'}',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: lastProposedBy == 'client'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              // Action buttons: View Profile, Counter, Accept
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewProfile,
                      icon: Icon(PhosphorIcons.userCircle),
                      label: const Text('Profile'),
                    ),
                  ),
                  if (canCounter) ...<Widget>[
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCounter,
                        icon: Icon(PhosphorIcons.arrowsLeftRight),
                        label: const Text('Counter'),
                      ),
                    ),
                  ],
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: PrimaryButton(
                      label: (status == 'accepted' && isAwaitingPayment)
                          ? 'Pay Deposit'
                          : (status == 'accepted' ? 'Accepted' : 'Accept'),
                      isLoading: isAccepting && (status == 'pending' || status == 'accepted'),
                      isEnabled: canAccept,
                      onPressed: onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicantQuote extends StatelessWidget {
  const _ApplicantQuote({
    required this.totalQuote,
    this.distanceKm,
    this.distanceCost,
    this.baseServiceFee,
    this.urgencyPremium,
    required this.hasCustomProposal,
  });

  final double totalQuote;
  final double? distanceKm;
  final double? distanceCost;
  final double? baseServiceFee;
  final double? urgencyPremium;
  final bool hasCustomProposal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            hasCustomProposal
                ? 'Artisan proposed quote'
                : 'Artisan quote estimate',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasCustomProposal
                ? 'This artisan edited the amount before applying. Review this total before accepting.'
                : 'This total is calculated from the service estimate and travel details.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (baseServiceFee != null) _row('Base service', baseServiceFee!),
          if (distanceCost != null)
            _row(
              distanceKm != null
                  ? 'Travel (${distanceKm!.toStringAsFixed(1)} km)'
                  : 'Travel',
              distanceCost!,
            ),
          if ((urgencyPremium ?? 0) > 0)
            _row('ASAP premium', urgencyPremium!),
          const Divider(height: 18),
          _row('Total to review', totalQuote, isTotal: true),
        ],
      ),
    );
  }

  Widget _row(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: (isTotal ? AppTypography.labelLarge : AppTypography.bodySmall)
                .copyWith(
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            'GHS ${amount.toStringAsFixed(2)}',
            style: (isTotal ? AppTypography.labelLarge : AppTypography.bodyMedium)
                .copyWith(color: AppColors.primary),
          ),
        ],
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
