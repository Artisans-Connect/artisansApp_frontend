import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:artisans_app/core/theme/index.dart';
import '../../../../core/services/workers_service.dart';
import '../../../client/presentation/navigation/client_navigation.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/job_site_map.dart';
import '../models/worker_job.dart';
import '../utils/worker_formatters.dart';
import '../widgets/gradient_button.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/reference_photos_row.dart';
import '../widgets/timing_estimate_row.dart';
import '../../../../shared/widgets/custom_back_button.dart';

class JobRequestDetailScreen extends StatefulWidget {
  const JobRequestDetailScreen({
    super.key,
    required this.job,
    required this.onAcceptRequest,
    this.onAcceptResponse,
  });
  final WorkerJob job;
  final ValueChanged<WorkerJob> onAcceptRequest;
  final ValueChanged<Map<String, dynamic>>? onAcceptResponse;
  @override
  State<JobRequestDetailScreen> createState() =>
      _JobRequestDetailScreenState();
}
class _JobRequestDetailScreenState extends State<JobRequestDetailScreen> {
  final WorkersService _workersService = WorkersService();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _proposedRateController = TextEditingController();
  bool _applyLocked = false;
  bool _isApplying = false;

  @override
  void dispose() {
    _noteController.dispose();
    _proposedRateController.dispose();
    super.dispose();
  }

  void _onApply() async {
    if (_isApplying || _applyLocked) return;
    await HapticFeedback.mediumImpact();
    setState(() {
      _applyLocked = true;
      _isApplying = true;
    });
    try {
      final double? customRate =
          double.tryParse(_proposedRateController.text.trim());
      final dynamic application = await _workersService.applyToJob(
        widget.job.id,
        message: _noteController.text,
        proposedRate: customRate,
      );
      if (!mounted) return;
      if (application is Map<String, dynamic>) {
        widget.onAcceptResponse?.call(application);
      }
      AppToast.showSuccess(context, 'Application sent. The client will choose an artisan.');
      await Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Unable to apply for this request.');
      setState(() {
        _applyLocked = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }
  void _onDecline() async {
    await HapticFeedback.lightImpact();
    try {
      await _workersService.declineJob(widget.job.id);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not decline request.');
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Request Details',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(job.title, style: AppTypography.titleLarge),
                      ),
                      if (job.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'URGENT',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryFixed,
                        child: Text(
                          job.clientName.substring(0, 1),
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.clientName,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                PhosphorIcons.star,
                                size: 16,
                                color: Color(0xFFFFB800),
                              ),
                              Text(
                                ' ${formatRating(job.clientRating)} (${job.reviewCount} Reviews)',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.mapPin,
                        size: 18,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${job.distanceText} from your location',
                          style: AppTypography.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (job.hasServiceLocation)
                    JobSiteMap(
                      latitude: job.latitude,
                      longitude: job.longitude,
                      label: job.addressLabel,
                      height: 180,
                      showDirectionsButton: true,
                    )
                  else
                    MapPlaceholder(
                      height: 140,
                      compact: true,
                      addressLabel: job.mapLabel ?? job.addressLabel,
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('REQUEST DESCRIPTION', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  Text(job.description, style: AppTypography.bodyMedium),
                  if (job.referencePhotoLabels.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Text('SITE PHOTOS', style: AppTypography.labelCaps),
                        const Spacer(),
                        Text(
                          '${job.photoCount} PHOTOS',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.accentBlue,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ReferencePhotosRow(labels: job.referencePhotoLabels),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  TimingEstimateRow(job: job),
                  if (job.applicationTotalQuote != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _QuoteBreakdown(job: job),
                  ],
                  Text('PROPOSED RATE (GH₵)', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _proposedRateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Default rate: GH₵ ${(job.grossAmount ?? 0).round()}',
                      prefixText: 'GH₵ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('NOTE TO CLIENT', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: 'Optional note about your availability or approach',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => _callClient(job),
                    icon: Icon(PhosphorIcons.phone),
                    label: Text('Call ${job.clientName}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              12,
              AppSpacing.gutter,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: 'Decline',
                      onPressed: _onDecline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      label: 'Apply for Job',
                      isLoading: _isApplying,
                      enabled: !_applyLocked && !_isApplying,
                      onPressed: _applyLocked ? null : _onApply,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callClient(WorkerJob job) async {
    final String phone = job.clientPhone ?? '';
    await ClientNavigation.callPhone(context, phone);
  }
}

class _QuoteBreakdown extends StatelessWidget {
  const _QuoteBreakdown({required this.job});

  final WorkerJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR LOCKED QUOTE', style: AppTypography.labelCaps),
          const SizedBox(height: AppSpacing.sm),
          if (job.applicationBaseServiceFee != null)
            _QuoteRow('Base service', job.applicationBaseServiceFee!),
          if (job.applicationDistanceKm != null &&
              job.applicationDistanceCost != null)
            _QuoteRow(
              'Travel (${job.applicationDistanceKm!.toStringAsFixed(1)} km)',
              job.applicationDistanceCost!,
            ),
          if ((job.applicationUrgencyPremium ?? 0) > 0)
            _QuoteRow('ASAP premium', job.applicationUrgencyPremium!),
          const Divider(height: 18),
          _QuoteRow('Total', job.applicationTotalQuote!, isTotal: true),
        ],
      ),
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow(this.label, this.amount, {this.isTotal = false});

  final String label;
  final double amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTypography.labelLarge : AppTypography.bodyMedium,
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
