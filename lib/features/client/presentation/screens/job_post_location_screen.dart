import 'package:flutter/material.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../widgets/job_post_wizard_scaffold.dart';

class JobPostLocationScreen extends StatefulWidget {
  const JobPostLocationScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostLocationScreen> createState() => _JobPostLocationScreenState();
}

class _JobPostLocationScreenState extends State<JobPostLocationScreen> {
  late ClientJobDraft _draft;
  late TextEditingController _addressController;
  bool _showAddressEditor = false;

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _addressController = TextEditingController(
      text: _draft.address ?? '123 Osu St, Accra, Ghana',
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _continue() {
    _draft.merge(<String, dynamic>{
      'address': _addressController.text.trim(),
      'locationLat': 5.6037,
      'locationLng': -0.1870,
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostUrgency,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobPostWizardScaffold(
      step: JobPostWizardStep.location,
      headline: 'Where is the job?',
      primaryLabel: 'Next',
      primaryEnabled: _addressController.text.trim().isNotEmpty,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artisans use this to estimate travel time and availability.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 48, color: AppColors.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Map preview (UI stub)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _showAddressEditor
                      ? 'Edit address'
                      : _addressController.text,
                  style: AppTypography.labelLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    setState(() => _showAddressEditor = !_showAddressEditor),
              ),
            ],
          ),
          if (_showAddressEditor) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }
}
