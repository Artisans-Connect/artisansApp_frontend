import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/history_job_card.dart';
import '../widgets/segment_toggle.dart';
import 'worker_booking_detail_screen.dart';
import '../../../../shared/widgets/custom_back_button.dart';

class WorkerBookingHistoryScreen extends StatefulWidget {
  const WorkerBookingHistoryScreen({super.key});

  @override
  State<WorkerBookingHistoryScreen> createState() =>
      _WorkerBookingHistoryScreenState();
}

class _WorkerBookingHistoryScreenState
    extends State<WorkerBookingHistoryScreen> {
  final WorkersService _workersService = WorkersService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _loadError;
  bool _showCompleted = true;
  List<WorkerJob> _allJobs = <WorkerJob>[];

  int _limit = 10;
  int _offset = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadHistory(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreHistory();
    }
  }

  Future<void> _loadHistory({bool reset = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
      if (reset) {
        _offset = 0;
        _hasMore = true;
        _allJobs = <WorkerJob>[];
      }
    });
    try {
      final dynamic response = await _workersService.getHistory(
        limit: _limit,
        offset: _offset,
      );
      if (!mounted) return;
      final List<dynamic> data = response as List<dynamic>;
      final List<WorkerJob> newJobs = data
          .map((dynamic item) =>
              workerHistoryJobFromApi(item as Map<String, dynamic>))
          .toList();

      setState(() {
        if (reset) {
          _allJobs = newJobs;
        } else {
          _allJobs.addAll(newJobs);
        }
        _offset += _limit;
        if (newJobs.length < _limit) {
          _hasMore = false;
        }
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

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final dynamic response = await _workersService.getHistory(
        limit: _limit,
        offset: _offset,
      );
      if (!mounted) return;
      final List<dynamic> data = response as List<dynamic>;
      final List<WorkerJob> newJobs = data
          .map((dynamic item) =>
              workerHistoryJobFromApi(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _allJobs.addAll(newJobs);
        _offset += _limit;
        if (newJobs.length < _limit) {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<WorkerJob> get _filtered => _allJobs
      .where((WorkerJob j) => _showCompleted
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
        leading: CustomBackButton(
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
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Text(
              'CraftMatch',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: SegmentToggle(
              leftLabel: 'Completed',
              rightLabel: 'Cancelled',
              isLeftSelected: _showCompleted,
              onChanged: (bool v) {
                setState(() => _showCompleted = v);
                _loadHistory(reset: true);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                    ? ErrorStateView(
                        message: _loadError!,
                        title: 'Could not load history',
                        onRetry: () => _loadHistory(reset: true),
                      )
                    : _filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No history available',
                              style: AppTypography.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.gutter),
                            itemCount: _filtered.length +
                                (_isLoadingMore ? 1 : 0),
                            itemBuilder: (_, int i) {
                              if (i == _filtered.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return HistoryJobCard(
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
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
