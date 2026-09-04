import 'dart:async';

import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/shared/widgets/job_site_map.dart';
import 'package:artisans_app/shared/widgets/primary_button.dart';
import 'package:artisans_app/core/services/workers_service.dart';
import 'package:artisans_app/shared/models/worker_job.dart';
import 'package:artisans_app/features/worker/presentation/utils/worker_job_mapper.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_gradient_button.dart';
import 'package:artisans_app/features/worker/presentation/widgets/map_placeholder.dart';

class WorkerJobAlertSheet extends StatefulWidget {
  const WorkerJobAlertSheet({
    super.key,
    required this.job,
    required this.onAccepted,
    required this.onDeclined,
    this.onViewDetails,
    this.initialSeconds = 90,
  });

  final WorkerJob job;
  final ValueChanged<Map<String, dynamic>> onAccepted;
  final VoidCallback onDeclined;
  final ValueChanged<WorkerJob>? onViewDetails;
  final int initialSeconds;

  @override
  State<WorkerJobAlertSheet> createState() => _WorkerJobAlertSheetState();
}

class _WorkerJobAlertSheetState extends State<WorkerJobAlertSheet> {
  final WorkersService _workersService = WorkersService();
  Timer? _timer;
  late int _secondsLeft;
  bool _accepting = false;
  bool _declining = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _secondsLeft <= 0) return;
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double _parseEstimatedRate() {
    final job = widget.job;
    if (job.applicationTotalQuote != null && job.applicationTotalQuote! > 0) {
      return job.applicationTotalQuote!;
    }
    if (job.grossAmount != null && job.grossAmount! > 0) {
      return job.grossAmount!;
    }
    if (job.baseRate != null && job.baseRate! > 0) {
      return job.baseRate!;
    }
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(job.estimateDisplay);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 50.0;
    }
    return 50.0;
  }

  Future<void> _showQuoteModal() async {
    final double initialRate = _parseEstimatedRate();
    final TextEditingController rateController =
        TextEditingController(text: initialRate.toStringAsFixed(0));
    final TextEditingController noteController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double currentVal =
                double.tryParse(rateController.text) ?? initialRate;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confirm Your Quote',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client estimate: GH₵${initialRate.toStringAsFixed(0)}. You can adjust your quote below:',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: rateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Your Quote (GH₵)',
                      prefixText: 'GH₵ ',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ActionChip(
                          label: Text(
                              'GH₵${initialRate.toStringAsFixed(0)} (Base)'),
                          onPressed: () {
                            rateController.text =
                                initialRate.toStringAsFixed(0);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('+ GH₵10'),
                          onPressed: () {
                            rateController.text =
                                (currentVal + 10).toStringAsFixed(0);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('+ GH₵20'),
                          onPressed: () {
                            rateController.text =
                                (currentVal + 20).toStringAsFixed(0);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('+ GH₵50'),
                          onPressed: () {
                            rateController.text =
                                (currentVal + 50).toStringAsFixed(0);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText:
                          'Add an optional note (e.g. includes transport)',
                      hintStyle: AppTypography.bodySmall,
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: 'Send Quote',
                          onPressed: () {
                            final double? quote =
                                double.tryParse(rateController.text.trim());
                            if (quote == null || quote <= 0) {
                              AppToast.showError(
                                  context, 'Please enter a valid quote amount.');
                              return;
                            }
                            Navigator.of(context).pop(<String, dynamic>{
                              'proposedRate': quote,
                              'message': noteController.text.trim().isNotEmpty
                                  ? noteController.text.trim()
                                  : null,
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    rateController.dispose();
    noteController.dispose();

    if (result != null) {
      final double? proposedRate = result['proposedRate'] as double?;
      final String? message = result['message'] as String?;
      await _submitApplication(
        proposedRate: proposedRate,
        message: message,
      );
    }
  }

  Future<void> _submitApplication({
    double? proposedRate,
    String? message,
  }) async {
    if (_accepting || _declining) return;
    setState(() => _accepting = true);
    try {
      final dynamic application = await _workersService.applyToJob(
        widget.job.id,
        proposedRate: proposedRate,
        message: message,
      );
      if (!mounted) return;
      if (application is Map<String, dynamic>) {
        widget.onAccepted(application);
      }
      AppToast.showSuccess(
        context,
        'Quote sent (GH₵${(proposedRate ?? _parseEstimatedRate()).toStringAsFixed(0)}). The client will review your quote.',
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'This job has already been taken.',
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  Future<void> _decline() async {
    if (_accepting || _declining) return;
    
    // Instantly close the modal sheet to make the UI feel fast
    widget.onDeclined();
    if (mounted) Navigator.of(context).pop();

    // Fire the decline API request in the background
    try {
      await _workersService.declineJob(widget.job.id);
    } catch (e) {
      debugPrint('[WorkerJobAlertSheet] Background decline failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final Color timerColor =
        _secondsLeft <= 20 ? AppColors.error : AppColors.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: timerColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$_secondsLeft',
                    style: AppTypography.titleLarge.copyWith(color: timerColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('NEW JOB REQUEST', style: AppTypography.labelCaps),
                      const SizedBox(height: 4),
                      Text(job.title, style: AppTypography.titleLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Icon(PhosphorIcons.userCircle, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.clientName,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(job.estimateDisplay, style: AppTypography.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(PhosphorIcons.mapPin, color: AppColors.outline),
                const SizedBox(width: 8),
                Expanded(child: Text(job.addressLabel)),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: job.hasServiceLocation
                  ? JobSiteMap(
                      latitude: job.latitude,
                      longitude: job.longitude,
                      label: job.addressLabel,
                      height: 150,
                      showDirectionsButton: true,
                    )
                  : MapPlaceholder(
                      height: 130,
                      compact: true,
                      addressLabel: job.addressLabel,
                    ),
            ),
            const SizedBox(height: 14),
            Text(
              job.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlineButton(
                    label: 'Decline',
                    isLoading: _declining,
                    enabled: !_accepting,
                    onPressed: _decline,
                  ),
                ),
                if (widget.onViewDetails != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlineButton(
                      label: 'Details',
                      enabled: !_accepting && !_declining,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onViewDetails?.call(job);
                      },
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  flex: widget.onViewDetails != null ? 1 : 2,
                  child: WorkerGradientButton(
                    label: 'Apply',
                    isLoading: _accepting,
                    enabled: !_declining,
                    onPressed: _showQuoteModal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

WorkerJob workerJobAlertFromApi(Map<String, dynamic> json) =>
    workerJobFromApi(json);
