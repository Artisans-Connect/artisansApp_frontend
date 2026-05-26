import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class JobPostDescriptionScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const JobPostDescriptionScreen({
    Key? key,
    this.jobData,
  }) : super(key: key);

  @override
  State<JobPostDescriptionScreen> createState() =>
      _JobPostDescriptionScreenState();
}

class _JobPostDescriptionScreenState extends State<JobPostDescriptionScreen> {
  late TextEditingController _descriptionController;
  int _descriptionLength = 0;
  final int _maxDescriptionLength = 2000;
  final List<String> _uploadedPhotos = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.jobData?['description'] ?? '',
    );
    _descriptionLength = _descriptionController.text.length;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    // Simulate adding a photo
    if (_uploadedPhotos.length < 5) {
      setState(() {
        _uploadedPhotos.add('photo_${_uploadedPhotos.length}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'ConnectFlow',
        onBackPressed: () => Navigator.pop(context),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JOB SETUP',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXLarge),
                    ),
                    child: Text(
                      '4 / 7',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Title with Progress
              Text(
                'Details & Photos',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: LinearProgressIndicator(
                  value: 0.57,
                  minHeight: 6,
                  backgroundColor: AppColors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Job Description Section
              _buildDescriptionSection(),
              const SizedBox(height: AppSpacing.lg),

              // Add Photos Section
              _buildPhotoSection(),
              const SizedBox(height: AppSpacing.lg),

              // Pro Tip
              _buildProTipCard(),
              const SizedBox(height: AppSpacing.lg),

              // Promotional Card
              _buildPromotionalCard(),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Next',
                      icon: Icons.arrow_forward_ios,
                      mainAxisAlignment: MainAxisAlignment.center,
                      onPressed: () {
                        final jobData = widget.jobData ?? {};
                        jobData['description'] = _descriptionController.text;
                        jobData['photos'] = _uploadedPhotos;
                        Navigator.pushNamed(
                          context,
                          AppRoutes.jobPostLocation,
                          arguments: jobData,
                        );
                      },
                      isEnabled: _descriptionLength > 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Icon(
                    Icons.description,
                    color: AppColors.primary,
                    size: AppSpacing.iconMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Description',
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Describe the scope, requirements, and any specific\ntools needed for this task.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLength: _maxDescriptionLength,
              maxLines: 6,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText:
                    'Explain what needs to be done.\nFor example: \'I need a\nprofessional to install 4 smart\ndimmers in the living room and\ntroubleshoot a flickering light in\nthe kitchen...\'',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                counterText: '',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _descriptionLength = value.length;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_descriptionLength / $_maxDescriptionLength',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                _buildChip('Mention deadlines', Icons.schedule),
                _buildChip('Location access details', Icons.location_on),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.iconSmall,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: AppSpacing.iconMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Photos',
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Help experts understand the\ntask better by showing the\nworkspace or specific issues.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Photo upload slots
          ...[0, 1, 2].map((index) {
            final hasPhoto = index < _uploadedPhotos.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GestureDetector(
                onTap: _addPhoto,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                    color: hasPhoto
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Icon(
                      hasPhoto
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: hasPhoto
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      size: 32,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProTipCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb,
            color: AppColors.accentBlue,
            size: AppSpacing.iconMedium,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip: Take clear photos in good\nlighting. For repair jobs, include a\nwide shot and a close-up of the\nissue.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a3f),
            const Color(0xFF2d1b69),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Earnings',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '+\$1,240',
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
