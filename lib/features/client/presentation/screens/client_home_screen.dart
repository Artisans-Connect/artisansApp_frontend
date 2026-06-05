import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../client_shell.dart';
import '../models/client_booking_stub.dart';
import '../navigation/client_navigation.dart';
import '../navigation/client_shell_scope.dart';
import '../widgets/artisan_card.dart';
import '../widgets/category_chip.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../../../../core/services/jobs_service.dart';
import '../../services/explore_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String _selectedCategory = '';

  List<Map<String, dynamic>> featuredArtisans = [];
  bool _isLoadingFeatured = true;
  final JobsService _jobsService = JobsService();
  ClientBooking? _activeTrackableJob;
  bool _loadingActiveJob = true;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedArtisans();
    _loadActiveJob();
  }

  Future<void> _loadActiveJob() async {
    try {
      final List<dynamic> data = await _jobsService.getMyJobs();
      if (!mounted) return;
      setState(() {
        _activeTrackableJob = ClientBooking.pickActiveTrackable(
          data.cast<Map<String, dynamic>>(),
        );
        _loadingActiveJob = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingActiveJob = false);
    }
  }

  Future<void> _fetchFeaturedArtisans() async {
    try {
      final artisans = await ExploreService.instance.getArtisans(
        limit: 5,
        onRefreshed: (List<Map<String, dynamic>> fresh) {
          if (!mounted) return;
          setState(() {
            featuredArtisans = fresh;
            _isLoadingFeatured = false;
          });
        },
      );
      if (mounted) {
        setState(() {
          featuredArtisans = artisans;
          _isLoadingFeatured = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFeatured = false;
        });
      }
    }
  }

  final List<Map<String, dynamic>> categories = [
    {'label': 'Plumbing', 'icon': PhosphorIcons.drop},
    {'label': 'Electrical', 'icon': PhosphorIcons.lightning},
    {'label': 'Carpentry', 'icon': PhosphorIcons.wrench},
    {'label': 'Cleaning', 'icon': PhosphorIcons.broom},
    {'label': 'Painting', 'icon': PhosphorIcons.palette},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Good Morning',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Welcome back, Client',
                style: AppTypography.displaySmall,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: InkWell(
                  onTap: () =>
                      ClientNavigation.selectTab(context, ClientNavTab.messages),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLarge),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      PhosphorIcons.bell,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              CustomSearchBar(
                hintText: 'Search artisans or services...',
                onChanged: (value) {
                  // TODO: Implement search filtering
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Categories Section
              Text(
                'Categories',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category['label'];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: CategoryChip(
                        label: category['label'],
                        icon: category['icon'],
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = isSelected ? '' : category['label'];
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Featured Artisans Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Artisans',
                    style: AppTypography.displaySmall,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.exploreArtisans);
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
              if (!_isLoadingFeatured && featuredArtisans.isEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.users, color: AppColors.outlineVariant, size: 32),
                      const SizedBox(height: AppSpacing.sm),
                      Text('No featured artisans available right now', style: AppTypography.bodyMedium),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _isLoadingFeatured ? 3 : featuredArtisans.length,
                    itemBuilder: (context, index) {
                      if (_isLoadingFeatured) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: SizedBox(
                            width: 200,
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                        );
                      }
                      final artisan = featuredArtisans[index];
                      final profile = artisan['profiles'] as Map<String, dynamic>? ?? {};
                      final name = profile['full_name'] as String? ?? 'Artisan';
                      final imageUrl = profile['avatar_url'] as String? ?? 'https://via.placeholder.com/200?text=Artisan';
                      final skills = artisan['skills'] as List<dynamic>? ?? [];
                      final profession = skills.isNotEmpty ? skills.first.toString() : 'Professional';
                      final rating = (artisan['rating'] as num?)?.toDouble() ?? 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: SizedBox(
                          width: 200,
                          child: ArtisanCard(
                            name: name,
                            profession: profession,
                            rating: rating,
                            reviewCount: 0,
                            imageUrl: imageUrl,
                            location: 'Location not set',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.artisanProfile,
                                arguments: artisan,
                              );
                            },
                            onFavoriteTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to favorites'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.jobPostCategory);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              PhosphorIcons.plusCircle,
                              color: AppColors.onPrimary,
                              size: 32,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Post a Job',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.mapDiscovery);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              PhosphorIcons.mapTrifold,
                              color: AppColors.onSecondary,
                              size: 32,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Map View',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!_loadingActiveJob && _activeTrackableJob != null) ...[
                const SizedBox(height: AppSpacing.md),
                _ActiveJobBanner(
                  booking: _activeTrackableJob!,
                  onViewJob: () {
                    ClientShellScope.of(context)
                        .selectTab(ClientNavTab.bookings);
                  },
                  onTrack: () async {
                    ClientBooking booking = _activeTrackableJob!;
                    if (booking.jobUuid != null) {
                      try {
                        final dynamic job =
                            await _jobsService.getJobById(booking.jobUuid!);
                        if (job is Map<String, dynamic> && mounted) {
                          booking = ClientBooking.fromApiJob(job);
                        }
                      } catch (_) {}
                    }
                    if (!context.mounted) return;
                    unawaited(ClientNavigation.pushFlow(
                      context,
                      AppRoutes.liveTracking,
                      arguments: booking.toTrackingMap(),
                    ));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveJobBanner extends StatelessWidget {
  const _ActiveJobBanner({
    required this.booking,
    required this.onViewJob,
    required this.onTrack,
  });

  final ClientBooking booking;
  final VoidCallback onViewJob;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job in progress',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            booking.title,
            style: AppTypography.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'With ${booking.artisan}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewJob,
                  child: const Text('All bookings'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTrack,
                  child: const Text('Track live'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
