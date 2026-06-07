import 'dart:async';

import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/job_site_map.dart';
import '../../../../core/services/workers_service.dart';
import '../models/worker_job.dart';
import '../utils/worker_job_mapper.dart';
import 'gradient_button.dart';
import 'map_placeholder.dart';

class WorkerJobAlertSheet extends StatefulWidget {
  const WorkerJobAlertSheet({
    super.key,
    required this.job,
    required this.onAccepted,
    required this.onDeclined,
    this.initialSeconds = 90,
  });

  final WorkerJob job;
  final ValueChanged<Map<String, dynamic>> onAccepted;
  final VoidCallback onDeclined;
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

  Future<void> _accept() async {
    if (_accepting || _declining) return;
    setState(() => _accepting = true);
    try {
      final dynamic accepted = await _workersService.acceptJob(widget.job.id);
      if (!mounted) return;
      if (accepted is Map<String, dynamic>) {
        widget.onAccepted(accepted);
      }
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
    setState(() => _declining = true);
    try {
      await _workersService.declineJob(widget.job.id);
      widget.onDeclined();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not decline request.');
    } finally {
      if (mounted) setState(() => _declining = false);
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
                    label: _declining ? 'Declining...' : 'Decline',
                    onPressed: _declining ? null : _decline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: 'Accept Job',
                    isLoading: _accepting,
                    enabled: !_declining,
                    onPressed: _accept,
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
