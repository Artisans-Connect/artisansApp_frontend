import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/worker_job.dart';
import '../widgets/job_detail_card.dart';

class WorkerPendingApprovalScreen extends StatelessWidget {
  const WorkerPendingApprovalScreen({super.key, required this.job});

  final WorkerJob job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Awaiting Approval',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.md,
          AppSpacing.gutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        PhosphorIcons.clockCountdown,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          job.title,
                          style: AppTypography.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Your completion report has been sent to ${job.clientName}. You can take another job after the client approves or reopens this booking.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('CLIENT', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.xs),
                  Text(job.clientName, style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text('LOCATION', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.xs),
                  Text(job.addressLabel, style: AppTypography.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
