import 'dart:async';
import 'dart:io';
 
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/device_location_service.dart';
import '../../../../core/location/place_lookup_service.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../worker/presentation/worker_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/user_profile_view.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import '../../widgets/role_option_card.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/services/smart_search_service.dart';
 
// // ─────────────────────────────────────────────────────────────────────────────
// // Design tokens (mirrored from DESIGN.md)
// // ─────────────────────────────────────────────────────────────────────────────
// class _T {
//   // Surfaces
//   static const Color surfaceBase = Color(0xFFFFF8F0);
//   static const Color surfaceCard = Color(0xFFFFFFFF);
 
//   // Brand
//   static const Color primary     = Color(0xFFC15A3D); // terracotta
//   static const Color primaryDark = Color(0xFF8B3A2A);
//   static const Color accentGold  = Color(0xFFE6A017); // Kente gold
//   static const Color accentWarm  = Color(0xFFD97706);
 
//   // Text
//   static const Color textPrimary   = Color(0xFF2C2418);
//   static const Color textSecondary = Color(0xFF5C5243);
 
//   // Borders
//   static const Color borderSubtle = Color(0x0F000000); // rgba(0,0,0,0.06)
 
//   // Feedback
//   static const Color successGreen = Color(0xFF00E676);
//   static const Color error        = Color(0xFFBA1A1A);
 
//   // Derived tints used in the redesigned screens
//   static const Color primaryTint12 = Color(0x1FC15A3D); // 12% primary
//   static const Color primaryTint08 = Color(0x14C15A3D); // 8%
//   static const Color goldTint12    = Color(0x1FE6A017);
//   static const Color warmSurface   = Color(0xFFFAF2EA); // slightly richer off-white
 
//   // Radii
//   static const double radiusSm  = 4;
//   static const double radiusMd  = 12;
//   static const double radiusLg  = 16;
//   static const double radiusXl  = 24;
//   static const double radiusFull = 999;
 
//   // Spacing
//   static const double xs     = 4;
//   static const double sm     = 8;
//   static const double md     = 16;
//   static const double lg     = 24;
//   static const double xl     = 40;
//   static const double gutter = 20;
// }
 
// ─────────────────────────────────────────────────────────────────────────────
// Small reusable local widgets
// ─────────────────────────────────────────────────────────────────────────────
 
/// Pill-shaped progress step dots
class _StepDots extends StatelessWidget {
  const _StepDots({required this.total, required this.current});
  final int total;
  final int current;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? DesignTokens.primary : DesignTokens.primary.withAlpha((0.22 * 255).round()),
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          ),
        );
      }),
    );
  }
}
 
/// Hero band shown at the top of each onboarding page.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.icon,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.totalDots,
    required this.currentDot,
  });
 
  final Widget icon;
  final Color bgColor;
  final String title;
  final String subtitle;
  final int totalDots;
  final int currentDot;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(DesignTokens.gutter, 28, DesignTokens.gutter, 22),
      decoration: const BoxDecoration(
        color: DesignTokens.surfaceCard,
        border: Border(
          bottom: BorderSide(color: DesignTokens.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: DesignTokens.borderSubtle, width: 1.5),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 14),
          _StepDots(total: totalDots, current: currentDot),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DesignTokens.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
 
/// Premium 2-col trade icon card chip.
class _TradeChip extends StatelessWidget {
  const _TradeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
 
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? DesignTokens.primaryTint08 : DesignTokens.surfaceCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: selected ? DesignTokens.primary : DesignTokens.borderSubtle,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? DesignTokens.primaryTint12
                        : DesignTokens.surfaceBase,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected ? DesignTokens.primary : DesignTokens.textSecondary,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: DesignTokens.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? DesignTokens.primary : DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _ExperienceDetail {
  const _ExperienceDetail({
    required this.band,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String band;
  final String title;
  final String subtitle;
  final IconData icon;
}

const List<_ExperienceDetail> _experienceDetails = <_ExperienceDetail>[
  _ExperienceDetail(
    band: '0–1 years',
    title: 'Entry Level (0–1 years)',
    subtitle: 'Starting out, building experience and portfolio.',
    icon: PhosphorIcons.user,
  ),
  _ExperienceDetail(
    band: '1–3 years',
    title: 'Junior (1–3 years)',
    subtitle: 'Completed training, working independently on standard jobs.',
    icon: PhosphorIcons.wrench,
  ),
  _ExperienceDetail(
    band: '3–5 years',
    title: 'Intermediate (3–5 years)',
    subtitle: 'Experienced professional with a solid track record.',
    icon: PhosphorIcons.briefcase,
  ),
  _ExperienceDetail(
    band: '5+ years',
    title: 'Expert / Master (5+ years)',
    subtitle: 'Seasoned craftsman with deep expertise and master status.',
    icon: PhosphorIcons.star,
  ),
];

class _ExperienceOptionCard extends StatelessWidget {
  const _ExperienceOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.primaryTint08 : DesignTokens.surfaceCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: isSelected ? DesignTokens.primary : DesignTokens.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isSelected
                  ? DesignTokens.primary.withAlpha((0.08 * 255).round())
                  : Colors.black.withAlpha((0.02 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? DesignTokens.primaryTint12 : DesignTokens.surfaceBase,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                icon,
                color: isSelected ? DesignTokens.primary : DesignTokens.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? DesignTokens.primary : DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: DesignTokens.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? DesignTokens.primary : DesignTokens.borderSubtle,
                  width: isSelected ? 6.0 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
/// Info strip used on the service areas page.
class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.text});
  final String text;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.primaryTint08,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.primaryTint12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(PhosphorIcons.info, color: DesignTokens.primary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: DesignTokens.primaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
/// Section label (small caps, muted).
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
 
/// Trust signal chip shown in the Bio page.
class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: DesignTokens.primaryTint08,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: DesignTokens.primaryTint12),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: DesignTokens.primary, size: 18),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.05,
                color: DesignTokens.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
 
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});
 
  static const String routeName = '/auth/role-selection';
 
  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}
 
class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final PageController _pageController = PageController();
  final OnboardingSession _session = OnboardingSession.instance;
 
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final GlobalKey<FormState> _bioFormKey = GlobalKey<FormState>();
  final TextEditingController _customTradeController = TextEditingController();
 
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _isLoadingTrades = true;
  bool _isResolvingTrade = false;
  String? _resolveMessage;
  bool _resolveSuccess = false;
  String _lastQuery = '';

  int _currentIndex = 0;
  bool _isBecomingWorker = false;
  bool _parsedRouteArgs = false;

  // Dynamic service areas autocomplete
  final TextEditingController _areaSearchController = TextEditingController();
  List<PlaceSuggestion> _areaSuggestions = <PlaceSuggestion>[];
  bool _isSearchingAreas = false;
  Timer? _areaDebounce;
  
  // Dynamic trades loaded from database
  List<_TradeEntry> _trades = <_TradeEntry>[];
  final CategoriesService _categoriesService = CategoriesService();
 
  // ── Lifecycle ──────────────────────────────────────────────────────────────
  
  @override
  void initState() {
    super.initState();
    _loadTrades();
    _areaSearchController.addListener(_onAreaSearchChanged);
  }
  
  void _onAreaSearchChanged() {
    if (mounted) setState(() {});

    if (_areaDebounce?.isActive ?? false) _areaDebounce!.cancel();
    _areaDebounce = Timer(const Duration(milliseconds: 300), () async {
      final String query = _areaSearchController.text.trim();
      if (query.length < 2) {
        if (mounted) {
          setState(() {
            _areaSuggestions = <PlaceSuggestion>[];
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _isSearchingAreas = true;
        });
      }
      try {
        final List<PlaceSuggestion> suggestions =
            await PlaceLookupService.instance.search(query);
        if (mounted) {
          setState(() {
            _areaSuggestions = suggestions;
            _isSearchingAreas = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _areaSuggestions = <PlaceSuggestion>[];
            _isSearchingAreas = false;
          });
        }
      }
    });
  }

  void _addAreaFromInput([String? text]) {
    final String query = text ?? _areaSearchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _session.serviceAreas.add(query);
        _areaSearchController.clear();
        _areaSuggestions = <PlaceSuggestion>[];
      });
    }
  }
  
  Future<void> _loadTrades() async {
    try {
      final categories = await _categoriesService.listCategories();
      final List<_TradeEntry> trades = <_TradeEntry>[];
      
      for (final category in categories) {
        if (category is Map) {
          final Map<String, dynamic> categoryMap =
              Map<String, dynamic>.from(category);
          final String name = (categoryMap['name'] ?? '').toString();
          final String? iconName = categoryMap['icon_name']?.toString();
          final IconData icon = PhosphorIconMapper.fromString(iconName);

          if (name.isNotEmpty) trades.add(_TradeEntry(name, icon));
        }
      }

      if (!mounted) return;
      setState(() {
        _trades = trades;
        _isLoadingTrades = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTrades = false;
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_parsedRouteArgs) return;
    _parsedRouteArgs = true;
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['isBecomingWorker'] == true) {
      _isBecomingWorker = true;
      _session.setRole(UserRole.worker);
    }
  }
 
  @override
  void dispose() {
    _pageController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _customTradeController.dispose();
    _areaSearchController.removeListener(_onAreaSearchChanged);
    _areaSearchController.dispose();
    _areaDebounce?.cancel();
    super.dispose();
  }
 
  // ── Helpers ────────────────────────────────────────────────────────────────
 
  int get _totalDots {
    if (_isBecomingWorker) return 4;
    return _session.isWorker ? 5 : 2;
  }
 
  bool _canProceed() {
    if (_isBecomingWorker) {
      if (_currentIndex == 0) return _session.selectedTrades.isNotEmpty;
      if (_currentIndex == 1) {
        return _session.serviceAreas.isNotEmpty &&
            _session.experienceBand != null;
      }
      return true;
    }
    if (_currentIndex == 0) return _session.role != null;
    if (_session.isWorker) {
      if (_currentIndex == 1) return _session.selectedTrades.isNotEmpty;
      if (_currentIndex == 2) {
        return _session.serviceAreas.isNotEmpty &&
            _session.experienceBand != null;
      }
    }
    return true;
  }
 
  Future<void> _resolveCustomTrade() async {
    final String query = _customTradeController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _lastQuery = query;
      _isResolvingTrade = true;
      _resolveMessage = null;
      _resolveSuccess = false;
    });

    try {
      final SmartSearchIntent intent =
          await SmartSearchService.instance.parseIntent(query);

      if (!mounted) return;

      if (intent.categoryNames.isEmpty) {
        setState(() {
          _isResolvingTrade = false;
          _resolveMessage =
              "We couldn't match this to any available trade category. Please select from the listed options or try describing it differently.";
          _resolveSuccess = false;
        });
        return;
      }

      // We have matched some categories! Let's find matches in our trades list.
      final List<String> matchedLabels = <String>[];
      for (final String matchedName in intent.categoryNames) {
        final String normalizedMatched = matchedName.trim().toLowerCase();
        
        for (final _TradeEntry entry in _trades) {
          final String entryLabel = entry.label.trim().toLowerCase();
          if (entryLabel == normalizedMatched ||
              entryLabel.contains(normalizedMatched) ||
              normalizedMatched.contains(entryLabel)) {
            
            if (!_session.selectedTrades.contains(entry.label)) {
              _session.selectedTrades.add(entry.label);
            }
            if (!matchedLabels.contains(entry.label)) {
              matchedLabels.add(entry.label);
            }
          }
        }
      }

      setState(() {
        _isResolvingTrade = false;
        if (matchedLabels.isNotEmpty) {
          _resolveSuccess = true;
          _resolveMessage = "Matched and selected: ${matchedLabels.join(', ')}";
          _customTradeController.clear();
        } else {
          _resolveSuccess = false;
          _resolveMessage =
              "Matched to '${intent.categoryNames.join(', ')}', but we couldn't map it to the listed options. Please select a trade from the grid.";
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResolvingTrade = false;
          _resolveSuccess = false;
          _resolveMessage = "An error occurred while matching your trade. Please try again.";
        });
      }
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
 
  void _onNext() {
    if (_isBecomingWorker) {
      if (_currentIndex == 0 && _session.selectedTrades.isEmpty) return;
      if (_currentIndex == 1 &&
          (_session.serviceAreas.isEmpty || _session.experienceBand == null)) {
        return;
      }
      if (_currentIndex == 2) {
        _session.locationLabel = _locationController.text.trim();
      }
      if (_currentIndex == 3) {
        _finishProfile();
        return;
      }
    } else if (_session.isClient) {
      if (_currentIndex == 0 && _session.role == null) return;
      if (_currentIndex == 1) {
        _session.locationLabel = _locationController.text.trim();
        _finishProfile();
        return;
      }
    } else {
      if (_currentIndex == 0 && _session.role == null) return;
      if (_currentIndex == 1 && _session.selectedTrades.isEmpty) return;
      if (_currentIndex == 2 &&
          (_session.serviceAreas.isEmpty || _session.experienceBand == null)) {
        return;
      }
      if (_currentIndex == 3) {
        _session.locationLabel = _locationController.text.trim();
      }
      if (_currentIndex == 4) {
        _finishProfile();
        return;
      }
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
 
  // ── Submit ─────────────────────────────────────────────────────────────────
 
  Future<void> _finishProfile() async {
    if (_session.isWorker) {
      if (_bioFormKey.currentState?.validate() != true) return;
      _session.bio = _bioController.text.trim();
    }
 
    setState(() => _isSubmitting = true);
 
    if (_imageFile != null &&
        !(_session.avatarUrl?.startsWith('http') ?? false)) {
      try {
        final String? url =
            await StorageService.instance.uploadAvatar(_imageFile!);
        if (url != null) _session.avatarUrl = url;
      } catch (_) {
        // Avatar upload failed — continue without it
      }
    }
 
    try {
      final String role = _session.isWorker ? 'worker' : 'client';
      if (_isBecomingWorker) {
        final Map<String, dynamic> workerBody = <String, dynamic>{
          'skills': _session.selectedTrades.toList(),
          'service_areas': _session.serviceAreas.toList(),
          if (_session.experienceBand != null)
            'experience_band': _session.experienceBand,
          if (_session.bio != null && _session.bio!.isNotEmpty)
            'bio': _session.bio,
          if (_session.locationLabel != null &&
              _session.locationLabel!.isNotEmpty)
            'location_label': _session.locationLabel,
          if (_session.avatarUrl != null &&
              _session.avatarUrl!.startsWith('http'))
            'avatar_url': _session.avatarUrl,
        };
        await AuthService.instance.becomeWorker(workerBody);
        if (!mounted) return;
        await Navigator.pushNamedAndRemoveUntil(
          context,
          WorkerShell.routeName,
          (Route<dynamic> route) => false,
        );
        return;
      }
 
      final Map<String, dynamic> body = <String, dynamic>{
        'full_name': _session.fullName?.isNotEmpty == true
            ? _session.fullName
            : 'User',
        'phone': _session.phone?.isNotEmpty == true
            ? _session.phone
            : '0000000000',
        'signup_type': role,
        if (_session.avatarUrl != null &&
            _session.avatarUrl!.startsWith('http'))
          'avatar_url': _session.avatarUrl,
        if (_session.bio != null && _session.bio!.isNotEmpty)
          'bio': _session.bio,
        if (_session.experienceBand != null)
          'experience_band': _session.experienceBand,
      };
 
      if (_session.isWorker) {
        body['skills'] = _session.selectedTrades.toList();
        body['service_areas'] = _session.serviceAreas.toList();
      }
 
      final user = await AuthService.instance.createProfile(body);
 
      if (!mounted) return;
      await Navigator.pushNamedAndRemoveUntil(
        context,
        shellRouteForUser(user),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not save your profile.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
 
  // ── Image picker ───────────────────────────────────────────────────────────
 
  Future<void> _pickImage() async {
    unawaited(showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: DesignTokens.borderSubtle,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                ),
                ListTile(
                  leading:
                      Icon(PhosphorIcons.images, color: DesignTokens.primary),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _imageFile = File(image.path);
                        _session.avatarUrl = image.path;
                      });
                    }
                  },
                ),
                ListTile(
                  leading:
                      Icon(PhosphorIcons.camera, color: DesignTokens.primary),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _imageFile = File(image.path);
                        _session.avatarUrl = image.path;
                      });
                    }
                  },
                ),
                if (_imageFile != null) ...<Widget>[
                  const Divider(),
                  ListTile(
                    leading:
                        Icon(PhosphorIcons.trash, color: AppColors.error),
                    title: const Text('Remove Photo',
                        style: TextStyle(color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _imageFile = null;
                        _session.avatarUrl = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ));
  }
 
  Future<void> _autoDetectLocation() async {
    if (_isLoadingLocation) return;
    setState(() => _isLoadingLocation = true);
    try {
      final loc = await DeviceLocationService.getCurrentOrDefault();
      if (!mounted) return;
      if (loc.isFallback) {
        AppToast.showError(
          context,
          Exception('Could not access your GPS. Please check permission.'),
          fallback: 'Could not access GPS',
        );
        return;
      }

      final LatLng position = LatLng(loc.latitude, loc.longitude);
      final String? city =
          await PlaceLookupService.instance.reverseGeocodeToCity(position);
      if (!mounted) return;

      if (city != null && city.isNotEmpty) {
        setState(() {
          _locationController.text = city;
        });
      } else {
        AppToast.showError(
          context,
          Exception('Could not determine city for your location.'),
          fallback: 'Could not resolve city',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not auto detect location.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Content PageView ──────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int index) {
                  setState(() => _currentIndex = index);
                },
                children: _isBecomingWorker
                    ? <Widget>[
                        _buildTradeSelectionPage(),
                        _buildServiceAreasPage(),
                        _buildPhotoLocationPage(),
                        _buildBioPage(),
                      ]
                    : _session.isClient
                        ? <Widget>[
                            _buildRoleSelectionPage(),
                            _buildPhotoLocationPage(),
                          ]
                        : <Widget>[
                            _buildRoleSelectionPage(),
                            _buildTradeSelectionPage(),
                            _buildServiceAreasPage(),
                            _buildPhotoLocationPage(),
                            _buildBioPage(),
                          ],
              ),
            ),
 
            // ── Bottom CTA ────────────────────────────────────────────────
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }
 
  // ── Bottom bar ─────────────────────────────────────────────────────────────
 
  Widget _buildBottomBar() {
    final bool isLastPage = _currentIndex == _totalDots - 1;
    final bool canProceed = _canProceed();
 
    return Container(
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.gutter, 12, DesignTokens.gutter, 28),
      decoration: const BoxDecoration(
        color: DesignTokens.surfaceBase,
        border: Border(
          top: BorderSide(color: DesignTokens.borderSubtle),
        ),
      ),
      child: GradientButton(
        label: isLastPage ? 'Complete Setup & Explore' : 'Continue',
        trailingIcon:
            isLastPage ? null : PhosphorIcons.caretRight,
        isLoading: _isSubmitting,
        onPressed: canProceed ? _onNext : null,
      ),
    );
  }
 
  // ── Role Selection (unchanged logic, kept consistent) ──────────────────────
 
  Widget _buildRoleSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.gutter),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Text(
            'How will you use\nCraftMatch?',
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(fontSize: 50 * 0.78),
          ),
          const SizedBox(height: 10),
          Text(
            'Select your primary role to customize your\nexperience and connect with the right people.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 24),
          RoleOptionCard(
            title: 'I need a worker',
            subtitle: 'Find skilled professionals for your next project.',
            icon: PhosphorIcons.desktop,
            isSelected: _session.isClient,
            onTap: () => setState(() => _session.setRole(UserRole.client)),
          ),
          const SizedBox(height: 18),
          RoleOptionCard(
            title: 'I offer services',
            subtitle: 'Showcase your skills and find new clients.',
            icon: PhosphorIcons.briefcase,
            isSelected: _session.isWorker,
            onTap: () => setState(() => _session.setRole(UserRole.worker)),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────────────────────────────────
  // ── TRADE SELECTION (redesigned) ─────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────
 
  Widget _buildTradeSelectionPage() {
    final int selectedCount = _session.selectedTrades.length;

    // Show loading state
    if (_isLoadingTrades) {
      return Column(
        children: <Widget>[
          _HeroHeader(
            icon: const Icon(
              PhosphorIcons.toolbox,
              color: DesignTokens.primary,
              size: 34,
            ),
            bgColor: DesignTokens.primaryTint12,
            title: 'What work\ndo you do?',
            subtitle:
                'Pick all your trades — clients match\nyou based on these.',
            totalDots: _totalDots,
            currentDot: _isBecomingWorker ? 0 : 1,
          ),
          Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }
 
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Hero header
          _HeroHeader(
            icon: const Icon(
              PhosphorIcons.toolbox,
              color: DesignTokens.primary,
              size: 34,
            ),
            bgColor: DesignTokens.primaryTint12,
            title: 'What work\ndo you do?',
            subtitle:
                'Pick all your trades — clients match\nyou based on these.',
            totalDots: _totalDots,
            currentDot: _isBecomingWorker ? 0 : 1,
          ),
 
          // Content
          Padding(
            padding: const EdgeInsets.all(DesignTokens.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Smart search bar at the top
                AppInput(
                  controller: _customTradeController,
                  hint: "Search or describe what you do (e.g. I fix shoes)",
                  prefixIcon: PhosphorIcons.magnifyingGlass,
                  suffixIcon: _isResolvingTrade
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DesignTokens.primary,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            PhosphorIcons.arrowRight,
                            color: DesignTokens.primary,
                          ),
                          onPressed: _resolveCustomTrade,
                        ),
                ),
                if (_resolveMessage != null) ...[
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _resolveSuccess
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(
                        color: _resolveSuccess
                            ? const Color(0xFF81C784)
                            : const Color(0xFFE57373),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _resolveSuccess ? PhosphorIcons.checkCircle : PhosphorIcons.warningCircle,
                              color: _resolveSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _resolveMessage!,
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12,
                                  color: _resolveSuccess ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_lastQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final String formattedQuery = _lastQuery
                                    .split(' ')
                                    .map((word) => word.isNotEmpty
                                        ? '${word[0].toUpperCase()}${word.substring(1)}'
                                        : '')
                                    .join(' ');
                                if (!_session.selectedTrades.contains(formattedQuery)) {
                                  _session.selectedTrades.add(formattedQuery);
                                }
                                _resolveMessage = null;
                                _customTradeController.clear();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.plusCircle,
                                  size: 14,
                                  color: _resolveSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Add '$_lastQuery' as custom trade",
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _resolveSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                Builder(
                  builder: (BuildContext context) {
                    final List<String> predefinedLabels = _trades.map((_TradeEntry t) => t.label).toList();
                    final List<String> customTrades = _session.selectedTrades
                        .where((String trade) => !predefinedLabels.contains(trade))
                        .toList();

                    if (customTrades.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 12),
                        const _SectionLabel("Custom added trades"),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: customTrades.map((String trade) {
                            return Chip(
                              label: Text(
                                trade,
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.primaryDark,
                                ),
                              ),
                              backgroundColor: DesignTokens.primaryTint08,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                side: const BorderSide(color: DesignTokens.primaryTint12),
                              ),
                              deleteIcon: const Icon(
                                PhosphorIcons.x,
                                size: 14,
                                color: DesignTokens.primary,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _session.selectedTrades.remove(trade);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
                const _SectionLabel('All trades'),
 
                // 2-column icon card grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: _trades.length,
                  itemBuilder: (BuildContext context, int i) {
                    final _TradeEntry entry = _trades[i];
                    final bool selected =
                        _session.selectedTrades.contains(entry.label);
                    return _TradeChip(
                      label: entry.label,
                      icon: entry.icon,
                      selected: selected,
                      onTap: () => setState(() {
                        if (selected) {
                          _session.selectedTrades.remove(entry.label);
                        } else {
                          _session.selectedTrades.add(entry.label);
                        }
                      }),
                    );
                  },
                ),
 
                const SizedBox(height: 16),
 
                // Selected count strip
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: selectedCount > 0
                      ? Container(
                          key: ValueKey<int>(selectedCount),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: DesignTokens.goldTint12,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusMd),
                            border:
                                Border.all(color: DesignTokens.accentGold, width: 1),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(PhosphorIcons.checkCircle,
                                  color: DesignTokens.accentWarm, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$selectedCount trade${selectedCount > 1 ? 's' : ''} selected — add more any time from settings.",
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 12,
                                    color: DesignTokens.accentWarm,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────────────────────────────────
  // ── SERVICE AREAS + EXPERIENCE (redesigned) ───────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────
 
  Widget _buildServiceAreasPage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Hero header
          _HeroHeader(
            icon: const Icon(
              PhosphorIcons.mapPin,
              color: Color(0xFF1D9E75),
              size: 34,
            ),
            bgColor: const Color(0xFFE1F5EE),
            title: 'Where do\nyou work?',
            subtitle:
                'Choose the areas you cover and how\nlong you\'ve been in the trade.',
            totalDots: _totalDots,
            currentDot: _isBecomingWorker ? 1 : 2,
          ),
 
          // Body
          Padding(
            padding: const EdgeInsets.all(DesignTokens.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── Areas ──
                const _SectionLabel('Service areas'),
                AppInput(
                  controller: _areaSearchController,
                  hint: "Search area (e.g. East Legon, Accra)",
                  prefixIcon: PhosphorIcons.mapPin,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (String val) => _addAreaFromInput(val),
                  suffixIcon: _isSearchingAreas
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DesignTokens.primary,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            PhosphorIcons.plusCircle,
                            color: DesignTokens.primary,
                          ),
                          onPressed: () => _addAreaFromInput(),
                        ),
                ),
                if (_areaSuggestions.isNotEmpty || _areaSearchController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: DesignTokens.surfaceCard,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(color: DesignTokens.borderSubtle),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withAlpha((0.04 * 255).round()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ..._areaSuggestions.map((PlaceSuggestion suggestion) {
                            return ListTile(
                              dense: true,
                              leading: const Icon(PhosphorIcons.mapPin, size: 16, color: DesignTokens.textSecondary),
                              title: Text(
                                suggestion.description,
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: DesignTokens.textPrimary,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _session.serviceAreas.add(suggestion.description);
                                  _areaSearchController.clear();
                                  _areaSuggestions = <PlaceSuggestion>[];
                                });
                              },
                            );
                          }),
                          if (_areaSearchController.text.trim().isNotEmpty)
                            ListTile(
                              dense: true,
                              leading: const Icon(PhosphorIcons.plusCircle, size: 16, color: DesignTokens.primary),
                              title: Text(
                                "Add '${_areaSearchController.text.trim()}' as custom area",
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.primary,
                                ),
                              ),
                              onTap: () => _addAreaFromInput(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_session.serviceAreas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _session.serviceAreas.map((String area) {
                      return Chip(
                        label: Text(
                          area,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.primaryDark,
                          ),
                        ),
                        backgroundColor: DesignTokens.primaryTint08,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          side: const BorderSide(color: DesignTokens.primaryTint12),
                        ),
                        deleteIcon: const Icon(
                          PhosphorIcons.x,
                          size: 14,
                          color: DesignTokens.primary,
                        ),
                        onDeleted: () {
                          setState(() {
                            _session.serviceAreas.remove(area);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
 
                const SizedBox(height: DesignTokens.lg),
 
                // ── Experience ──
                const _SectionLabel('Experience level'),
                Column(
                  children: _experienceDetails.map((_ExperienceDetail detail) {
                    final bool isSelected = _session.experienceBand == detail.band;
                    return _ExperienceOptionCard(
                      title: detail.title,
                      subtitle: detail.subtitle,
                      icon: detail.icon,
                      isSelected: isSelected,
                      onTap: () => setState(() => _session.experienceBand = detail.band),
                    );
                  }).toList(),
                ),
 
                const SizedBox(height: DesignTokens.md),
                const _InfoStrip(
                  text:
                      'Hourly rates are negotiated per job — you set them after accepting a request.',
                ),
                const SizedBox(height: DesignTokens.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────────────────────────────────
  // ── PHOTO + LOCATION (original layout, token-updated) ─────────────────────
  // ─────────────────────────────────────────────────────────────────────────
 
  Widget _buildPhotoLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.gutter),
      child: Column(
        children: <Widget>[
          Text(
            'Complete Your Profile',
            style: AppTypography.displayMedium.copyWith(fontSize: 58 * 0.78),
          ),
          const SizedBox(height: 10),
          Text(
            "Let's put a face to the name and finalize\nyour setup.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.gutter),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceCard,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              border: Border.all(color: DesignTokens.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Avatar picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DesignTokens.warmSurface,
                            border: Border.all(
                              color: DesignTokens.borderSubtle,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                          ),
                          child: _imageFile != null
                              ? ClipOval(
                                  child: Image.file(_imageFile!,
                                      fit: BoxFit.cover),
                                )
                              : Icon(PhosphorIcons.cameraPlus,
                                  color: DesignTokens.textSecondary, size: 42),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: DesignTokens.primary,
                            child: const Icon(
                              PhosphorIcons.pencilSimple,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'UPLOAD PROFILE PICTURE',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08,
                      color: DesignTokens.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
 
                // Account type display
                const _SectionLabel('Account type'),
                Container(
                  padding: const EdgeInsets.all(DesignTokens.md),
                  decoration: BoxDecoration(
                    color: DesignTokens.warmSurface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    border: Border.all(color: DesignTokens.borderSubtle),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _session.isClient
                            ? DesignTokens.primaryTint12
                            : DesignTokens.primaryTint12,
                        child: Icon(
                          _session.isClient
                              ? PhosphorIcons.desktop
                              : PhosphorIcons.identificationCard,
                          color: DesignTokens.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'SELECTED ROLE',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                            Text(
                              _session.isClient
                                  ? 'Client Profile'
                                  : 'Worker Profile',
                              style: const TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(PhosphorIcons.checkCircle,
                          color: DesignTokens.successGreen, size: 20),
                    ],
                  ),
                ),
 
                const SizedBox(height: 22),
 
                // Location input
                const _SectionLabel('Location'),
                AppInput(
                  controller: _locationController,
                  hint: 'e.g., East Legon, Accra',
                  prefixIcon: PhosphorIcons.mapPin,
                  suffixIcon: _isLoadingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DesignTokens.primary,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            PhosphorIcons.crosshair,
                            color: DesignTokens.primary,
                          ),
                          onPressed: _autoDetectLocation,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────────────────────────────────
  // ── BIO PAGE (redesigned) ─────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────
 
  Widget _buildBioPage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Hero header
          _HeroHeader(
            icon: const Icon(
              PhosphorIcons.userCircle,
              color: DesignTokens.primary,
              size: 34,
            ),
            bgColor: DesignTokens.primaryTint12,
            title: _session.isClient
                ? 'Tell us about\nyourself'
                : 'Write your\nprofessional bio',
            subtitle: _session.isClient
                ? 'A quick intro helps artisans know\nwho they\'re working with.'
                : 'A great bio gets you hired faster.\nKeep it honest and specific.',
            totalDots: _totalDots,
            currentDot: _isBecomingWorker ? 3 : 4,
          ),
 
          // Body
          Form(
            key: _bioFormKey,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.gutter),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.gutter),
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceCard,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                  border: Border.all(color: DesignTokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      // Label + character ring row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _SectionLabel(
                            _session.isClient
                                ? 'About you'
                                : 'Professional bio',
                          ),
                          // Character count ring
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _bioController,
                            builder: (BuildContext context,
                                TextEditingValue value, Widget? _) {
                              final int count = value.text.length;
                              const int maxLen = 250;
                              final double progress = count / maxLen;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CustomPaint(
                                      painter: _RingPainter(
                                        progress: progress.clamp(0, 1),
                                        trackColor: DesignTokens.borderSubtle,
                                        fillColor: progress > 0.9
                                            ? DesignTokens.error
                                            : DesignTokens.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$count/$maxLen',
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 11,
                                      color: DesignTokens.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
 
                      // Textarea
                      AppInput(
                        controller: _bioController,
                        hint: _session.isClient
                            ? 'What kind of help do you usually need?'
                            : 'Tell clients about your background and work ethic…',
                        maxLines: 4,
                        maxLength: 250,
                        validator: (String? value) {
                          if ((value ?? '').trim().length < 10) {
                            return 'Bio should be at least 10 characters.';
                          }
                          return null;
                        },
                      ),
 
                      const SizedBox(height: 20),
 
                      // Trust signal chips
                      const _SectionLabel('Your profile will show'),
                      Row(
                        children: const <Widget>[
                          _TrustChip(
                            icon: PhosphorIcons.star,
                            label: 'Verified\ntrades',
                          ),
                          SizedBox(width: 8),
                          _TrustChip(
                            icon: PhosphorIcons.clock,
                            label: 'Response\ntime',
                          ),
                          SizedBox(width: 8),
                          _TrustChip(
                            icon: PhosphorIcons.checkCircle,
                            label: 'Job\nhistory',
                          ),
                        ],
                      ),
 
                      const SizedBox(height: 20),
 
                      // Guidelines note
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'By continuing you agree to our ',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 12,
                              color: DesignTokens.textSecondary,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'Community Guidelines',
                                style: const TextStyle(
                                  color: DesignTokens.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Helper data class for trade entries
// ─────────────────────────────────────────────────────────────────────────────
 
class _TradeEntry {
  const _TradeEntry(this.label, this.icon);
  final String label;
  final IconData icon;
}
 
// ─────────────────────────────────────────────────────────────────────────────
// Custom painter for the bio character-count ring
// ─────────────────────────────────────────────────────────────────────────────
 
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });
 
  final double progress;
  final Color trackColor;
  final Color fillColor;
 
  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.5;
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
 
    // Track
    canvas.drawArc(
      rect,
      -1.5708, // -π/2  (12 o'clock)
      6.2832,  // full circle
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
 
    // Fill arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -1.5708,
        6.2832 * progress,
        false,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }
 
  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}
