import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/history_job_card.dart';
import '../widgets/segment_toggle.dart';
import 'worker_booking_detail_screen.dart';
class WorkerBookingHistoryScreen extends StatefulWidget {
  const WorkerBookingHistoryScreen({super.key});
  @override
  State<WorkerBookingHistoryScreen> createState() =>
      _WorkerBookingHistoryScreenState();
}
class _WorkerBookingHistoryScreenState extends State<WorkerBookingHistoryScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isLoading = true;
  String? _loadError;
  bool _showCompleted = true;
  List<WorkerJob> _allJobs = [];
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final dynamic response = await _workersService.getHistory();
      if (!mounted) return;
      final List<dynamic> data = response as List<dynamic>;
      setState(() {
        _allJobs = data
            .map((dynamic item) =>
                workerHistoryJobFromApi(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = userMessageFor(e, fallback: 'Failed to load history.');
      });
    }
  }
  List<WorkerJob> get _filtered => _allJobs
      .where((WorkerJob j) =>
          _showCompleted
              ? j.historyStatus == HistoryStatus.completed
              : j.historyStatus == HistoryStatus.cancelled)
      .toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft, size: 20),
          color: AppColors.primary,
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
          style: AppTypography.titleLarge.copyWith(color: AppColors.onSurface),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Text(
              'ArtisansConnect',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
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
                : _loadError != null
                    ? ErrorStateView(
                        message: _loadError!,
                        title: 'Could not load history',
                        onRetry: _loadHistory,
                      )
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No history available',
                          style: AppTypography.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                        itemCount: _filtered.length,
                        itemBuilder: (_, int i) => HistoryJobCard(
                          job: _filtered[i],
                          onViewDetails: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => WorkerBookingDetailScreen(
                                  job: _filtered[i],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
