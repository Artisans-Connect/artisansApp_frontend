import 'package:flutter/material.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _agreeToTerms = _draft.data['agreeToTerms'] as bool? ?? false;
  }

  void _showEditSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit section', style: AppTypography.displaySmall),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Service & type'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.popUntil(
                    context,
                    (Route<dynamic> r) =>
                        r.settings.name == AppRoutes.jobPostCategory,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: const Text('Title & description'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.popUntil(
                    context,
                    (Route<dynamic> r) =>
                        r.settings.name == AppRoutes.jobPostTitle,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location & budget'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.popUntil(
                    context,
                    (Route<dynamic> r) =>
                        r.settings.name == AppRoutes.jobPostLocation,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved locally')),
    );
    ClientNavigation.popToShell(context);
  }

  void _postJob() {
    if (!_agreeToTerms) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job posted — finding an artisan…')),
    );
    ClientNavigation.startFindingArtisan(context, jobData: _draft.toMap());
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
      primaryLabel: 'Post job',
      primaryEnabled: _agreeToTerms,
      onPrimary: _postJob,
      secondaryLabel: 'Save draft',
      onSecondary: _saveDraft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artisans — elite craftsmanship on demand',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SummaryCard(
            onEdit: _showEditSheet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_draft.displayTitle, style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _draft.displayDescription,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Chip(_draft.displayCategory),
                    if (_draft.displaySubcategory.isNotEmpty)
                      _Chip(_draft.displaySubcategory),
                    _Chip(_draft.displayLocation),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BUDGET (GHS)', style: AppTypography.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      ClientJobDraft.formatGhs(_draft.budgetMin),
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (_draft.budgetMin != _draft.budgetMax) ...[
                      Text('-', style: AppTypography.bodyLarge),
                      Text(
                        ClientJobDraft.formatGhs(_draft.budgetMax),
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    Text(
                      'estimated',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailLine('Urgency', _draft.displayUrgency),
                if (_draft.urgency == 'scheduled') ...[
                  _DetailLine('Date', dateStr),
                  _DetailLine('Time', _draft.timeWindow ?? '—'),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppColors.success),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to post on Artisans',
                        style: AppTypography.labelLarge,
                      ),
                      Text(
                        'Your request will be shared with matched artisans.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (bool? v) =>
                    setState(() => _agreeToTerms = v ?? false),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I agree to the Terms & Conditions and confirm this information is accurate.',
                    style: AppTypography.bodySmall.copyWith(
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.child, this.onEdit});

  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onEdit != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Job summary', style: AppTypography.labelLarge),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
              ],
            ),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
