import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/offline/job_post_queue.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/services/pricing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../navigation/client_navigation.dart';
import '../widgets/job_post_wizard_scaffold.dart';

class JobPostSummaryScreen extends StatefulWidget {
  const JobPostSummaryScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostSummaryScreen> createState() => _JobPostSummaryScreenState();
}

class _JobPostSummaryScreenState extends State<JobPostSummaryScreen> {
  late ClientJobDraft _draft;
  bool _agreeToTerms = false;
  bool _isPosting = false;
  final JobsService _jobsService = JobsService();
  final PricingService _pricingService = PricingService();

  // Pricing state
  FeeEstimate? _estimate;
  bool _loadingPrice = true;
  String? _priceError;
  double _clientPremium = 0;

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _fetchPricing();
  }

  Future<void> _fetchPricing() async {
    setState(() {
      _loadingPrice = true;
      _priceError = null;
    });

    try {
      final String categoryId = _draft.categoryId ?? '';
      final double lat =
          (_draft.data['locationLat'] as num?)?.toDouble() ?? 5.6037;
      final double lng =
          (_draft.data['locationLng'] as num?)?.toDouble() ?? -0.1870;
      final String jobMode = (_draft.urgency ?? 'asap').toLowerCase();

      final estimate = await _pricingService.estimateFee(
        categoryId: categoryId,
        locationLat: lat,
        locationLng: lng,
        jobMode: jobMode,
      );

      if (!mounted) return;
      setState(() {
        _estimate = estimate;
        _loadingPrice = false;
        // Store in draft so payload uses it
        _draft.merge(<String, dynamic>{
          'recommendedFee': estimate.minimumFee,
          'clientPremium': _clientPremium,
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPrice = false;
        _priceError = 'Could not calculate pricing. Using default.';
        // Use a fallback so the user can still post
        _draft.merge(<String, dynamic>{
          'recommendedFee': 50.0,
          'clientPremium': 0.0,
        });
      });
    }
  }

  void _saveDraft() {
    AppToast.showInfo(context, 'Draft saved locally');
    ClientNavigation.popToShell(context);
  }

  Future<void> _postJob() async {
    if (!_agreeToTerms || _isPosting) return;

    // Ensure premium is synced
    _draft.merge(<String, dynamic>{'clientPremium': _clientPremium});

    setState(() => _isPosting = true);

    final payload = _draft.toCreateJobPayload();
    final idempotencyKey = const Uuid().v4();

    try {
      final dynamic created = await _jobsService.createJob(
        payload,
        idempotencyKey: idempotencyKey,
      );
      final Map<String, dynamic> jobData = _draft.toMap();
      if (created is Map<String, dynamic>) {
        jobData['id'] = created['id'];
        jobData['status'] = created['status'];
      }

      if (!mounted) return;
      AppToast.showSuccess(context, 'Job posted — finding an artisan…');
      ClientNavigation.startFindingArtisan(context, jobData: jobData);
    } catch (e) {
      if (!mounted) return;
      final bool offline = e is NetworkException;
      if (offline) {
        await JobPostQueue.instance.enqueue(payload);
        if (!mounted) return;
        AppToast.showInfo(
          context,
          'You are offline. Job queued and will post when connection returns.',
        );
        ClientNavigation.popToShell(context);
      } else {
        AppToast.showError(
            context, e, fallback: 'Failed to post job. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr = _draft.preferredDate != null
        ? '${_draft.preferredDate!.day}/${_draft.preferredDate!.month}/${_draft.preferredDate!.year}'
        : '—';

    final double totalFee =
        (_estimate?.minimumFee ?? 50) + _clientPremium;

    return JobPostWizardScaffold(
      step: JobPostWizardStep.summary,
      appBarTitle: 'Review & Post',
      headline: 'Review your job post',
      primaryLabel: _isPosting ? 'Posting…' : 'Post job',
      primaryEnabled: _agreeToTerms && !_isPosting && !_loadingPrice,
      onPrimary: _postJob,
      secondaryLabel: 'Save draft',
      onSecondary: _saveDraft,
      showDiscardOnBack: _draft.hasAnyData,
      onDiscard: () => ClientNavigation.popToShell(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Job details summary ─────────────────────────────────
          _SummaryRow(label: 'Category', value: _draft.displayCategory),
          _SummaryRow(
            label: 'Subcategory',
            value: _draft.displaySubcategory.isEmpty
                ? '—'
                : _draft.displaySubcategory,
          ),
          _SummaryRow(label: 'Title', value: _draft.displayTitle),
          _SummaryRow(
              label: 'Description', value: _draft.displayDescription),
          _SummaryRow(label: 'Location', value: _draft.displayLocation),
          _SummaryRow(label: 'Urgency', value: _draft.displayUrgency),
          if (_draft.urgency == 'scheduled')
            _SummaryRow(label: 'Preferred date', value: dateStr),
          if (_draft.photoUrls.isNotEmpty)
            _SummaryRow(
              label: 'Photos',
              value: '${_draft.photoUrls.length} attached',
            ),

          // ── Pricing section ─────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: _loadingPrice
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(PhosphorIcons.currencyCircleDollar,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Smart pricing',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primary,
                              )),
                        ],
                      ),
                      if (_priceError != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _priceError!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      if (_estimate != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _PriceBreakdownRow(
                          label: 'Base service fee',
                          amount: _estimate!.baseServiceFee,
                        ),
                        _PriceBreakdownRow(
                          label: 'Travel/distance cost',
                          amount: _estimate!.distanceCost,
                        ),
                        if (_estimate!.urgencyPremium > 0)
                          _PriceBreakdownRow(
                            label: 'ASAP urgency premium',
                            amount: _estimate!.urgencyPremium,
                          ),
                        if (_estimate!.verificationPremium > 0)
                          _PriceBreakdownRow(
                            label: 'Verified client bonus',
                            amount: _estimate!.verificationPremium,
                          ),
                        const Divider(height: 20),
                        _PriceBreakdownRow(
                          label: 'Recommended fee',
                          amount: _estimate!.minimumFee,
                          isBold: true,
                        ),
                      ],
                      // ── Optional premium ───────────────────────
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Add a premium for faster matching (optional)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            'GH₵${_clientPremium.toStringAsFixed(0)}',
                            style: AppTypography.labelLarge,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Slider(
                              value: _clientPremium,
                              min: 0,
                              max: 200,
                              divisions: 20,
                              label:
                                  'GH₵${_clientPremium.toStringAsFixed(0)}',
                              onChanged: (double v) {
                                setState(() {
                                  _clientPremium = v;
                                  _draft.merge(<String, dynamic>{
                                    'clientPremium': v,
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL',
                              style: AppTypography.labelLarge),
                          Text(
                            ClientJobDraft.formatGhs(totalFee),
                            style: AppTypography.displaySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

          // ── Terms ───────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: _agreeToTerms,
                onChanged: (bool? v) =>
                    setState(() => _agreeToTerms = v ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I agree to the platform terms and understand artisans may contact me about this job.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodyLarge),
        ],
      ),
    );
  }
}

class _PriceBreakdownRow extends StatelessWidget {
  const _PriceBreakdownRow({
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  final String label;
  final double amount;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTypography.labelMedium
                : AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
          Text(
            ClientJobDraft.formatGhs(amount),
            style: isBold
                ? AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  )
                : AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
