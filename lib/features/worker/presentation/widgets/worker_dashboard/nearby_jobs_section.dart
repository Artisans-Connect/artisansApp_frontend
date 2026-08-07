import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/widgets/job_requests_map.dart';
import '../../models/worker_job.dart';
import '../worker_request_card.dart';
import 'availability_card.dart';

class NearbyJobsSection extends StatelessWidget {
  const NearbyJobsSection({
    super.key,
    required this.isOnline,
    required this.isSearching,
    required this.jobs,
    required this.selectedJobId,
    required this.lastCheckedAt,
    required this.onGoOnline,
    required this.onStartMatching,
    required this.onSelectJob,
    required this.onOpenJob,
    required this.onViewDetails,
    required this.onAccept,
  });

  final bool isOnline;
  final bool isSearching;
  final List<WorkerJob> jobs;
  final String? selectedJobId;
  final DateTime? lastCheckedAt;
  final VoidCallback onGoOnline;
  final VoidCallback onStartMatching;
  final ValueChanged<String> onSelectJob;
  final ValueChanged<WorkerJob> onOpenJob;
  final ValueChanged<WorkerJob> onViewDetails;
  final ValueChanged<WorkerJob> onAccept;

  String get _checkedLabel {
    if (lastCheckedAt == null) return '';
    final Duration age = DateTime.now().difference(lastCheckedAt!);
    if (age.inSeconds < 5) return 'Just now';
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    return '${age.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Expanded(
              child: Text(
                'Nearby Requests',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ),
            if (jobs.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${jobs.length} active',
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: DesignTokens.sm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildState(context),
        ),
      ],
    );
  }

  Widget _buildState(BuildContext context) {
    if (!isOnline) {
      return MinimalisticStatusCard(
        key: const ValueKey('offline'),
        title: 'Offline',
        subtitle: 'Turn on availability to receive nearby job requests.',
        isOnline: false,
        isLoading: false,
        actionLabel: 'Go online',
        onAction: onGoOnline,
      );
    }

    if (jobs.isNotEmpty) {
      final String selectedId = selectedJobId ?? jobs.first.id;
      return Column(
        key: const ValueKey('has_jobs'),
        children: <Widget>[
          JobRequestsMapPreview(
            jobs: jobs,
            selectedJobId: selectedId,
            onSelectJob: onSelectJob,
            onOpenJob: onOpenJob,
            height: 145,
          ),
          const SizedBox(height: DesignTokens.md),
          ...jobs.map(
            (WorkerJob job) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.md),
              child: RequestJobCard(
                job: job,
                isSelected: job.id == selectedId,
                onTap: () => onSelectJob(job.id),
                onAccept: () => onAccept(job),
                onViewDetails: () => onViewDetails(job),
              ),
            ),
          ),
        ],
      );
    }

    if (isSearching) {
      return const MinimalisticStatusCard(
        key: ValueKey('searching'),
        title: 'Searching nearby...',
        subtitle: 'Checking for client requests close to your location.',
        isOnline: true,
        isLoading: true,
      );
    }

    return MinimalisticStatusCard(
      key: const ValueKey('empty'),
      title: 'Listening for requests',
      subtitle: _checkedLabel.isNotEmpty
          ? 'Last checked: $_checkedLabel'
          : 'No active requests nearby right now.',
      isOnline: true,
      isLoading: false,
      actionLabel: 'Refresh',
      onAction: onStartMatching,
    );
  }
}

class MinimalisticStatusCard extends StatelessWidget {
  const MinimalisticStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isOnline,
    required this.isLoading,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final bool isOnline;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Row(
        children: <Widget>[
          PulseDot(online: isOnline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: DesignTokens.primary,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
