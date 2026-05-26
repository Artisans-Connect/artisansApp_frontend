import 'package:flutter/material.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

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
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        title: Text('Design reference', style: WorkerTextStyles.titleMd),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(WorkerSpacing.gutter),
        itemCount: _assets.length,
        separatorBuilder: (_, __) => const SizedBox(height: WorkerSpacing.lg),
        itemBuilder: (context, index) {
          final (file, label) = _assets[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: WorkerTextStyles.titleMd),
              Text(file, style: WorkerTextStyles.bodyMd),
              const SizedBox(height: WorkerSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
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
