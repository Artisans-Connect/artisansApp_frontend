import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../widgets/job_post_wizard_scaffold.dart';

class JobPostDescriptionScreen extends StatefulWidget {
  const JobPostDescriptionScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostDescriptionScreen> createState() =>
      _JobPostDescriptionScreenState();
}

class _JobPostDescriptionScreenState extends State<JobPostDescriptionScreen> {
  late TextEditingController _descriptionController;
  late ClientJobDraft _draft;
  int _descriptionLength = 0;
  final int _maxDescriptionLength = 2000;
  final List<String> _uploadedPhotos = <String>[];

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _descriptionController =
        TextEditingController(text: _draft.description ?? '');
    _descriptionLength = _descriptionController.text.length;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    if (_uploadedPhotos.length < 5) {
      setState(() {
        _uploadedPhotos.add('photo_${_uploadedPhotos.length}');
      });
    }
  }

  void _continue() {
    _draft.merge(<String, dynamic>{
      'description': _descriptionController.text.trim(),
      'photos': List<String>.from(_uploadedPhotos),
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostLocation,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobPostWizardScaffold(
      step: JobPostWizardStep.description,
      headline: 'Describe the work',
      primaryLabel: 'Next',
      primaryEnabled: _descriptionLength >= 20,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Include scope, access details, and deadlines (min. 20 characters).',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            maxLength: _maxDescriptionLength,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'What should the artisan do?',
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            onChanged: (String v) => setState(() => _descriptionLength = v.length),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_descriptionLength / $_maxDescriptionLength',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Photos (optional)', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ..._uploadedPhotos.map(
                (_) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Icon(PhosphorIcons.image, color: AppColors.primary),
                ),
              ),
              InkWell(
                onTap: _addPhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Icon(PhosphorIcons.cameraPlus),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
