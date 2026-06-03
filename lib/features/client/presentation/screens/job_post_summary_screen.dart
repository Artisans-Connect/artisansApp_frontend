import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/offline/job_post_queue.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../navigation/client_navigation.dart';
import '../widgets/job_post_wizard_scaffold.dart';

class JobPostSummaryScreen extends StatefulWidget {
  const JobPostSummaryScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostSummaryScreen> createState() => _JobPostSummaryScreenState();
}

class _JobPostSummaryScreenState extends State<JobPostSummaryScreen> {
  late ClientJobDraft _draft;
  bool _agreeToTerms = false;
  bool _isPosting = false;
  final JobsService _jobsService = JobsService();

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
  }

  void _saveDraft() {
    AppToast.showInfo(context, 'Draft saved locally');
    ClientNavigation.popToShell(context);
  }

  Future<void> _postJob() async {
    if (!_agreeToTerms || _isPosting) return;

    setState(() => _isPosting = true);

    final payload = _draft.toCreateJobPayload();
    final idempotencyKey = const Uuid().v4();

    try {
      final dynamic created = await _jobsService.createJob(
        payload,
        idempotencyKey: idempotencyKey,
      );
      final Map<String, dynamic> jobData = _draft.toMap();
      if (created is Map<String, dynamic>) {
        jobData['id'] = created['id'];
        jobData['status'] = created['status'];
      }

      if (!mounted) return;
      AppToast.showSuccess(context, 'Job posted — finding an artisan…');
      ClientNavigation.startFindingArtisan(context, jobData: jobData);
    } catch (e) {
      if (!mounted) return;
      final bool offline = e is NetworkException;
      if (offline) {
        await JobPostQueue.instance.enqueue(payload);
        if (!mounted) return;
        AppToast.showInfo(
          context,
          'You are offline. Job queued and will post when connection returns.',
        );
        ClientNavigation.popToShell(context);
      } else {
        AppToast.showError(context, e, fallback: 'Failed to post job. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr = _draft.preferredDate != null
        ? '${_draft.preferredDate!.day}/${_draft.preferredDate!.month}/${_draft.preferredDate!.year}'
        : '—';

    return JobPostWizardScaffold(
      step: JobPostWizardStep.summary,
      appBarTitle: 'Review & Post',
      headline: 'Review your job post',
      primaryLabel: _isPosting ? 'Posting…' : 'Post job',
      primaryEnabled: _agreeToTerms && !_isPosting,
      onPrimary: _postJob,
      secondaryLabel: 'Save draft',
      onSecondary: _saveDraft,
      showDiscardOnBack: _draft.hasAnyData,
      onDiscard: () => ClientNavigation.popToShell(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SummaryRow(label: 'Category', value: _draft.displayCategory),
          _SummaryRow(
            label: 'Subcategory',
            value: _draft.displaySubcategory.isEmpty
                ? '—'
                : _draft.displaySubcategory,
          ),
          _SummaryRow(label: 'Title', value: _draft.displayTitle),
          _SummaryRow(label: 'Description', value: _draft.displayDescription),
          _SummaryRow(label: 'Location', value: _draft.displayLocation),
          _SummaryRow(label: 'Urgency', value: _draft.displayUrgency),
          _SummaryRow(label: 'Preferred date', value: dateStr),
          _SummaryRow(
            label: 'Budget',
            value:
                '${ClientJobDraft.formatGhs(_draft.budgetMin)} – ${ClientJobDraft.formatGhs(_draft.budgetMax)}',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: _agreeToTerms,
                onChanged: (bool? v) =>
                    setState(() => _agreeToTerms = v ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I agree to the platform terms and understand artisans may contact me about this job.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodyLarge),
        ],
      ),
    );
  }
}
