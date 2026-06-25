import '../../../../core/theme/design_tokens.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/navigation/app_routes.dart';
import '../models/client_booking.dart';
import '../navigation/client_navigation.dart';
import '../navigation/client_shell_scope.dart';
import '../client_shell.dart';
import '../widgets/artisan_card.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/session/app_user_session.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../services/explore_service.dart';
import '../../../../core/services/smart_search_service.dart';

const Map<String, List<String>> _categoryAliases = <String, List<String>>{
  'plumbing': <String>['plumber', 'pipe', 'drainage', 'septic'],
  'electrical': <String>['electrician', 'wiring', 'lighting', 'generator'],
  'carpentry': <String>['carpenter', 'woodwork', 'furniture', 'cabinet'],
  'masonry': <String>['mason', 'blockwork', 'plastering', 'concrete'],
  'welding': <String>['welder', 'fabrication', 'metalwork', 'blacksmith'],
  'construction': <String>['builder', 'building', 'renovation'],
  'automotive': <String>['mechanic', 'car', 'motorbike', 'auto body'],
  'painting': <String>['painter', 'paint'],
  'tiling': <String>['tiler', 'tiles', 'flooring', 'terrazzo'],
  'roofing': <String>['roofer', 'roof', 'ceiling'],
  'hvac': <String>['ac', 'air conditioning', 'refrigeration', 'fridge'],
  'appliance_repair': <String>[
    'appliance',
    'electronics',
    'tv',
    'washing machine',
  ],
  'cleaning': <String>['cleaner', 'deep clean', 'fumigation'],
  'landscaping': <String>['lawn', 'garden', 'weeding'],
  'fashion': <String>['tailor', 'dressmaker', 'sewing', 'seamstress'],
  'beauty': <String>['hairdresser', 'barber', 'makeup', 'nails'],
  'catering': <String>['caterer', 'cook', 'baking', 'baker'],
  'upholstery': <String>['sofa', 'cushion', 'curtains', 'blinds'],
  'security': <String>['locksmith', 'cctv', 'access control'],
  'ict_support': <String>['computer', 'phone repair', 'network', 'wifi'],
};


BoxDecoration _card({
  Color color = DesignTokens.surfaceCard,
  double radius = DesignTokens.radiusXl,
  bool shadow = true,
}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: DesignTokens.borderSubtle),
      boxShadow: shadow
          ? const <BoxShadow>[
              BoxShadow(
                  color: DesignTokens.shadowDeep, blurRadius: 20, offset: Offset(0, 6)),
              BoxShadow(
                  color: DesignTokens.shadow, blurRadius: 4, offset: Offset(0, 2)),
            ]
          : null,
    );
 
// ─────────────────────────────────────────────────────────────────────────────
// _HomeHero — greeting banner, single floating icon, clean gradient
// ─────────────────────────────────────────────────────────────────────────────
class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.greeting, required this.name});
  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[DesignTokens.primary, DesignTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: const Text(
                    'What do you need fixed today?',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.handyman_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// _CategoryChip — solid fill on select (no gradient)
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.primary : DesignTokens.surfaceCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isSelected ? DesignTokens.primary : DesignTokens.borderSubtle,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isSelected
                  ? DesignTokens.primary.withValues(alpha: 0.22)
                  : DesignTokens.shadow,
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : DesignTokens.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// _QuickActionCard — gradient card, no decorative circles
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: DesignTokens.textSecondary)),
          ],
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader — left accent bar + title + optional action pill
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 3,
              height: 16,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: DesignTokens.primary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: DesignTokens.primaryTint08,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// _ActiveJobBanner — job in progress card, left accent strip via Row
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveJobBanner extends StatefulWidget {
  const _ActiveJobBanner({
    required this.booking,
    required this.onViewJob,
    required this.onTrack,
  });

  final ClientBooking booking;
  final VoidCallback onViewJob;
  final VoidCallback onTrack;

  @override
  State<_ActiveJobBanner> createState() => _ActiveJobBannerState();
}

class _ActiveJobBannerState extends State<_ActiveJobBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(color: DesignTokens.primary.withValues(alpha: 0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: DesignTokens.successGreen.withValues(
                      alpha: 0.5 + _pulse.value * 0.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'JOB IN PROGRESS',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.primary,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.booking.title,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: <Widget>[
              const Icon(Icons.person_rounded,
                  size: 12, color: DesignTokens.textSecondary),
              const SizedBox(width: 4),
              Text(
                'With ${widget.booking.artisan}',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onViewJob,
                  child: const Text('All bookings'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onTrack,
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
 
// ─────────────────────────────────────────────────────────────────────────────
// _ArtisanSkeleton — single opacity pulse, no per-card AnimationController
// ─────────────────────────────────────────────────────────────────────────────
class _ArtisanSkeleton extends StatelessWidget {
  const _ArtisanSkeleton({required this.opacity});
  final double opacity;
 
  @override
  Widget build(BuildContext context) {
    final Color base =
        Color.lerp(const Color(0xFFF0EBE5), const Color(0xFFFFF0E6), opacity)!;
    return Container(
      width: 190,
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: base,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignTokens.radiusXl)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _bar(110, 12, base),
                const SizedBox(height: 7),
                _bar(75, 10, base),
                const SizedBox(height: 10),
                _bar(90, 10, base),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _bar(double width, double height, Color color) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      );
}
 
class _SkeletonRow extends StatefulWidget {
  @override
  State<_SkeletonRow> createState() => _SkeletonRowState();
}
 
class _SkeletonRowState extends State<_SkeletonRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
 
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _ArtisanSkeleton(opacity: _anim.value),
          ),
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// _EmptyArtisans
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyArtisans extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: _card(
          color: const Color(0xFFFAF5F0), shadow: false),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.people_outline_rounded,
              size: 34,
              color: DesignTokens.textSecondary.withValues(alpha: 0.35)),
          const SizedBox(height: 10),
          Text(
            'No artisans match your search',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);
 
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
 
  final JobsService        _jobsService        = JobsService();
  final CategoriesService  _categoriesService  = CategoriesService();
 
  // ── Greeting ───────────────────────────────────────────────────────────────
  String get _greeting {
    final int h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
 
  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _fetchFeaturedArtisans();
    _loadActiveJob();
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
      final List<dynamic> data = await _jobsService.getMyJobs();
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
 
  // ── Filtered artisans ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _visibleArtisans {
    return _featuredArtisans.where((Map<String, dynamic> a) {
      final Map<String, dynamic> profile = Map<String, dynamic>.from(
          a['profiles'] as Map<String, dynamic>? ?? const <String, dynamic>{});
      final List<dynamic> skills =
          a['skills'] as List<dynamic>? ?? <dynamic>[];
      final String haystack = <String>[
        (profile['full_name'] ?? a['name'] ?? '').toString(),
        ...skills.map((dynamic s) => s.toString()),
      ].join(' ').toLowerCase();
 
      final String trimmedQuery = _searchQuery.trim();
      if (trimmedQuery.isNotEmpty &&
          !haystack.contains(trimmedQuery.toLowerCase())) return false;
      return true;
    }).toList();
  }
 
  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildAppBar()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.gutter, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  // Hero
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
                      return _HomeHero(greeting: _greeting, name: name);
                    },
                  ),
                  const SizedBox(height: 18),
 
                  // Active job banner
                  if (!_loadingActiveJob && _activeJob != null) ...<Widget>[
                    _ActiveJobBanner(
                      booking: _activeJob!,
                      onViewJob: () => ClientShellScope.of(context)
                          .selectTab(ClientNavTab.bookings),
                      onTrack: () => _trackJob(_activeJob!),
                    ),
                    const SizedBox(height: 18),
                  ],
 
                  // Search
                  CustomSearchBar(
                    hintText: 'Search artisans or services...',
                    isLoading: _isParsingIntent,
                    onChanged: (String v) => setState(() => _searchQuery = v),
                    onSearch: () async {
                      final String query = _searchQuery.trim();
                      if (query.isEmpty) return;

                      setState(() => _isParsingIntent = true);
                      try {
                        final SmartSearchIntent intent =
                            await SmartSearchService.instance.parseIntent(query);
                        if (mounted) {
                          setState(() => _isParsingIntent = false);
                          Navigator.pushNamed(
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
                        }
                      } catch (_) {
                        if (mounted) {
                          setState(() => _isParsingIntent = false);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.exploreArtisans,
                            arguments: <String, dynamic>{
                              'query': query,
                              if (_selectedCategory.isNotEmpty)
                                'category': _selectedCategory,
                              if (_selectedCategoryId.isNotEmpty)
                                'categoryId': _selectedCategoryId,
                            },
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
 
                  // Quick actions
                  const _SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _QuickActionCard(
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
                        child: _QuickActionCard(
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
                  const _SectionHeader(title: 'Categories'),
                  const SizedBox(height: 14),
                  _buildCategories(),
                  const SizedBox(height: 26),
 
                  // Featured artisans
                  _SectionHeader(
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: DesignTokens.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: DesignTokens.surfaceCard, width: 1.5),
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

    return _MarqueeCategoriesList(
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
    if (_isLoadingFeatured) return _SkeletonRow();
 
    if (_visibleArtisans.isEmpty) return _EmptyArtisans();
 
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

// ─────────────────────────────────────────────────────────────────────────────
// _MarqueeCategoriesList — horizontal marquee scrolling category bar
// ─────────────────────────────────────────────────────────────────────────────
class _MarqueeCategoriesList extends StatefulWidget {
  const _MarqueeCategoriesList({
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedCategory,
    required this.categoryIcon,
    required this.onCategorySelected,
    required this.onSeeMore,
  });

  final List<Map<String, dynamic>> categories;
  final String selectedCategoryId;
  final String selectedCategory;
  final IconData Function(Map<String, dynamic>) categoryIcon;
  final Function(String id, String label) onCategorySelected;
  final VoidCallback onSeeMore;

  @override
  State<_MarqueeCategoriesList> createState() => _MarqueeCategoriesListState();
}

class _MarqueeCategoriesListState extends State<_MarqueeCategoriesList>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  bool _isManualScrolling = false;
  Timer? _manualScrollResumeTimer;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Start with a large offset so scrolling both ways is infinite
    _scrollController = ScrollController(initialScrollOffset: 2000.0);
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _manualScrollResumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _shouldAnimate {
    final bool hasSelection =
        widget.selectedCategoryId.isNotEmpty || widget.selectedCategory.isNotEmpty;
    return !hasSelection && !_isManualScrolling;
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final double deltaSeconds = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (_shouldAnimate && _scrollController.hasClients) {
      // Smooth movement at 50 logical pixels per second
      final double scrollSpeed = 50.0 * deltaSeconds;
      final double newOffset = _scrollController.offset + scrollSpeed;
      _scrollController.jumpTo(newOffset);
    }
  }

  void _onUserScrollStart() {
    if (!_isManualScrolling) {
      setState(() {
        _isManualScrolling = true;
      });
    }
    _manualScrollResumeTimer?.cancel();
  }

  void _onUserScrollEnd() {
    _manualScrollResumeTimer?.cancel();
    _manualScrollResumeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isManualScrolling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cats = widget.categories;
    final int totalItems = cats.length + 1; // +1 for "See more"

    return SizedBox(
      height: 46,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            _onUserScrollStart();
          } else if (notification is ScrollEndNotification) {
            _onUserScrollEnd();
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final int actualIndex = (index % totalItems + totalItems) % totalItems;

            if (actualIndex == cats.length) {
              // Build "See more" chip
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _CategoryChip(
                  label: 'See more',
                  icon: Icons.arrow_forward_rounded,
                  isSelected: false,
                  onTap: widget.onSeeMore,
                ),
              );
            }

            final Map<String, dynamic> cat = cats[actualIndex];
            final String catId = (cat['id'] ?? '').toString();
            final String label =
                (cat['name'] ?? cat['label'] ?? 'Service').toString();
            final bool selected = catId.isNotEmpty
                ? widget.selectedCategoryId == catId
                : widget.selectedCategory == label;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _CategoryChip(
                label: label,
                icon: widget.categoryIcon(cat),
                isSelected: selected,
                onTap: () => widget.onCategorySelected(catId, label),
              ),
            );
          },
        ),
      ),
    );
  }
}
