import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/workers_service.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
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
  });

  final MockWorkerJob job;
  final ValueChanged<MockWorkerJob> onAcceptRequest;

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
    HapticFeedback.mediumImpact();
    setState(() {
      _acceptLocked = true;
      _isAccepting = true;
    });
    try {
      await _workersService.acceptJob(widget.job.id);
      if (!mounted) return;
      widget.onAcceptRequest(widget.job);
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to accept request right now. $e',
          ),
        ),
      );
      setState(() {
        _acceptLocked = false;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isAccepting = false;
      });
    }
  }

  void _onDecline() async {
    HapticFeedback.lightImpact();
    try {
      await _workersService.declineJob(widget.job.id);
    } catch (_) {
      // Ignore errors for now
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: WorkerColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Request Details',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.primary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                WorkerSpacing.gutter,
                0,
                WorkerSpacing.gutter,
                WorkerSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(job.title, style: WorkerTextStyles.titleMd),
                      ),
                      if (job.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: WorkerColors.primaryFixed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'URGENT',
                            style: WorkerTextStyles.badge.copyWith(
                              color: WorkerColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: WorkerSpacing.md),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: WorkerColors.primaryFixed,
                        child: Text(
                          job.clientName.substring(0, 1),
                          style: WorkerTextStyles.titleMd.copyWith(
                            color: WorkerColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: WorkerSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.clientName,
                            style: WorkerTextStyles.bodyLg.copyWith(
                              color: WorkerColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFFFB800),
                              ),
                              Text(
                                ' ${formatRating(job.clientRating)} (${job.reviewCount} Reviews)',
                                style: WorkerTextStyles.bodyMd,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: WorkerSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: WorkerColors.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${job.distanceText} from your location',
                        style: WorkerTextStyles.bodyMd,
                      ),
                    ],
                  ),
                  const SizedBox(height: WorkerSpacing.md),
                  MapPlaceholder(
                    height: 140,
                    compact: true,
                    addressLabel: job.mapLabel ?? job.addressLabel,
                  ),
                  const SizedBox(height: WorkerSpacing.lg),
                  Text('REQUEST DESCRIPTION', style: WorkerTextStyles.labelCaps),
                  const SizedBox(height: WorkerSpacing.sm),
                  Text(job.description, style: WorkerTextStyles.bodyMd),
                  if (job.referencePhotoLabels.isNotEmpty) ...[
                    const SizedBox(height: WorkerSpacing.lg),
                    Row(
                      children: [
                        Text('SITE PHOTOS', style: WorkerTextStyles.labelCaps),
                        const Spacer(),
                        Text(
                          '${job.photoCount} PHOTOS',
                          style: WorkerTextStyles.labelCaps.copyWith(
                            color: WorkerColors.accentBlue,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: WorkerSpacing.sm),
                    ReferencePhotosRow(labels: job.referencePhotoLabels),
                  ],
                  const SizedBox(height: WorkerSpacing.lg),
                  TimingEstimateRow(job: job),
                  const SizedBox(height: WorkerSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Call ${job.clientName} — later'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_outlined),
                    label: Text('Call ${job.clientName}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: WorkerSpacing.lg),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              WorkerSpacing.gutter,
              12,
              WorkerSpacing.gutter,
              WorkerSpacing.md,
            ),
            decoration: BoxDecoration(
              color: WorkerColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
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
