import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/errors/error_messages.dart';
import '../navigation/client_navigation.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rating_widget.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../../../core/services/reviews_service.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? artisan;

  const ArtisanProfileScreen({Key? key, this.artisan}) : super(key: key);

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  List<dynamic> _reviews = [];
  bool _isOpeningChat = false;

  Map<String, dynamic> get _artisan => Map<String, dynamic>.from(widget.artisan ?? const <String, dynamic>{});

  Map<String, dynamic> get _profile => Map<String, dynamic>.from(_artisan['profiles'] as Map<String, dynamic>? ?? const <String, dynamic>{});

  String get _name => (_artisan['name'] ?? _profile['full_name'] ?? 'Artisan').toString();

  String get _profession => (_artisan['profession'] ?? _profile['profession'] ?? 'Professional').toString();

  String get _imageUrl => (_artisan['imageUrl'] ?? _profile['avatar_url'] ?? '').toString();

  String get _location => (_artisan['location'] ?? _profile['location_label'] ?? 'Location not set').toString();

  String get _phone => (_artisan['phone'] ?? _profile['phone'] ?? '').toString();

  double get _rating => ((_artisan['rating'] as num?) ?? (_profile['rating'] as num?) ?? 0.0).toDouble();

  int get _reviewCount => ((_artisan['reviewCount'] as num?) ?? 0).toInt();

  String get _bio => (_artisan['bio'] ?? _profile['bio'] ?? 'Experienced professional with 10+ years in the industry. Specialized in residential and commercial projects. Committed to delivering high-quality work with excellent customer service.').toString();

  List<String> get _services {
    final dynamic rawServices = _artisan['services'] ?? _artisan['skills'] ?? _profile['skills'] ?? <String>['Repair', 'Installation', 'Maintenance', 'Consultation'];
    if (rawServices is List) {
      return rawServices.map((dynamic item) => item.toString()).toList();
    }
    return <String>[rawServices.toString()];
  }

  String get _workerId => (_artisan['id'] ?? _artisan['worker_id'] ?? _profile['id'] ?? _artisan['userId'] ?? '').toString();
  bool _isLoadingReviews = true;
  String? _reviewError;
  final ReviewsService _reviewsService = ReviewsService();

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final workerId = _workerId;
    if (workerId.isEmpty) {
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
            Container(
              width: double.infinity,
              height: 300,
              color: AppColors.surfaceContainer,
              child: ArtisanLogoPanel(
                imageUrl: _imageUrl,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),

            // Profile Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Profession
                  Text(
                    _name,
                    style: AppTypography.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _profession,
                    style: AppTypography.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Rating and Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingWidget(
                        rating: _rating,
                        reviewCount: _reviewCount,
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
                            _location,
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
                      _bio,
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
                    children: _services
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
	                                content: Text('Showing the latest reviews.'),
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
                    onTap: () => ClientNavigation.callPhone(
                      context,
                      _phone,
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
                    onTap: _isOpeningChat ? null : () async {
                      setState(() => _isOpeningChat = true);
                      await ClientNavigation.openChatForArtisan(
                        context,
                        _artisan,
                      );
                      if (mounted) setState(() => _isOpeningChat = false);
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
                Navigator.pushNamed(
                  context,
                  AppRoutes.directWorkerRequest,
                  arguments: _artisan,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
