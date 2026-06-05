import 'dart:async';

import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/availability_card.dart';
import '../widgets/request_job_card.dart';
import '../widgets/skeleton_box.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/error_state_view.dart';
import 'job_request_detail_screen.dart';
enum RequestsViewState { loading, loaded, empty, error }
class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});
  @override
  State<WorkerRequestsScreen> createState() => _WorkerRequestsScreenState();
}
class _WorkerRequestsScreenState extends State<WorkerRequestsScreen> {
  final WorkersService _workersService = WorkersService();
  RequestsViewState _viewState = RequestsViewState.loading;
  List<MockWorkerJob> _jobs = <MockWorkerJob>[];
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _viewState = RequestsViewState.loading;
        _errorMessage = null;
      });
    }
    try {
      final List<dynamic> data = await _workersService.getJobRequests();
      if (!mounted) return;
      setState(() {
        _jobs = data
            .map((dynamic item) =>
                workerJobFromApi(item as Map<String, dynamic>))
            .toList();
        _viewState = _jobs.isEmpty
            ? RequestsViewState.empty
            : RequestsViewState.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = userMessageFor(e, fallback: 'Failed to load requests.');
        _viewState = RequestsViewState.error;
      });
    }
  }
  void _openDetail(MockWorkerJob job) {
    final session = WorkerScope.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobRequestDetailScreen(
          job: job,
          onAcceptRequest: (accepted) {
            session.acceptJob(accepted);
            _load();
          },
          onAcceptResponse: (accepted) {
            session.acceptJobFromApi(accepted);
            _load();
          },
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Job Requests',
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(session),
      ),
    );
  }
  Widget _buildBody(WorkerSessionState session) {
    if (_viewState == RequestsViewState.loading) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        children: const <Widget>[
          SkeletonBox(height: 120),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 160),
        ],
      );
    }
    if (_viewState == RequestsViewState.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          ErrorStateView(
            message: _errorMessage!,
            title: 'Could not load requests',
            onRetry: _load,
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.md,
        AppSpacing.gutter,
        AppSpacing.gutter,
      ),
      children: <Widget>[
          AvailabilityCard(
          isAvailable: session.isAvailable,
          onChanged: (bool value) async {
            final bool ok = await session.setAvailable(value);
            if (ok && mounted) {
              await _load();
            }
            if (!ok && mounted) {
              AppToast.showError(
                context,
                Exception('Could not update availability.'),
                fallback: 'Could not update availability.',
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_viewState == RequestsViewState.empty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: <Widget>[
                Icon(
                  session.isAvailable
                      ? Icons.radar
                      : Icons.power_settings_new,
                  color: AppColors.onSurfaceVariant,
                  size: 36,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  session.isAvailable
                      ? 'No open requests right now.\nWe refresh this list automatically.'
                      : 'Go online to receive nearby job requests.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => _load(),
                  child: const Text('Refresh'),
                ),
              ],
              ),
            ),
        if (_viewState != RequestsViewState.empty)
          ..._jobs.map(
            (MockWorkerJob job) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RequestJobCard(
                job: job,
                onAccept: () => _openDetail(job),
                onTap: () => _openDetail(job),
              ),
            ),
          ),
      ],
    );
  }
}
