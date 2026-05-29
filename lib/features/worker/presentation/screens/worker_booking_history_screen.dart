import 'package:flutter/material.dart';

import '../../../../core/services/workers_service.dart';
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
  final WorkersService _workersService = WorkersService();
  bool _isLoading = true;
  bool _showCompleted = true;
  List<MockWorkerJob> _allJobs = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final dynamic response = await _workersService.getHistory();
      if (!mounted) return;
      final List<dynamic> data = response as List<dynamic>;
      setState(() {
        _allJobs = data.map((dynamic item) {
          final Map<String, dynamic> json = item as Map<String, dynamic>;
          return MockWorkerJob(
            id: json['id'] as String,
            title: json['title'] as String,
            category: json['category']?['name'] as String? ?? 'General',
            description: json['description'] as String? ?? '',
            addressLabel: json['location_address'] as String? ?? 'Unknown',
            latitude: 0.0,
            longitude: 0.0,
            clientName: json['profiles']?['full_name'] as String? ?? 'Client',
            urgency: JobUrgency.scheduled,
            estimatedBudgetLabel: '${json['budget_min']} - ${json['budget_max']} GHS',
            distanceKm: null,
            historyDate: json['completed_at'] != null ? json['completed_at'].toString().split('T')[0] : 'Just now',
            historyStatus: json['status'] == 'COMPLETED' ? HistoryStatus.completed : HistoryStatus.cancelled,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load history: $e')),
      );
    }
  }

  List<MockWorkerJob> get _filtered => _allJobs
      .where((MockWorkerJob j) =>
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
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No history available',
                          style: WorkerTextStyles.bodyLg,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: WorkerSpacing.gutter),
                        itemCount: _filtered.length,
                        itemBuilder: (_, int i) => HistoryJobCard(job: _filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
