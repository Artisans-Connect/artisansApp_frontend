import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../navigation/client_navigation.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/services/reviews_service.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../trust_safety/presentation/widgets/report_submission_bottom_sheet.dart';

class RateServiceScreen extends StatefulWidget {
  final Map<String, dynamic>? service;

  const RateServiceScreen({
    Key? key,
    this.service,
  }) : super(key: key);

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  double _rating = 0;
  late TextEditingController _reviewController;
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;
  final ReviewsService _reviewsService = ReviewsService();

  final List<String> reviewTags = [
    'Professional',
    'On Time',
    'Skilled',
    'Friendly',
    'Clean',
    'Affordable',
  ];

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> service = widget.service ?? <String, dynamic>{
      'artisan': 'John Smith',
      'profession': 'Professional Plumber',
      'title': 'Fix leaking kitchen faucet',
      'imageUrl': 'https://via.placeholder.com/200?text=John',
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Rate Service',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Info Card
              _buildServiceInfoCard(service),
              const SizedBox(height: AppSpacing.lg),

              // Rating Section
              _buildRatingSection(),
              const SizedBox(height: AppSpacing.lg),

              // Quality Tags
              _buildQualityTagsSection(),
              const SizedBox(height: AppSpacing.lg),

              // Review Input
              _buildReviewInputSection(),
              const SizedBox(height: AppSpacing.lg),

              // Completion Steps
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Column(
                  children: [
                    _buildStepIndicator(1, 'Rate Service', true),
                    const SizedBox(height: AppSpacing.md),
                    _buildStepIndicator(2, 'View in History', false),
                    const SizedBox(height: AppSpacing.md),
                    _buildStepIndicator(3, 'Artisan Review', false),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit Button
              PrimaryButton(
                label: _isSubmitting ? 'Submitting...' : 'Submit Rating & Complete →',
                isEnabled: _rating > 0 && !_isSubmitting,
                onPressed: () async {
                  setState(() => _isSubmitting = true);
                  try {
                    final String jobId = _stringValue(
                      widget.service?['job_id'] ??
                          widget.service?['jobId'] ??
                          widget.service?['id'],
                    );
                    final String workerId = _stringValue(
                      widget.service?['workerId'] ??
                          widget.service?['worker_id'] ??
                          widget.service?['counterpartUserId'],
                    );
                    
                    if (jobId.isEmpty || workerId.isEmpty) {
                      throw Exception('This booking is missing review details.');
                    }

                    final String comment = [
                      _reviewController.text.trim(),
                      if (_selectedTags.isNotEmpty)
                        'Highlights: ${_selectedTags.join(', ')}',
                    ].where((part) => part.isNotEmpty).join('\n\n');

                    await _reviewsService.createReview({
                      'job_id': jobId,
                      'worker_id': workerId,
                      'rating': _rating.toInt(),
                      if (comment.isNotEmpty) 'comment': comment,
                    });
                    
                    if (!mounted) return;
                    AppToast.showSuccess(context, 'Thank you for your review!');
                    ClientNavigation.goToBookingHistory(context);
                  } catch (e) {
                    if (!mounted) return;
                    AppToast.showError(context, e, fallback: 'Could not submit review.');
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Report a Problem Link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    final String? jobId = widget.service?['job_id'] as String? ??
                        widget.service?['jobId'] as String? ??
                        widget.service?['id'] as String?;
                    final String? workerId = widget.service?['worker_id'] as String? ??
                        widget.service?['workerId'] as String?;
                    final String? workerName = widget.service?['artisan'] as String? ??
                        widget.service?['worker_name'] as String?;

                    ReportSubmissionBottomSheet.show(
                      context,
                      bookingId: jobId,
                      reportedId: workerId,
                      reportedName: workerName,
                    );
                  },
                  icon: const Icon(PhosphorIcons.warningCircle, color: AppColors.error, size: 18),
                  label: Text(
                    'Report a Problem / Safety Concern',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Rating Details
              _buildRatingInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard(Map<String, dynamic> service) {
    final String imageUrl = _stringValue(service['imageUrl']);
    final bool hasNetworkImage = imageUrl.startsWith('http');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: hasNetworkImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          PhosphorIcons.user,
                          color: AppColors.onPrimary,
                        );
                      },
                    )
                  : Icon(
                      PhosphorIcons.user,
                      color: AppColors.onPrimary,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stringValue(service['artisan'], fallback: 'Artisan Name'),
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _stringValue(service['profession'], fallback: 'Professional'),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _stringValue(service['title'], fallback: 'Service Title'),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stringValue(Object? value, {String fallback = ''}) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How was your experience?',
          style: AppTypography.displaySmall,
        ),
        const SizedBox(height: AppSpacing.md),

        // Star Rating
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = (index + 1).toDouble();
                    });
                  },
                  child: Icon(
                    index < _rating ? PhosphorIcons.star : PhosphorIcons.star,
                    size: 48,
                    color: index < _rating
                        ? const Color(0xFFFFC107)
                        : AppColors.outlineVariant,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Rating Text
        if (_rating > 0)
          Center(
            child: Column(
              children: [
                Text(
                  _getRatingText(_rating.toInt()),
                  style: AppTypography.labelLarge.copyWith(
                    color: _getRatingColor(_rating.toInt()),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_rating.toInt()} out of 5',
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

  Widget _buildQualityTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What went well? (Optional)',
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: reviewTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              backgroundColor: AppColors.surfaceContainerLow,
              selectedColor: AppColors.primaryContainer,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a comment (Optional)',
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: AppColors.outlineVariant,
            ),
          ),
          child: TextField(
            controller: _reviewController,
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience with this artisan...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              counterText: '',
              hintStyle: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            style: AppTypography.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.info,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Ratings Help Others',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your honest feedback helps other clients find trusted artisans and helps artisans improve their service quality.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return 'Excellent!';
      case 4:
        return 'Very Good';
      case 3:
        return 'Good';
      case 2:
        return 'Okay';
      case 1:
        return 'Poor';
      default:
        return 'Select a rating';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
      case 4:
        return AppColors.success;
      case 3:
        return AppColors.primary;
      case 2:
      case 1:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildStepIndicator(int stepNumber, String stepName, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: AppTypography.labelMedium.copyWith(
                color: isCompleted ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            stepName,
            style: AppTypography.bodyMedium.copyWith(
              color: isCompleted ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ),
        if (isCompleted)
          Icon(
            PhosphorIcons.checkCircle,
            color: AppColors.success,
            size: 20,
          )
        else
          Icon(
            PhosphorIcons.circle,
            color: AppColors.outlineVariant,
            size: 20,
          ),
      ],
    );
  }
}
