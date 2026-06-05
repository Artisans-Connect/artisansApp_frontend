import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:artisans_app/core/theme/index.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/mock_worker_job.dart';
import '../utils/worker_job_mapper.dart';
import '../utils/worker_formatters.dart';
import '../widgets/gradient_button.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/reference_photos_row.dart';
import '../widgets/timing_estimate_row.dart';
class JobRequestDetailScreen extends StatefulWidget {
  const JobRequestDetailScreen({
    super.key,
    required this.job,
    required this.onAcceptRequest,
    this.onAcceptResponse,
  });
  final MockWorkerJob job;
  final ValueChanged<MockWorkerJob> onAcceptRequest;
  final ValueChanged<Map<String, dynamic>>? onAcceptResponse;
  @override
  State<JobRequestDetailScreen> createState() =>
      _JobRequestDetailScreenState();
}
class _JobRequestDetailScreenState extends State<JobRequestDetailScreen> {
  final WorkersService _workersService = WorkersService();
  bool _acceptLocked = false;
  bool _isAccepting = false;
  void _onAccept() async {
    if (_isAccepting || _acceptLocked) return;
    await HapticFeedback.mediumImpact();
    setState(() {
      _acceptLocked = true;
      _isAccepting = true;
    });
    try {
      final dynamic accepted = await _workersService.acceptJob(widget.job.id);
      if (!mounted) return;
      if (accepted is Map<String, dynamic>) {
        widget.onAcceptResponse?.call(accepted);
        if (widget.onAcceptResponse == null) {
          widget.onAcceptRequest(workerJobFromApi(accepted));
        }
      } else {
        widget.onAcceptRequest(widget.job);
      }
      await Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Unable to accept this request.');
      setState(() {
        _acceptLocked = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
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
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Request Details',
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
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
                        child: Text(job.title, style: AppTypography.titleMd),
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
                          style: AppTypography.titleMd.copyWith(
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
                            style: AppTypography.bodyLg.copyWith(
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
                                style: AppTypography.bodyMd,
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
                      Text(
                        '${job.distanceText} from your location',
                        style: AppTypography.bodyMd,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MapPlaceholder(
                    height: 140,
                    compact: true,
                    addressLabel: job.mapLabel ?? job.addressLabel,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('REQUEST DESCRIPTION', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  Text(job.description, style: AppTypography.bodyMd),
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
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Call ${job.clientName} — later'),
                        ),
                      );
                    },
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
                      label: 'Accept Job',
                      isLoading: _isAccepting,
                      enabled: !_acceptLocked && !_isAccepting,
                      onPressed: _acceptLocked ? null : _onAccept,
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
}
