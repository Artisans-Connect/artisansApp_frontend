import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../client_shell.dart';
import '../navigation/client_navigation.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/services/reviews_service.dart';
import '../../../../shared/widgets/app_toast.dart';

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
    final service = widget.service ?? {
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
                    final jobId = widget.service?['id'] ?? widget.service?['jobId'];
                    final workerId = widget.service?['workerId'] ?? widget.service?['worker_id'];
                    
                    if (jobId != null && workerId != null) {
                      await _reviewsService.createReview({
                        'job_id': jobId,
                        'worker_id': workerId,
                        'rating': _rating.toInt(),
                        'comment': _reviewController.text.trim(),
                      });
                    }
                    
                    if (!mounted) return;
                    AppToast.showSuccess(context, 'Rating submitted successfully!');

                    ClientNavigation.popToShellAndSelectTab(
                      context,
                      ClientNavTab.bookings,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    AppToast.showError(context, e, fallback: 'Could not submit rating.');
                    setState(() => _isSubmitting = false);
                  }
                },
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
              child: Image.network(
                service['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    color: AppColors.onPrimary,
                  );
                },
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
                  service['artisan'] ?? 'Artisan Name',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  service['profession'] ?? 'Professional',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  service['title'] ?? 'Service Title',
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
                    index < _rating ? Icons.star_rounded : Icons.star_outline,
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
                Icons.info_outline,
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
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          )
        else
          Icon(
            Icons.circle_outlined,
            color: AppColors.outlineVariant,
            size: 20,
          ),
      ],
    );
  }
}
