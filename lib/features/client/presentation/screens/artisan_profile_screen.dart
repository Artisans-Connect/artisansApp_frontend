import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/core/errors/error_messages.dart';
import 'package:artisans_app/features/client/presentation/navigation/client_navigation.dart';
import 'package:artisans_app/shared/widgets/primary_button.dart';
import 'package:artisans_app/core/services/reviews_service.dart';
import 'package:artisans_app/shared/widgets/custom_back_button.dart';
import 'package:artisans_app/features/client/presentation/widgets/artisan_profile/profile_atoms.dart';
import 'package:artisans_app/features/client/presentation/widgets/artisan_profile/review_components.dart';
import 'package:artisans_app/features/client/presentation/widgets/artisan_profile/gallery_components.dart';
import 'package:artisans_app/core/services/profile_service.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/features/client/presentation/widgets/artisan_profile/profile_tab_bar.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/report_submission_bottom_sheet.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/block_user_dialog.dart';

 
// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class ArtisanProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? artisan;
 
  const ArtisanProfileScreen({Key? key, this.artisan}) : super(key: key);
 
  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}
 
class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  ProfileTab _activeTab = ProfileTab.about;
  List<dynamic> _reviews = <dynamic>[];
  bool _isLoadingReviews = true;
  String? _reviewError;
  bool _isOpeningChat = false;
  late Map<String, dynamic> _artisanDetails;

  final ReviewsService _reviewsService = ReviewsService();

  // ── Data accessors ─────────────────────────────────────────────────────────
  Map<String, dynamic> get _artisan => _artisanDetails;

  Map<String, dynamic> get _profile =>
      Map<String, dynamic>.from(
          _artisanDetails['profiles'] as Map? ??
          _artisanDetails);

  String get _workerId =>
      (_artisanDetails['id'] ??
              _artisanDetails['worker_id'] ??
              (_artisanDetails['profiles'] as Map?)?['id'] ??
              _artisanDetails['userId'] ??
              '')
          .toString();
  String get _name =>
      (_artisanDetails['name'] ?? _profile['full_name'] ?? 'Artisan').toString();

  String get _profession =>
      (_artisanDetails['profession'] ??
       _profile['profession'] ??
       (_profile['skills'] as List?)?.firstOrNull ??
       ((_artisanDetails['skills'] as List?)?.firstOrNull) ??
       'Professional')
          .toString();

  String get _imageUrl =>
      (_artisanDetails['imageUrl'] ?? _profile['avatar_url'] ?? '').toString();

  String get _location =>
      (_artisanDetails['location'] ?? _profile['location_label'] ?? 'Location not set')
          .toString();

  String get _phone =>
      (_artisanDetails['phone'] ?? _profile['phone'] ?? '').toString();

  double get _rating =>
      ((_artisanDetails['rating'] as num?) ??
              (_profile['rating'] as num?) ??
              (_artisanDetails['worker']?['rating'] as num?) ??
              0.0)
          .toDouble();

  int get _reviewCount =>
      ((_artisanDetails['reviewCount'] as num?) ??
       (_artisanDetails['worker']?['total_jobs'] as num?) ??
       0).toInt();

  String get _bio =>
      (_artisanDetails['bio'] ??
              _profile['bio'] ??
              'Experienced professional with 10+ years in the industry. '
                  'Specialized in residential and commercial projects. '
                  'Committed to delivering high-quality work with excellent '
                  'customer service.')
          .toString();

  List<String> get _services {
    final dynamic raw = _artisanDetails['services'] ??
        _artisanDetails['skills'] ??
        (_artisanDetails['worker'] as Map?)?['skills'] ??
        _profile['skills'] ??
        <String>['Repair', 'Installation', 'Maintenance', 'Consultation'];
    if (raw is List) {
      return raw.map((dynamic e) => e.toString()).toList();
    }
    return <String>[raw.toString()];
  }

  List<String> get _galleryUrls {
    final dynamic raw =
        _artisanDetails['job_images'] ?? _profile['job_images'] ?? <dynamic>[];
    if (raw is List) {
      return raw
          .map((dynamic e) => e.toString())
          .where((String s) => s.isNotEmpty)
          .toList();
    }
    return <String>[];
  }
 
  // ── Rating breakdown helper ────────────────────────────────────────────────
  /// Returns fractions [5-star, 4-star, 3-star, 2-star, 1-star] from reviews.
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
 
  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _artisanDetails = Map<String, dynamic>.from(widget.artisan ?? const <String, dynamic>{});
    _fetchReviews();
    _fetchFullProfile();
  }

  Future<void> _fetchFullProfile() async {
    final String workerId = _workerId;
    if (workerId.isEmpty) return;
    try {
      final Map<String, dynamic> freshProfile =
          await ProfileService.instance.getProfileById(workerId);
      if (mounted) {
        setState(() {
          _artisanDetails = <String, dynamic>{
            ..._artisanDetails,
            ...freshProfile,
            if (freshProfile['worker'] is Map<String, dynamic>)
              ...Map<String, dynamic>.from(freshProfile['worker'] as Map),
            if (_artisanDetails['profiles'] is Map)
              'profiles': <String, dynamic>{
                ...Map<String, dynamic>.from(_artisanDetails['profiles'] as Map),
                ...freshProfile,
              },
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading full artisan profile: $e');
    }
  }
 
  Future<void> _fetchReviews() async {
    final String workerId = _workerId;
    if (workerId.isEmpty) {
      setState(() => _isLoadingReviews = false);
      return;
    }
    try {
      final List<dynamic> reviews =
          await _reviewsService.getWorkerReviews(workerId);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _reviewError =
            userMessageFor(e, fallback: 'Could not load reviews.');
        _isLoadingReviews = false;
      });
    }
  }
 
  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      body: Column(
        children: <Widget>[
          // ── Scrollable upper portion ────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                // ── Hero image sliver app bar ────────────────────────────
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: DesignTokens.surfaceBase,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  leading: const Padding(
                    padding: EdgeInsets.all(8),
                    child: CustomBackButton(),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(PhosphorIcons.dotsThreeVertical, color: Colors.white),
                      ),
                      onSelected: (value) async {
                        if (value == 'report') {
                          ReportSubmissionBottomSheet.show(
                            context,
                            reportedId: _workerId,
                            reportedName: _name,
                          );
                        } else if (value == 'block') {
                          await showBlockUserDialog(
                            context,
                            blockedId: _workerId,
                            displayName: _name,
                            subjectLabel: 'Worker',
                            source: 'artisan profile',
                          );
                        } else if (value == 'share') {
                          AppToast.showSuccess(context, 'Artisan profile link copied.');
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.shareNetwork, size: 18),
                              SizedBox(width: 10),
                              Text('Share Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.warningCircle, size: 18, color: Colors.orange),
                              SizedBox(width: 10),
                              Text('Report Worker'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.userMinus, size: 18, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Block Worker', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _imageUrl.isNotEmpty
                        ? Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                HeroFallback(initials: _initials(_name)),
                          )
                        : HeroFallback(initials: _initials(_name)),
                    collapseMode: CollapseMode.parallax,
                  ),
                ),
 
                // ── Identity card ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildIdentityCard(),
                ),
 
                // ── Sticky tab bar ───────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ProfileTabBarDelegate(
                    activeTab: _activeTab,
                    onTabChanged: (tab) =>
                        setState(() => _activeTab = tab),
                  ),
                ),
 
                // ── Tab content ──────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      DesignTokens.gutter, DesignTokens.md, DesignTokens.gutter, DesignTokens.gutter),
                  sliver: SliverToBoxAdapter(
                    child: _buildActiveTab(),
                  ),
                ),
              ],
            ),
          ),
 
          // ── Bottom bar — Call / Chat / Book Now ─────────────────────────
          _buildBottomBar(),
        ],
      ),
    );
  }
 
  // ── Identity card ──────────────────────────────────────────────────────────
  Widget _buildIdentityCard() {
    return Container(
      decoration: const BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.gutter, DesignTokens.lg, DesignTokens.gutter, DesignTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Name
          Text(
            _name,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          // Profession
          Text(
            _profession,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Rating + location row
          Row(
            children: <Widget>[
              StarRow(rating: _rating.round()),
              const SizedBox(width: 6),
              Text(
                _rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textPrimary,
                ),
              ),
              Text(
                ' (${_reviewCount > 0 ? _reviewCount : _reviews.length} reviews)',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  color: DesignTokens.textMuted,
                ),
              ),
              const Spacer(),
              Icon(PhosphorIcons.mapPin,
                  size: 13, color: DesignTokens.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _location,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  Widget _buildActiveTab() {
    switch (_activeTab) {
      case ProfileTab.about:
        return _buildAboutTab();
      case ProfileTab.gallery:
        return _buildGalleryTab();
      case ProfileTab.reviews:
        return _buildReviewsTab();
    }
  }
 
  // ── About tab ─────────────────────────────────────────────────────────────
  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Bio
        const SectionLabel('Bio'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DesignTokens.md),
          decoration: BoxDecoration(
            color: DesignTokens.surfaceCard,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(color: DesignTokens.borderSubtle),
          ),
          child: Text(
            _bio,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              color: DesignTokens.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.lg),
 
        // Services
        const SectionLabel('Services'),
        Wrap(
          spacing: DesignTokens.sm,
          runSpacing: DesignTokens.sm,
          children: _services
              .map((String s) => ServiceChip(s))
              .toList(),
        ),
        const SizedBox(height: DesignTokens.md),
      ],
    );
  }
 
  // ── Gallery tab ───────────────────────────────────────────────────────────
  Widget _buildGalleryTab() {
    final List<String> urls = _galleryUrls;
 
    if (urls.isEmpty) {
      return Column(
        children: <Widget>[
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
              PhosphorIcons.images,
              color: DesignTokens.warmBorder,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No photos yet',
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
              'Job completion photos will appear\nhere after the artisan uploads them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: DesignTokens.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.md),
        ],
      );
    }
 
    // Show at most 9 tiles; last tile shows overflow count if more exist.
    const int maxVisible = 9;
    final bool hasOverflow = urls.length > maxVisible;
    final List<String> visibleUrls =
        urls.take(maxVisible).toList();
    final int overflowCount = urls.length - maxVisible;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionLabel(
            '${urls.length} job completion photo${urls.length == 1 ? '' : 's'}'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: visibleUrls.length,
          itemBuilder: (BuildContext context, int i) {
            final bool isLast = i == visibleUrls.length - 1;
            return GestureDetector(
              onTap: () => _openGalleryViewer(context, urls, i),
              child: GalleryTile(
                imageUrl: visibleUrls[i],
                overflowCount:
                    (isLast && hasOverflow) ? overflowCount : null,
              ),
            );
          },
        ),
        const SizedBox(height: DesignTokens.md),
      ],
    );
  }
 
  /// Simple full-screen image viewer — push a new route.
  void _openGalleryViewer(
      BuildContext context, List<String> urls, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GalleryViewerScreen(
          urls: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
 
  // ── Reviews tab ───────────────────────────────────────────────────────────
  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(
            color: DesignTokens.primary,
          ),
        ),
      );
    }
 
    if (_reviewError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text(
          _reviewError!,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            color: DesignTokens.error,
          ),
        ),
      );
    }
 
    if (_reviews.isEmpty) {
      return Column(
        children: <Widget>[
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
              'Reviews from completed jobs will\nappear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: DesignTokens.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.md),
        ],
      );
    }
 
    final List<double> fractions = _ratingFractions;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Rating summary card ──────────────────────────────────────────
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
 
        // ── Review list ──────────────────────────────────────────────────
        ..._reviews.map((dynamic review) => ReviewCard(
              review: review as Map<String, dynamic>,
            )),
        const SizedBox(height: DesignTokens.md),
      ],
    );
  }
 
  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        DesignTokens.gutter,
        DesignTokens.md,
        DesignTokens.gutter,
        bottomPadding > 0 ? bottomPadding + 8 : DesignTokens.lg,
      ),
      decoration: const BoxDecoration(
        color: DesignTokens.surfaceBase,
        border: Border(
          top: BorderSide(color: DesignTokens.borderSubtle),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Call + Chat
          Row(
            children: <Widget>[
              QuickActionBtn(
                icon: PhosphorIcons.phone,
                label: 'Call',
                onTap: () =>
                    ClientNavigation.callPhone(context, _phone),
              ),
              const SizedBox(width: DesignTokens.md),
              QuickActionBtn(
                icon: PhosphorIcons.chatTeardrop,
                label: 'Chat',
                loading: _isOpeningChat,
                onTap: () async {
                  setState(() => _isOpeningChat = true);
                  await ClientNavigation.openChatForArtisan(
                      context, _artisan);
                  if (mounted) setState(() => _isOpeningChat = false);
                },
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.md),
          // Book Now
          PrimaryButton(
            label: 'Book Now',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.directWorkerRequest,
              arguments: _artisan,
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Helpers ────────────────────────────────────────────────────────────────
  static String _initials(String name) {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).take(2).toList();
    return parts
        .map((String p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .join();
  }
}
