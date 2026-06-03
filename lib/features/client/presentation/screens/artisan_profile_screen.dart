import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/errors/error_messages.dart';
import '../models/client_job_draft.dart';
import '../navigation/client_navigation.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rating_widget.dart';
import '../../../../core/services/reviews_service.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? artisan;

  const ArtisanProfileScreen({Key? key, this.artisan}) : super(key: key);

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  bool _isFavorite = false;
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = true;
  String? _reviewError;
  final ReviewsService _reviewsService = ReviewsService();

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final workerId = widget.artisan?['id'] ?? widget.artisan?['worker_id'];
    if (workerId == null) {
      setState(() => _isLoadingReviews = false);
      return;
    }
    
    try {
      final reviews = await _reviewsService.getWorkerReviews(workerId);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _reviewError = userMessageFor(e, fallback: 'Could not load reviews.');
        _isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final artisan = widget.artisan ?? {
      'name': 'John Smith',
      'profession': 'Professional Plumber',
      'rating': 4.8,
      'reviewCount': 342,
      'imageUrl': 'https://via.placeholder.com/400?text=John',
      'location': 'Downtown Area',
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Profile',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  color: AppColors.surfaceContainer,
                  child: Image.network(
                    artisan['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceContainer,
                        child: Icon(
                          PhosphorIcons.user,
                          size: 100,
                          color: AppColors.outlineVariant,
                        ),
                      );
                    },
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _isFavorite ? PhosphorIcons.heart : PhosphorIcons.heart,
                        color: _isFavorite ? Colors.red : AppColors.outlineVariant,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Profile Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Profession
                  Text(
                    artisan['name'],
                    style: AppTypography.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    artisan['profession'],
                    style: AppTypography.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Rating and Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingWidget(
                        rating: artisan['rating'],
                        reviewCount: artisan['reviewCount'],
                      ),
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.mapPin,
                            size: 16,
                            color: AppColors.outlineVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            artisan['location'],
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // About Section
                  Text(
                    'About',
                    style: AppTypography.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    ),
                    child: Text(
                      'Experienced professional with 10+ years in the industry. Specialized in residential and commercial projects. Committed to delivering high-quality work with excellent customer service.',
                      style: AppTypography.bodyMedium,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Services Section
                  Text(
                    'Services',
                    style: AppTypography.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: ['Repair', 'Installation', 'Maintenance', 'Consultation']
                        .map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Text(
                          service,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style: AppTypography.displaySmall,
                      ),
                      if (!_isLoadingReviews && _reviews.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Full reviews list (UI stub).'),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Review Cards
                  if (_isLoadingReviews)
                    const Center(child: CircularProgressIndicator())
                  else if (_reviewError != null)
                    Text(_reviewError!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                        ))
                  else if (_reviews.isEmpty)
                    Text('No reviews yet.', style: AppTypography.bodyMedium)
                  else
                    ..._reviews.map((review) {
                      final reviewerName = review['profiles']?['full_name'] ?? 'Client';
                      final rating = review['rating'] as int? ?? 0;
                      final comment = review['comment'] as String? ?? 'No comment provided.';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    reviewerName,
                                    style: AppTypography.labelLarge,
                                  ),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < rating ? PhosphorIcons.star : PhosphorIcons.star,
                                        size: 14,
                                        color: const Color(0xFFFFC107),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                comment,
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => ClientNavigation.showCallPlaceholder(
                      context,
                      '+233 24 000 0000',
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLarge),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLarge),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.phone,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Call',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ClientNavigation.openChat(
                        context,
                        conversationId: 'conv-artisan',
                        counterpartUserId: 'worker-${artisan['name']}',
                        counterpartName: artisan['name'] as String,
                        jobTitle: artisan['profession'] as String?,
                      );
                    },
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLarge),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLarge),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.chatTeardrop,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Chat',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Book Now',
              onPressed: () {
                final draft = ClientJobDraft.fromMap(<String, dynamic>{
                  'category': artisan['profession'],
                  'title': 'Service with ${artisan['name']}',
                });
                ClientNavigation.startFindingArtisan(
                  context,
                  jobData: draft.toMap(),
                  artisan: artisan,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
