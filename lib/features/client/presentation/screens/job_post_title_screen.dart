import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../widgets/job_post_wizard_scaffold.dart';

class JobPostTitleScreen extends StatefulWidget {
  const JobPostTitleScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostTitleScreen> createState() => _JobPostTitleScreenState();
}

class _JobPostTitleScreenState extends State<JobPostTitleScreen> {
  late TextEditingController _titleController;
  late ClientJobDraft _draft;
  int _titleLength = 0;
  final int _maxTitleLength = 80;

  List<String> get _suggestions {
    final String cat = _draft.displayCategory;
    return <String>[
      '$cat repair at my home',
      'Urgent $cat fix needed',
      'Scheduled $cat service',
    ];
  }

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _titleController = TextEditingController(text: _draft.title ?? '');
    _titleLength = _titleController.text.length;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _continue() {
    _draft.merge(<String, dynamic>{'title': _titleController.text.trim()});
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostDescription,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobPostWizardScaffold(
      step: JobPostWizardStep.title,
      headline: 'Give your job a clear title',
      primaryLabel: 'Next',
      primaryEnabled: _titleLength >= 3,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artisans see this first — be specific about what you need.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$_titleLength / $_maxTitleLength',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          TextField(
            controller: _titleController,
            maxLength: _maxTitleLength,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'e.g. Fix leaking kitchen faucet',
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              counterText: '',
            ),
            onChanged: (String value) =>
                setState(() => _titleLength = value.length),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Suggestions', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _suggestions.map((String s) {
              return ActionChip(
                label: Text(s, style: AppTypography.bodySmall),
                onPressed: () {
                  _titleController.text = s;
                  setState(() => _titleLength = s.length);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _TipRow(
            icon: PhosphorIcons.checkCircle(),
            color: AppColors.success,
            title: 'Good',
            example: 'Repair oak dining table leg',
          ),
          const SizedBox(height: AppSpacing.sm),
          _TipRow(
            icon: PhosphorIcons.xCircle(),
            color: AppColors.error,
            title: 'Avoid',
            example: 'URGENT HELP NEEDED!!!',
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.example,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String example;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelMedium),
              Text(
                example,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
