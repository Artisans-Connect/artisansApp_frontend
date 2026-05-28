import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';

class JobPostDescriptionScreen extends StatefulWidget {
  const JobPostDescriptionScreen({Key? key, required jobData}) : super(key: key);

  @override
  State<JobPostDescriptionScreen> createState() => _JobPostDescriptionScreenState();
}

class _JobPostDescriptionScreenState extends State<JobPostDescriptionScreen> {
  late TextEditingController _descriptionController;
  int _descCharCount = 0;
  final int _descMaxChars = 2000;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _descriptionController.addListener(() {
      setState(() {
        _descCharCount = _descriptionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ConnectFlow',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Label
              Text(
                'JOB SETUP',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Details & Photos',
                    style: AppTypography.displayLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    '4 / 7',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: 0.57,
                minHeight: 6,
                backgroundColor: AppColors.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Job Description Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Description',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Describe the scope, requirements, and any specific tools needed for this task.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Description TextField
                    TextField(
                      controller: _descriptionController,
                      maxLines: 6,
                      maxLength: _descMaxChars,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Explain what needs to be done. For example: \'I need a professional to install 4 smart dimmers in the living room and troubleshoot a flickering light in the kitchen...\'',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceContainer,
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                        counterText: '',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            '$_descCharCount / $_descMaxChars',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Chips
                    Wrap(
                      spacing: AppSpacing.md,
                      children: [
                        Chip(
                          label: Text(
                            'Mention deadlines',
                            style: AppTypography.bodySmall,
                          ),
                          avatar: Icon(
                            Icons.schedule,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          backgroundColor: AppColors.surfaceContainer,
                          side: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Location access details',
                            style: AppTypography.bodySmall,
                          ),
                          avatar: Icon(
                            Icons.location_on,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          backgroundColor: AppColors.surfaceContainer,
                          side: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Add Photos Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Photos',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Help experts understand the task better by showing the workspace or specific issues.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Photo Upload Buttons
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.image,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Main View',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Secondary Photo Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Pro Tip
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Pro Tip: Take clear photos in good lighting. For repair jobs, include a wide shot and a close-up of the issue.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Info Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                  image: DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/400x200'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Earnings',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '+\$1,240',
                          style: AppTypography.displaySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Back',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.jobPostLocation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
