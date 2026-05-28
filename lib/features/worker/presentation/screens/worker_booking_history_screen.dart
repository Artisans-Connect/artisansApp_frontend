import 'package:flutter/material.dart';
import '../models/mock_worker_data.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
import '../widgets/history_job_card.dart';
import '../widgets/segment_toggle.dart';

class WorkerBookingHistoryScreen extends StatefulWidget {
  const WorkerBookingHistoryScreen({super.key});

  @override
  State<WorkerBookingHistoryScreen> createState() =>
      _WorkerBookingHistoryScreenState();
}

class _WorkerBookingHistoryScreenState extends State<WorkerBookingHistoryScreen> {
  bool _showCompleted = true;

  List<MockWorkerJob> get _filtered => MockWorkerData.historyJobs
      .where((j) =>
          _showCompleted
              ? j.historyStatus == HistoryStatus.completed
              : j.historyStatus == HistoryStatus.cancelled)
      .toList();

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
              return;
            }
            WorkerScope.of(context).setProfilePage(WorkerProfilePage.earnings);
          },
        ),
        title: Text(
          'History',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.onSurface),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: WorkerSpacing.md),
            child: Text(
              'Artisans',
              style: WorkerTextStyles.titleMd.copyWith(
                color: WorkerColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(WorkerSpacing.gutter),
            child: SegmentToggle(
              leftLabel: 'Completed',
              rightLabel: 'Cancelled',
              isLeftSelected: _showCompleted,
              onChanged: (v) => setState(() => _showCompleted = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: WorkerSpacing.gutter),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => HistoryJobCard(job: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}
