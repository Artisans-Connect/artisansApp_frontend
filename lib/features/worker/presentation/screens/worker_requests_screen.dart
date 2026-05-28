import 'package:flutter/material.dart';
import '../models/mock_worker_data.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
import '../widgets/availability_card.dart';
import '../widgets/request_job_card.dart';
import '../widgets/skeleton_box.dart';
import 'job_request_detail_screen.dart';

enum RequestsViewState { loading, loaded, empty }

class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});

  @override
  State<WorkerRequestsScreen> createState() => _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState extends State<WorkerRequestsScreen> {
  RequestsViewState _viewState = RequestsViewState.loading;
  List<MockWorkerJob> _jobs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _viewState = RequestsViewState.loading);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _jobs = List.from(MockWorkerData.incomingJobs);
      _viewState =
          _jobs.isEmpty ? RequestsViewState.empty : RequestsViewState.loaded;
    });
  }

  void _openDetail(MockWorkerJob job) {
    final session = WorkerScope.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobRequestDetailScreen(
          job: job,
          onAcceptRequest: session.acceptJob,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);

    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        title: Text(
          'Job Requests',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: WorkerColors.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request filters coming soon'),
                ),
              );
            },
          ),
        ],
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
        padding: const EdgeInsets.all(WorkerSpacing.gutter),
        children: const [
          SkeletonBox(height: 80, borderRadius: 20),
          SizedBox(height: 16),
          SkeletonBox(height: 180, borderRadius: 20),
        ],
      );
    }

    if (_viewState == RequestsViewState.empty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(WorkerSpacing.gutter),
            child: AvailabilityCard(
              isAvailable: session.isAvailable,
              onChanged: session.setAvailable,
            ),
          ),
          const SizedBox(height: 80),
          Center(
            child: Text(
              'No open requests right now',
              style: WorkerTextStyles.titleMd,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        WorkerSpacing.gutter,
        0,
        WorkerSpacing.gutter,
        WorkerSpacing.xl,
      ),
      itemCount: _jobs.length + 1,
      separatorBuilder: (_, i) =>
          SizedBox(height: i == 0 ? WorkerSpacing.md : 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return AvailabilityCard(
            isAvailable: session.isAvailable,
            onChanged: session.setAvailable,
          );
        }
        final job = _jobs[index - 1];
        return RequestJobCard(
          job: job,
          onTap: () => _openDetail(job),
          onAccept: () => _openDetail(job),
          isAcceptEnabled: session.isAvailable,
        );
      },
    );
  }
}
