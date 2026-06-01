import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
class WorkerDesignReferenceScreen extends StatelessWidget {
  const WorkerDesignReferenceScreen({super.key});
  static const _assets = [
    ('40_worker_requests.png', 'Requests'),
    ('41_worker_job_detail.png', 'Job detail'),
    ('42_worker_active_pre_start.png', 'Active pre-start'),
    ('43_worker_active_in_progress.png', 'Active in-progress'),
    ('44_worker_completion_form.png', 'Completion form'),
    ('45_worker_completion_success.png', 'Completion success'),
    ('60_worker_active_empty.png', 'Active empty'),
    ('61_worker_earnings.png', 'Earnings'),
    ('62_worker_stats.png', 'Stats'),
    ('63_worker_booking_history.png', 'Booking history'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Design reference', style: AppTypography.titleMd),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        itemCount: _assets.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) {
          final (file, label) = _assets[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: AppTypography.titleMd),
              Text(file, style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'Artisans_Organized_ui/worker/$file',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}