import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/job_site_map.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/client_contact_row.dart';
import '../widgets/elapsed_timer_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/job_detail_card.dart';
import 'worker_completion_form_screen.dart';
class WorkerActiveInProgressScreen extends StatelessWidget {
  const WorkerActiveInProgressScreen({super.key, required this.job});
  final MockWorkerJob job;
  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'In Progress',
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.dotsThreeVertical),
            onPressed: () => _stub(context, 'More actions'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ElapsedTimerCard(),
            const SizedBox(height: AppSpacing.md),
            JobDetailCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryFixed,
                    child: Text(
                      job.clientName.substring(0, 1),
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.clientName, style: AppTypography.titleMd),
                        Text(
                          'Residential Client',
                          style: AppTypography.bodyMd,
                        ),
                      ],
                    ),
                  ),
                  ClientContactRow(
                    onMessage: () => _stub(context, 'Message'),
                    onCall: () => _callClient(context, job),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (job.hasServiceLocation) ...[
              JobSiteMap(
                latitude: job.latitude,
                longitude: job.longitude,
                label: job.addressLabel,
                height: 220,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            JobDetailCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: PhosphorIcons.mapPin,
                    label: 'BOOKING LOCATION',
                    value: job.addressLabel,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _DetailRow(
                    icon: PhosphorIcons.fileText,
                    label: 'REQUEST DETAILS',
                    value: job.description,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: 'Mark as Complete',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkerCompletionFormScreen(
                      job: job,
                      onCompletionSubmitted: session.completeJob,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: () => _stub(context, 'Support'),
              icon: Icon(PhosphorIcons.headset, size: 18),
              label: const Text('Need help? Call support'),
            ),
          ],
        ),
      ),
    );
  }
  void _stub(BuildContext context, String action) {
    AppToast.showInfo(context, '$action — coming soon');
  }
}
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines,
  });
  final IconData icon;
  final String label;
  final String value;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 9)),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
