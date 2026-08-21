import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/custom_app_bar.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/core/services/reviews_service.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_gradient_button.dart';

/// Screen for workers to rate a client after a completed job.
///
/// Accepts [jobId], [clientId], and [clientName] so it can be launched
/// from the completion success popup *or* from booking history detail.
class RateClientScreen extends StatefulWidget {
  const RateClientScreen({
    super.key,
    required this.jobId,
    required this.clientId,
    required this.clientName,
    this.clientAvatarUrl,
    this.jobTitle,
    this.onReviewSubmitted,
  });

  final String jobId;
  final String clientId;
  final String clientName;
  final String? clientAvatarUrl;
  final String? jobTitle;

  /// Called after a review is successfully submitted so callers can
  /// refresh their UI (e.g. hide the "Rate Client" button).
  final VoidCallback? onReviewSubmitted;

  @override
  State<RateClientScreen> createState() => _RateClientScreenState();
}

class _RateClientScreenState extends State<RateClientScreen> {
  double _rating = 0;
  late TextEditingController _commentController;
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;
  final ReviewsService _reviewsService = ReviewsService();

  static const List<String> _reviewTags = [
    'Clear instructions',
    'Respectful',
    'Paid promptly',
    'Good communication',
    'Fair expectations',
    'Welcoming',
  ];

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _rating == 0) return;
    setState(() => _isSubmitting = true);
    try {
      final String comment = [
        _commentController.text.trim(),
        if (_selectedTags.isNotEmpty)
          'Highlights: ${_selectedTags.join(', ')}',
      ].where((part) => part.isNotEmpty).join('\n\n');

      await _reviewsService.createClientReview({
        'job_id': widget.jobId,
        'rating': _rating.toInt(),
        if (comment.isNotEmpty) 'comment': comment,
      });

      if (!mounted) return;
      AppToast.showSuccess(context, 'Thank you for rating ${widget.clientName}!');
      widget.onReviewSubmitted?.call();
      Navigator.of(context).pop(true); // return true = review submitted
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not submit review.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Rate Client',
        onBackPressed: () => Navigator.pop(context, false),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client info card
              _buildClientInfoCard(),
              const SizedBox(height: AppSpacing.lg),

              // Star rating
              _buildRatingSection(),
              const SizedBox(height: AppSpacing.lg),

              // Quality tags
              _buildQualityTagsSection(),
              const SizedBox(height: AppSpacing.lg),

              // Comment
              _buildCommentSection(),
              const SizedBox(height: AppSpacing.lg),

              // Submit
              WorkerGradientButton(
                label: _isSubmitting ? 'Submitting...' : 'Submit Rating',
                isLoading: _isSubmitting,
                onPressed: _rating > 0 ? _submit : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Skip
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Skip for now',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Info card
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    final bool hasAvatar =
        widget.clientAvatarUrl != null && widget.clientAvatarUrl!.startsWith('http');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: hasAvatar
                  ? Image.network(
                      widget.clientAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        PhosphorIcons.user,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Icon(
                      PhosphorIcons.user,
                      color: AppColors.onPrimary,
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clientName,
                  style: AppTypography.labelLarge,
                ),
                if (widget.jobTitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.jobTitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
          'How was this client?',
          style: AppTypography.displaySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _rating = (index + 1).toDouble()),
                  child: Icon(
                    PhosphorIcons.star,
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
        const SizedBox(height: AppSpacing.md),
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
          children: _reviewTags.map((tag) {
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
                color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
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
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: TextField(
            controller: _commentController,
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience working with this client...',
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

  Widget _buildInfoCard() {
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
                'Your Feedback Matters',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Rating clients helps other artisans know what to expect and encourages respectful, fair interactions on CraftMatch.',
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
}
