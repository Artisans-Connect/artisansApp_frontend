import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../core/services/reviews_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../client/presentation/widgets/artisan_profile/review_components.dart';
import '../../../client/presentation/widgets/artisan_profile/profile_atoms.dart';

class WorkerReviewsScreen extends StatefulWidget {
  const WorkerReviewsScreen({super.key});

  @override
  State<WorkerReviewsScreen> createState() => _WorkerReviewsScreenState();
}

class _WorkerReviewsScreenState extends State<WorkerReviewsScreen> {
  final ReviewsService _reviewsService = ReviewsService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final String? uid = CurrentUser.id;
    if (uid == null || uid.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'User not authenticated.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<dynamic> reviews = await _reviewsService.getWorkerReviews(uid);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load reviews. Please try again.';
        });
      }
    }
  }

  double get _rating {
    if (_reviews.isEmpty) return 0.0;
    double sum = 0.0;
    for (final dynamic r in _reviews) {
      sum += ((r as Map<String, dynamic>)['rating'] as num?)?.toDouble() ?? 0.0;
    }
    return sum / _reviews.length;
  }

  List<double> get _ratingFractions {
    if (_reviews.isEmpty) return List<double>.filled(5, 0);
    final List<int> counts = List<int>.filled(5, 0);
    for (final dynamic r in _reviews) {
      final int stars = ((r as Map<String, dynamic>)['rating'] as int?) ?? 0;
      if (stars >= 1 && stars <= 5) counts[5 - stars]++;
    }
    final int total = _reviews.length;
    return counts.map((int c) => c / total).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> fractions = _ratingFractions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Customer Reviews',
        showBackButton: Navigator.of(context).canPop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: AppTypography.bodyMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchReviews,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchReviews,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_reviews.isEmpty) ...[
                          const SizedBox(height: 48),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: DesignTokens.warmTint,
                              shape: BoxShape.circle,
                              border: Border.all(color: DesignTokens.warmBorder, width: 1.5),
                            ),
                            child: const Icon(
                              PhosphorIcons.chatTeardrop,
                              color: DesignTokens.warmBorder,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No reviews yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Reviews from completed jobs will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 13,
                                color: DesignTokens.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Rating summary card
                          Container(
                            padding: const EdgeInsets.all(DesignTokens.md),
                            margin: const EdgeInsets.only(bottom: DesignTokens.lg),
                            decoration: BoxDecoration(
                              color: DesignTokens.surfaceCard,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                              border: Border.all(color: DesignTokens.borderSubtle),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // Big number
                                Column(
                                  children: <Widget>[
                                    Text(
                                      _rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: DesignTokens.textPrimary,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    StarRow(rating: _rating.round(), size: 13),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_reviews.length} reviews',
                                      style: const TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 11,
                                        color: DesignTokens.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: DesignTokens.lg),
                                // Bar breakdown
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      for (int i = 0; i < 5; i++) ...<Widget>[
                                        RatingBarRow(
                                          star: 5 - i,
                                          fraction: fractions[i],
                                        ),
                                        if (i < 4) const SizedBox(height: 5),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Reviews list
                          ..._reviews.map((dynamic review) => ReviewCard(
                                review: review as Map<String, dynamic>,
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
