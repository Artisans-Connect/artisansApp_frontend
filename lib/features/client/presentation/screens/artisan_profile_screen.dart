import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/errors/error_messages.dart';
import '../navigation/client_navigation.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/services/reviews_service.dart';
import '../../../../shared/widgets/custom_back_button.dart';
 

 
// ─────────────────────────────────────────────────────────────────────────────
// Local reusable widgets
// ─────────────────────────────────────────────────────────────────────────────
 
/// Small caps section label
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08,
          color: DesignTokens.textSecondary,
        ),
      ),
    );
  }
}
 
/// Star row — filled vs unfilled based on rating integer.
class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, this.size = 14});
  final int rating;
  final double size;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int i) {
        return Icon(
          i < rating ? PhosphorIcons.starFill : PhosphorIcons.star,
          size: size,
          color: i < rating ? DesignTokens.accentGold : DesignTokens.warmBorder,
        );
      }),
    );
  }
}
 
/// Service chip pill
class _ServiceChip extends StatelessWidget {
  const _ServiceChip(this.label);
  final String label;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DesignTokens.warmTint,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(color: DesignTokens.warmBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: DesignTokens.primaryDark,
        ),
      ),
    );
  }
}
 
/// Quick action button (Call / Chat) shown in the identity strip.
class _QuickActionBtn extends StatelessWidget {
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
  });
 
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: DesignTokens.surfaceBase,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: DesignTokens.borderSubtle),
          ),
          child: loading
              ? const SizedBox(
                  height: 18,
                  child: Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(DesignTokens.primary),
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, color: DesignTokens.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
 
/// Rating summary bar row (e.g. the 5-star breakdown on the Reviews tab).
class _RatingBarRow extends StatelessWidget {
  const _RatingBarRow({required this.star, required this.fraction});
  final int star;
  final double fraction; // 0.0 – 1.0
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '$star',
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            color: DesignTokens.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              backgroundColor: DesignTokens.warmTint,
              color: DesignTokens.primary,
            ),
          ),
        ),
      ],
    );
  }
}
 
/// A single review card.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Map<String, dynamic> review;
 
  String _relativeDate(String? raw) {
    if (raw == null) return '';
    try {
      final DateTime dt = DateTime.parse(raw);
      final Duration diff = DateTime.now().difference(dt);
      if (diff.inDays < 1) return 'Today';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (_) {
      return '';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final String reviewerName =
        review['profiles']?['full_name']?.toString() ?? 'Client';
    final int rating = (review['rating'] as int?) ?? 0;
    final String comment =
        (review['comment'] as String?) ?? 'No comment provided.';
    final String dateLabel = _relativeDate(review['created_at'] as String?);
 
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.md),
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                reviewerName,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textPrimary,
                ),
              ),
              Row(
                children: <Widget>[
                  _StarRow(rating: rating, size: 13),
                  if (dateLabel.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11,
                        color: DesignTokens.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.sm),
          Text(
            comment,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
 
/// Gallery image tile — shows a network image with a fallback placeholder.
class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.imageUrl, this.overflowCount});
  final String imageUrl;
  final int? overflowCount; // if non-null, renders a "+N" overlay
 
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: DesignTokens.warmTint,
              child: const Icon(
                PhosphorIcons.image,
                color: DesignTokens.warmBorder,
                size: 28,
              ),
            ),
          ),
          if (overflowCount != null)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Text(
                '+$overflowCount',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Tab enum
// ─────────────────────────────────────────────────────────────────────────────
enum _ProfileTab { about, gallery, reviews }
 
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
  _ProfileTab _activeTab = _ProfileTab.about;
  List<dynamic> _reviews = <dynamic>[];
  bool _isLoadingReviews = true;
  String? _reviewError;
  bool _isOpeningChat = false;
 
  final ReviewsService _reviewsService = ReviewsService();
 
  // ── Data accessors (identical to original) ─────────────────────────────────
  Map<String, dynamic> get _artisan =>
      Map<String, dynamic>.from(
          widget.artisan ?? const <String, dynamic>{});
 
  Map<String, dynamic> get _profile =>
      Map<String, dynamic>.from(
          _artisan['profiles'] as Map<String, dynamic>? ??
              const <String, dynamic>{});
 
  String get _name =>
      (_artisan['name'] ?? _profile['full_name'] ?? 'Artisan').toString();
 
  String get _profession =>
      (_artisan['profession'] ?? _profile['profession'] ?? 'Professional')
          .toString();
 
  String get _imageUrl =>
      (_artisan['imageUrl'] ?? _profile['avatar_url'] ?? '').toString();
 
  String get _location =>
      (_artisan['location'] ?? _profile['location_label'] ?? 'Location not set')
          .toString();
 
  String get _phone =>
      (_artisan['phone'] ?? _profile['phone'] ?? '').toString();
 
  double get _rating =>
      ((_artisan['rating'] as num?) ??
              (_profile['rating'] as num?) ??
              0.0)
          .toDouble();
 
  int get _reviewCount =>
      ((_artisan['reviewCount'] as num?) ?? 0).toInt();
 
  String get _bio =>
      (_artisan['bio'] ??
              _profile['bio'] ??
              'Experienced professional with 10+ years in the industry. '
                  'Specialized in residential and commercial projects. '
                  'Committed to delivering high-quality work with excellent '
                  'customer service.')
          .toString();
 
  List<String> get _services {
    final dynamic raw = _artisan['services'] ??
        _artisan['skills'] ??
        _profile['skills'] ??
        <String>['Repair', 'Installation', 'Maintenance', 'Consultation'];
    if (raw is List) {
      return raw.map((dynamic e) => e.toString()).toList();
    }
    return <String>[raw.toString()];
  }
 
  String get _workerId =>
      (_artisan['id'] ??
              _artisan['worker_id'] ??
              _profile['id'] ??
              _artisan['userId'] ??
              '')
          .toString();
 
  /// Job-completion gallery images — pulled from the artisan map if the
  /// backend embeds them, otherwise falls back to an empty list. The field
  /// name `job_images` matches the expected Supabase column; adjust if yours
  /// differs.
  List<String> get _galleryUrls {
    final dynamic raw =
        _artisan['job_images'] ?? _profile['job_images'] ?? <dynamic>[];
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
    _fetchReviews();
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
                  flexibleSpace: FlexibleSpaceBar(
                    background: _imageUrl.isNotEmpty
                        ? Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _HeroFallback(initials: _initials(_name)),
                          )
                        : _HeroFallback(initials: _initials(_name)),
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
                  delegate: _TabBarDelegate(
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
              _StarRow(rating: _rating.round()),
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
 
  // ── Tab content dispatcher ─────────────────────────────────────────────────
  Widget _buildActiveTab() {
    switch (_activeTab) {
      case _ProfileTab.about:
        return _buildAboutTab();
      case _ProfileTab.gallery:
        return _buildGalleryTab();
      case _ProfileTab.reviews:
        return _buildReviewsTab();
    }
  }
 
  // ── About tab ─────────────────────────────────────────────────────────────
  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Bio
        const _SectionLabel('Bio'),
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
        const _SectionLabel('Services'),
        Wrap(
          spacing: DesignTokens.sm,
          runSpacing: DesignTokens.sm,
          children: _services
              .map((String s) => _ServiceChip(s))
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
        _SectionLabel(
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
              child: _GalleryTile(
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
        builder: (_) => _GalleryViewerScreen(
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
                  _StarRow(rating: _rating.round(), size: 13),
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
                      _RatingBarRow(
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
        ..._reviews.map((dynamic review) => _ReviewCard(
              review: review as Map<String, dynamic>,
            )),
        const SizedBox(height: DesignTokens.md),
      ],
    );
  }
 
  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.gutter, DesignTokens.md, DesignTokens.gutter, DesignTokens.lg),
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
              _QuickActionBtn(
                icon: PhosphorIcons.phone,
                label: 'Call',
                onTap: () =>
                    ClientNavigation.callPhone(context, _phone),
              ),
              const SizedBox(width: DesignTokens.md),
              _QuickActionBtn(
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
 
 
// ─────────────────────────────────────────────────────────────────────────────
// Hero fallback — shown when no image URL or image fails to load
// ─────────────────────────────────────────────────────────────────────────────
class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.initials});
  final String initials;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignTokens.warmTint,
      alignment: Alignment.center,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: DesignTokens.primaryTint08,
          shape: BoxShape.circle,
          border: Border.all(color: DesignTokens.warmBorder, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: DesignTokens.primary,
          ),
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// SliverPersistentHeaderDelegate for the sticky tab bar
// ─────────────────────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({
    required this.activeTab,
    required this.onTabChanged,
  });
 
  final _ProfileTab activeTab;
  final ValueChanged<_ProfileTab> onTabChanged;
 
  static const double _height = 48;
 
  @override
  double get minExtent => _height;
 
  @override
  double get maxExtent => _height;
 
  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.activeTab != activeTab;
 
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        border: const Border(
          bottom: BorderSide(color: DesignTokens.borderSubtle),
        ),
        boxShadow: overlapsContent
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          _Tab(
            label: 'About',
            active: activeTab == _ProfileTab.about,
            onTap: () => onTabChanged(_ProfileTab.about),
          ),
          _Tab(
            label: 'Gallery',
            active: activeTab == _ProfileTab.gallery,
            onTap: () => onTabChanged(_ProfileTab.gallery),
          ),
          _Tab(
            label: 'Reviews',
            active: activeTab == _ProfileTab.reviews,
            onTap: () => onTabChanged(_ProfileTab.reviews),
          ),
        ],
      ),
    );
  }
}
 
class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });
 
  final String label;
  final bool active;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? DesignTokens.primary : DesignTokens.textMuted,
                ),
              ),
            ),
            if (active)
              Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: DesignTokens.primary,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusFull),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Full-screen gallery viewer
// ─────────────────────────────────────────────────────────────────────────────
class _GalleryViewerScreen extends StatefulWidget {
  const _GalleryViewerScreen({
    required this.urls,
    required this.initialIndex,
  });
 
  final List<String> urls;
  final int initialIndex;
 
  @override
  State<_GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}
 
class _GalleryViewerScreenState extends State<_GalleryViewerScreen> {
  late final PageController _pageCtrl;
  late int _current;
 
  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }
 
  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.urls.length}',
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: widget.urls.length,
        onPageChanged: (int i) => setState(() => _current = i),
        itemBuilder: (BuildContext context, int i) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.urls[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  PhosphorIcons.imageBroken,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
