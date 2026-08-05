import '../../../../core/theme/design_tokens.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/navigation/app_routes.dart';
import '../models/client_booking.dart';
import '../navigation/client_navigation.dart';
import '../navigation/client_shell_scope.dart';
import '../client_shell.dart';
import '../widgets/artisan_card.dart';
import '../widgets/client_home/home_hero.dart';
import '../widgets/client_home/home_atoms.dart';
import '../widgets/client_home/active_job_banner.dart';
import '../widgets/client_home/artisan_list_states.dart';
import '../widgets/client_home/marquee_categories.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/session/app_user_session.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../services/explore_service.dart';
import '../../../../core/services/smart_search_service.dart';
import '../../../../shared/utils/greeting_utils.dart';

const Map<String, List<String>> _categoryAliases = <String, List<String>>{
  'construction_building': <String>['builder', 'building', 'mason', 'carpenter', 'tiler', 'painter', 'steel bender', 'welder', 'fabricator', 'ceiling', 'glass', 'roofer', 'paver', 'construction'],
  'electrical_power': <String>['electrician', 'wiring', 'lighting', 'generator', 'inverter', 'solar', 'cctv', 'security', 'appliance', 'fan', 'iron'],
  'plumbing_water': <String>['plumber', 'pipe', 'leak', 'borehole', 'pump', 'drainage', 'sanitary', 'sink', 'toilet', 'shower', 'water'],
  'auto_mechanical': <String>['mechanic', 'car', 'vehicle', 'vulcanizer', 'sprayer', 'body', 'motorcycle', 'heavy equipment', 'engine', 'tyre'],
  'home_repairs': <String>['handyman', 'furniture', 'door', 'window', 'pest', 'cleaner', 'gardener', 'cleaning', 'repairs', 'maintenance'],
  'beauty_fashion': <String>['hairdresser', 'barber', 'makeup', 'tailor', 'dressmaker', 'shoemaker', 'cobbler', 'bead', 'milliner', 'braids', 'styling', 'sewing'],
  'electronics_it': <String>['phone', 'laptop', 'tv', 'sound', 'printer', 'computer', 'screen', 'electronics', 'it', 'network', 'wifi'],
  'hospitality_events': <String>['caterer', 'baker', 'decorator', 'photographer', 'videographer', 'dj', 'canopy', 'chair', 'catering', 'event', 'cake'],
  'arts_crafts': <String>['potter', 'weaver', 'wood carver', 'drum', 'goldsmith', 'jeweller', 'brass smith', 'signwriter', 'kente', 'pottery', 'craft'],
};



 
// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key, this.refreshSignal = 0}) : super(key: key);

  final int refreshSignal;
 
  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}
 
class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String _selectedCategory   = '';
  String _selectedCategoryId = '';
  String _searchQuery        = '';
  bool _isParsingIntent      = false;
 
  List<Map<String, dynamic>> _featuredArtisans = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _categories       = <Map<String, dynamic>>[];
  Map<String, int> _categoryWorkerCounts       = <String, int>{};
  bool _isLoadingFeatured    = true;
  bool _isLoadingCategories  = true;
  ClientBooking? _activeJob;
  bool _loadingActiveJob     = true;
  int _unreadNotifications   = 0;
 
  final JobsService        _jobsService        = JobsService();
  final CategoriesService  _categoriesService  = CategoriesService();
  final NotificationService _notificationService = NotificationService.instance;
 
  // ── Greeting ───────────────────────────────────────────────────────────────
  String get _greeting => GreetingUtils.getGreeting(capitalizeWords: true);
 
  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _fetchFeaturedArtisans();
    _loadActiveJob();
    _loadUnreadNotifications();
  }

  @override
  void didUpdateWidget(covariant ClientHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshSignal != oldWidget.refreshSignal) {
      unawaited(_refreshHome());
    }
  }

  Future<void> _refreshHome() async {
    await Future.wait<void>([
      _loadCategories(),
      _fetchFeaturedArtisans(),
      _loadActiveJob(),
      _loadUnreadNotifications(),
    ]);
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final int count = await _notificationService.getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadNotifications = count);
    } catch (_) {
      if (!mounted) return;
      setState(() => _unreadNotifications = 0);
    }
  }
 
  Future<void> _loadCategories() async {
    try {
      final List<dynamic> data = await _categoriesService.listCategories();
      if (!mounted) return;
      setState(() {
        _categories = data
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> e) =>
                Map<String, dynamic>.from(e))
            .toList();
        _isLoadingCategories = false;
      });
      _loadCategoryWorkerCounts();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories        = <Map<String, dynamic>>[];
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadCategoryWorkerCounts() async {
    try {
      final List<Map<String, dynamic>> workers =
          await ExploreService.instance.getArtisans(
        limit: 50,
        forceRefresh: true,
      );
      if (!mounted) return;
      setState(() {
        _categoryWorkerCounts = <String, int>{
          for (final Map<String, dynamic> category in _categories)
            _categoryKey(category): workers
                .where((Map<String, dynamic> worker) =>
                    _workerMatchesCategory(worker, category))
                .length,
        };
      });
    } catch (_) {
      if (mounted) setState(() => _categoryWorkerCounts = <String, int>{});
    }
  }
 
  Future<void> _loadActiveJob() async {
    try {
      final List<dynamic> data = await _jobsService.getMyJobs(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _activeJob = ClientBooking.pickActiveTrackable(
            data.cast<Map<String, dynamic>>());
        _loadingActiveJob = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingActiveJob = false);
    }
  }
 
  Future<void> _fetchFeaturedArtisans() async {
    if (!mounted) return;
    setState(() => _isLoadingFeatured = true);
    try {
      final List<Map<String, dynamic>> artisans =
          await ExploreService.instance.getArtisans(
        categoryId: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
        limit: 5,
        onRefreshed: (List<Map<String, dynamic>> fresh) {
          if (!mounted) return;
          setState(() {
            _featuredArtisans    = fresh;
            _isLoadingFeatured   = false;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _featuredArtisans  = artisans;
        _isLoadingFeatured = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingFeatured = false);
    }
  }
 
  // ── Static fallbacks ───────────────────────────────────────────────────────
  IconData _categoryIcon(Map<String, dynamic> category) {
    final Object? icon = category['icon'];
    if (icon is IconData) return icon;
    return PhosphorIconMapper.fromString(category['icon_name']?.toString());
  }

  String _categoryKey(Map<String, dynamic> category) {
    return (category['slug'] ?? category['id'] ?? category['name'] ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s-]+'), '_');
  }

  int _categorySortOrder(Map<String, dynamic> category) {
    return (category['sort_order'] as num?)?.toInt() ?? 999;
  }

  List<Map<String, dynamic>> get _categoriesByWorkerCount {
    final List<Map<String, dynamic>> sorted =
        List<Map<String, dynamic>>.from(_categories);
    sorted.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      final int countDelta = (_categoryWorkerCounts[_categoryKey(b)] ?? 0)
          .compareTo(_categoryWorkerCounts[_categoryKey(a)] ?? 0);
      if (countDelta != 0) return countDelta;

      final int orderDelta =
          _categorySortOrder(a).compareTo(_categorySortOrder(b));
      if (orderDelta != 0) return orderDelta;

      return (a['name'] ?? '')
          .toString()
          .compareTo((b['name'] ?? '').toString());
    });
    return sorted;
  }

  bool _workerMatchesCategory(
    Map<String, dynamic> worker,
    Map<String, dynamic> category,
  ) {
    final List<String> skills =
        (worker['skills'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic skill) => skill.toString().toLowerCase().trim())
            .where((String skill) => skill.isNotEmpty)
            .toList();
    if (skills.isEmpty) return false;

    final List<String> categoryTerms = _categoryWorkerTerms(category);

    return skills.any(
      (String skill) => categoryTerms.any(
        (String term) => skill.contains(term) || term.contains(skill),
      ),
    );
  }

  List<String> _categoryWorkerTerms(Map<String, dynamic> category) {
    final String key = _categoryKey(category);
    final Set<String> terms = <String>{
      category['slug']?.toString() ?? '',
      category['name']?.toString() ?? '',
      category['id']?.toString() ?? '',
      ...?_categoryAliases[key],
    };
    return terms
        .map((String term) => term.toLowerCase().replaceAll('_', ' ').trim())
        .where((String term) => term.isNotEmpty)
        .toList();
  }
  List<Map<String, dynamic>> get _visibleArtisans => _featuredArtisans;

  Future<void> _handleSearchSubmitted() async {
    final String query = _searchQuery.trim();
    if (query.isEmpty) return;

    setState(() => _isParsingIntent = true);
    try {
      final SmartSearchIntent intent =
          await SmartSearchService.instance.parseIntent(query);
      if (mounted) {
        setState(() => _isParsingIntent = false);
        await Navigator.pushNamed(
          context,
          AppRoutes.exploreArtisans,
          arguments: <String, dynamic>{
            'query': intent.refinedQuery,
            'categoryIds': intent.categoryIds,
            'categories': intent.categoryNames,
            'intentSummary': intent.intentSummary.isNotEmpty
                ? intent.intentSummary
                : null,
          },
        );
        if (mounted) {
          setState(() => _searchQuery = '');
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isParsingIntent = false);
        await Navigator.pushNamed(
          context,
          AppRoutes.exploreArtisans,
          arguments: <String, dynamic>{
            'query': query,
            if (_selectedCategory.isNotEmpty) 'category': _selectedCategory,
            if (_selectedCategoryId.isNotEmpty)
              'categoryId': _selectedCategoryId,
          },
        );
        if (mounted) {
          setState(() => _searchQuery = '');
        }
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverToBoxAdapter(child: _buildAppBar()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.gutter, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                  // Hero with Embedded Search
                  AnimatedBuilder(
                    animation: AppUserSession.instance,
                    builder: (BuildContext context, Widget? child) {
                      final String fullName =
                          AppUserSession.instance.currentUser?.fullName ?? '';
                      final String firstName =
                          fullName.trim().split(' ').first;
                      final String name = firstName.isNotEmpty
                          ? 'Welcome, $firstName 🙃'
                          : 'Welcome back 🙃';
                      return HomeHero(
                        greeting: _greeting,
                        name: name,
                        searchQuery: _searchQuery,
                        isParsingIntent: _isParsingIntent,
                        onSearchChanged: (String v) =>
                            setState(() => _searchQuery = v),
                        onSearchSubmitted: _handleSearchSubmitted,
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Active job banner
                  if (!_loadingActiveJob && _activeJob != null) ...<Widget>[
                    ActiveJobBanner(
                      booking: _activeJob!,
                      onViewJob: () => ClientShellScope.of(context)
                          .selectTab(ClientNavTab.bookings),
                      onTrack: () => _trackJob(_activeJob!),
                    ),
                    const SizedBox(height: 18),
                  ],
                  const SizedBox(height: 6),
 
                  // Quick actions
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Post a Job',
                          subtitle: 'Get matched instantly',
                          gradientColors: const <Color>[
                            DesignTokens.primary,
                            DesignTokens.primaryDark,
                          ],
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.jobPostCategory),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.map_rounded,
                          label: 'Map View',
                          subtitle: 'Artisans near you',
                          gradientColors: const <Color>[
                            DesignTokens.accentGold,
                            DesignTokens.accentWarm,
                          ],
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.mapDiscovery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
 
                  // Categories
                  const SectionHeader(title: 'Categories'),
                  const SizedBox(height: 14),
                  _buildCategories(),
                  const SizedBox(height: 26),
 
                  // Featured artisans
                  SectionHeader(
                    title: 'Featured Artisans',
                    actionLabel: 'View All',
                    onAction: () => Navigator.pushNamed(
                      context,
                      AppRoutes.exploreArtisans,
                      arguments: <String, dynamic>{
                        if (_searchQuery.trim().isNotEmpty) 'query': _searchQuery.trim(),
                        if (_selectedCategory.isNotEmpty)
                          'category': _selectedCategory,
                        if (_selectedCategoryId.isNotEmpty)
                          'categoryId': _selectedCategoryId,
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildArtisanList(),
                  const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  // ── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.gutter, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Wordmark
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[DesignTokens.primary, DesignTokens.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'CraftMatch',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          // Notification bell
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, AppRoutes.notifications);
              if (mounted) unawaited(_loadUnreadNotifications());
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: DesignTokens.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: DesignTokens.borderSubtle),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                      color: DesignTokens.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const Icon(Icons.notifications_outlined,
                      color: DesignTokens.textPrimary, size: 20),
                  if (_unreadNotifications > 0)
                    Positioned(
                      top: 5,
                      right: 4,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: DesignTokens.primary,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: DesignTokens.surfaceCard, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _unreadNotifications > 9
                              ? '9+'
                              : _unreadNotifications.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Categories ─────────────────────────────────────────────────────────────
  Widget _buildCategories() {
    final List<Map<String, dynamic>> cats =
        _isLoadingCategories ? <Map<String, dynamic>>[] : _categoriesByWorkerCount;

    if (_isLoadingCategories) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (cats.isEmpty) {
      return const Text(
        'Categories are unavailable right now.',
        style: TextStyle(color: DesignTokens.textSecondary),
      );
    }

    return MarqueeCategoriesList(
      categories: cats,
      selectedCategoryId: _selectedCategoryId,
      selectedCategory: _selectedCategory,
      categoryIcon: _categoryIcon,
      onCategorySelected: (String catId, String label) {
        setState(() {
          final bool selected = catId.isNotEmpty
              ? _selectedCategoryId == catId
              : _selectedCategory == label;
          _selectedCategory   = selected ? '' : label;
          _selectedCategoryId = selected ? '' : catId;
        });
        _fetchFeaturedArtisans();
      },
      onSeeMore: () => Navigator.pushNamed(
        context,
        AppRoutes.exploreArtisans,
        arguments: <String, dynamic>{
          if (_searchQuery.trim().isNotEmpty)
            'query': _searchQuery.trim(),
        },
      ),
    );
  }
 
  // ── Artisan list ───────────────────────────────────────────────────────────
  Widget _buildArtisanList() {
    if (_isLoadingFeatured) return const SkeletonRow();
 
    if (_visibleArtisans.isEmpty) return const EmptyArtisans();
 
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _visibleArtisans.length,
        itemBuilder: (BuildContext context, int i) {
          final Map<String, dynamic> artisan = _visibleArtisans[i];
          final Map<String, dynamic> profile =
              artisan['profiles'] as Map<String, dynamic>? ??
                  const <String, dynamic>{};
          final String name =
              (profile['full_name'] as String?) ?? 'Artisan';
          final String imageUrl =
              (profile['avatar_url'] as String?) ?? '';
          final List<dynamic> skills =
              artisan['skills'] as List<dynamic>? ?? <dynamic>[];
          final String profession =
              skills.isNotEmpty ? skills.first.toString() : 'Professional';
          final double rating =
              (artisan['rating'] as num?)?.toDouble() ?? 0.0;
 
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: SizedBox(
              width: 190,
              child: ArtisanCard(
                name: name,
                profession: profession,
                rating: rating,
                reviewCount: 0,
                imageUrl: imageUrl,
                location: (profile['location_label'] ?? 'Location not set')
                    .toString(),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.artisanProfile,
                  arguments: artisan,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
 
  // ── Track job helper ───────────────────────────────────────────────────────
  Future<void> _trackJob(ClientBooking booking) async {
    ClientBooking b = booking;
    if (b.jobUuid != null) {
      try {
        final dynamic job = await _jobsService.getJobById(b.jobUuid!);
        if (job is Map<String, dynamic> && mounted) {
          b = ClientBooking.fromApiJob(job);
        }
      } catch (_) {}
    }
    if (!context.mounted) return;
    unawaited(ClientNavigation.pushFlow(
      context,
      AppRoutes.liveTracking,
      arguments: b.toTrackingMap(),
    ));
  }
}
