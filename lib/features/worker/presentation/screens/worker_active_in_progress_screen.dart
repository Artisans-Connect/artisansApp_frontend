import 'package:flutter/material.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
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
    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: WorkerColors.primary,
          onPressed: () {},
        ),
        title: Text(
          'In Progress',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          WorkerSpacing.gutter,
          0,
          WorkerSpacing.gutter,
          WorkerSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ElapsedTimerCard(),
            const SizedBox(height: WorkerSpacing.md),
            JobDetailCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: WorkerColors.primaryFixed,
                    child: Text(
                      job.clientName.substring(0, 1),
                      style: WorkerTextStyles.titleMd.copyWith(
                        color: WorkerColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: WorkerSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.clientName, style: WorkerTextStyles.titleMd),
                        Text(
                          'Residential Client',
                          style: WorkerTextStyles.bodyMd,
                        ),
                      ],
                    ),
                  ),
                  ClientContactRow(
                    onMessage: () => _stub(context),
                    onCall: () => _stub(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.md),
            JobDetailCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'JOB LOCATION',
                    value: job.addressLabel,
                  ),
                  const Divider(height: WorkerSpacing.lg),
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: 'JOB DESCRIPTION',
                    value: job.description,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            GradientButton(
              label: 'Mark as Complete',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkerCompletionFormScreen(job: job),
                  ),
                );
              },
            ),
            const SizedBox(height: WorkerSpacing.md),
            TextButton.icon(
              onPressed: () => _stub(context),
              icon: const Icon(Icons.support_agent_outlined, size: 18),
              label: const Text('Need help? Call support'),
            ),
          ],
        ),
      ),
    );
  }

  void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support — integration later')),
    );
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
        Icon(icon, color: WorkerColors.primary, size: 20),
        const SizedBox(width: WorkerSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: WorkerTextStyles.labelCaps.copyWith(fontSize: 9)),
              const SizedBox(height: 4),
              Text(
                value,
                style: WorkerTextStyles.bodyMd.copyWith(
                  color: WorkerColors.onSurface,
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
