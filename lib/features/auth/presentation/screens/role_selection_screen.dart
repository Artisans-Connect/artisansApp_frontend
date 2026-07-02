import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../../core/location/device_location_service.dart';
import '../../../../../core/location/place_lookup_service.dart';
import '../../../../../core/navigation/auth_navigation.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/utils/icon_mapper.dart';
import '../../../../../shared/models/user_profile_view.dart';
import '../../../../../shared/widgets/app_toast.dart';
import '../../../../../shared/widgets/gradient_button.dart';
import '../../../worker/presentation/worker_shell.dart';
import '../../models/onboarding_session.dart';
import '../widgets/role_selection/bio_page.dart';
import '../widgets/role_selection/onboarding_atoms.dart';
import '../widgets/role_selection/photo_location_page.dart';
import '../widgets/role_selection/role_selection_page.dart';
import '../widgets/role_selection/service_areas_page.dart';
import '../widgets/role_selection/trade_selection_page.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({
    super.key,
    this.session,
    this.isBecomingWorker = false,
  });

  /// If provided, we resume an existing onboarding session
  final OnboardingSession? session;

  /// If true, we skip the role-selection page and go straight to worker config
  final bool isBecomingWorker;

  static const String routeName = '/auth/role';

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  late final OnboardingSession _session;
  late final PageController _pageController;
  late final bool _isBecomingWorker;

  int _currentIndex = 0;
  bool _isSubmitting = false;

  // Trades
  bool _isLoadingTrades = false;
  List<TradeEntry> _trades = <TradeEntry>[];
  final TextEditingController _customTradeController = TextEditingController();
  bool _isResolvingTrade = false;
  String? _resolveMessage;
  bool _resolveSuccess = false;
  String _lastQuery = '';

  // Service Areas
  final TextEditingController _areaSearchController = TextEditingController();
  Timer? _debounceTimer;
  List<PlaceSuggestion> _areaSuggestions = <PlaceSuggestion>[];
  bool _isSearchingAreas = false;

  // Location
  final TextEditingController _locationController = TextEditingController();
  bool _isLoadingLocation = false;

  // Bio
  final TextEditingController _bioController = TextEditingController();
  final GlobalKey<FormState> _bioFormKey = GlobalKey<FormState>();

  // Photo
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  int get _totalDots {
    if (_isBecomingWorker) return 4;
    return _session.isClient ? 2 : 5;
  }

  // ── Init & Dispose ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _isBecomingWorker = widget.isBecomingWorker;

    _session = widget.session ?? OnboardingSession.instance;

    if (_isBecomingWorker) {
      _session.setRole(UserRole.worker);
    }

    _pageController = PageController();

    if (_session.locationLabel != null) {
      _locationController.text = _session.locationLabel!;
    }
    if (_session.bio != null) {
      _bioController.text = _session.bio!;
    }

    _locationController.addListener(() {
      _session.locationLabel = _locationController.text.trim();
    });

    _areaSearchController.addListener(_onAreaSearchChanged);

    _loadTrades();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _locationController.dispose();
    _customTradeController.dispose();
    _areaSearchController.dispose();
    _bioController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Network / Helpers ──────────────────────────────────────────────────────

  Future<void> _loadTrades() async {
    setState(() => _isLoadingTrades = true);
    try {
      final List<dynamic> res = await ApiClient.instance.get('/trades');
      final List<TradeEntry> apiTrades = res
          .map(_tradeEntryFromApi)
          .whereType<TradeEntry>()
          .toList(growable: false);
      if (!mounted) return;

      setState(() {
        _trades = apiTrades;
      });
    } catch (e) {
      debugPrint('Error loading trades: $e');
      if (mounted) {
        setState(() {
          _trades = _fallbackTrades;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingTrades = false);
      }
    }
  }

  TradeEntry? _tradeEntryFromApi(dynamic entry) {
    if (entry is String) {
      final String label = entry.trim();
      if (label.isEmpty) return null;
      return TradeEntry(label, PhosphorIcons.wrench);
    }

    if (entry is! Map<String, dynamic>) return null;
    final String label = (entry['name'] as String? ?? '').trim();
    if (label.isEmpty) return null;

    return TradeEntry(
      label,
      PhosphorIconMapper.fromString(entry['icon_name'] as String?),
    );
  }

  List<TradeEntry> get _fallbackTrades {
    const IconData constructionIcon = PhosphorIcons.barricade;
    const IconData electricalIcon = PhosphorIcons.lightning;
    const IconData plumbingIcon = PhosphorIcons.drop;
    const IconData autoIcon = PhosphorIcons.car;
    const IconData homeRepairIcon = PhosphorIcons.hammer;
    const IconData beautyIcon = PhosphorIcons.scissors;
    const IconData electronicsIcon = PhosphorIcons.desktopTower;
    const IconData hospitalityIcon = PhosphorIcons.forkKnife;
    const IconData artsIcon = PhosphorIcons.palette;

    return const <TradeEntry>[
      TradeEntry('Mason', constructionIcon),
      TradeEntry('Carpenter', constructionIcon),
      TradeEntry('Tiler', constructionIcon),
      TradeEntry('Painter', constructionIcon),
      TradeEntry('Steel Bender', constructionIcon),
      TradeEntry('Welder / Metal Fabricator', constructionIcon),
      TradeEntry('Ceiling Installer', constructionIcon),
      TradeEntry('Glass Worker', constructionIcon),
      TradeEntry('Roofer', constructionIcon),
      TradeEntry('Paver / Landscaper', constructionIcon),
      TradeEntry('Electrician', electricalIcon),
      TradeEntry('Solar Technician', electricalIcon),
      TradeEntry('Appliance Electrician', electricalIcon),
      TradeEntry('Generator Technician', electricalIcon),
      TradeEntry('CCTV / Security Installer', electricalIcon),
      TradeEntry('Plumber', plumbingIcon),
      TradeEntry('Borehole / Pump Technician', plumbingIcon),
      TradeEntry('Drainage Worker', plumbingIcon),
      TradeEntry('Sanitary Installer', plumbingIcon),
      TradeEntry('Auto Mechanic', autoIcon),
      TradeEntry('Auto Electrician', autoIcon),
      TradeEntry('Vulcanizer', autoIcon),
      TradeEntry('Sprayer / Auto Body Worker', autoIcon),
      TradeEntry('Motorcycle Mechanic', autoIcon),
      TradeEntry('Heavy Equipment Mechanic', autoIcon),
      TradeEntry('General Handyman', homeRepairIcon),
      TradeEntry('Furniture Repairer', homeRepairIcon),
      TradeEntry('Door/Window Repairer', homeRepairIcon),
      TradeEntry('Pest Control Worker', homeRepairIcon),
      TradeEntry('Cleaner', homeRepairIcon),
      TradeEntry('Gardener', homeRepairIcon),
      TradeEntry('Hairdresser', beautyIcon),
      TradeEntry('Barber', beautyIcon),
      TradeEntry('Makeup Artist', beautyIcon),
      TradeEntry('Tailor / Dressmaker', beautyIcon),
      TradeEntry('Shoemaker / Cobbler', beautyIcon),
      TradeEntry('Bead Maker', beautyIcon),
      TradeEntry('Milliner', beautyIcon),
      TradeEntry('Phone Repairer', electronicsIcon),
      TradeEntry('Laptop Technician', electronicsIcon),
      TradeEntry('TV Technician', electronicsIcon),
      TradeEntry('Sound System Technician', electronicsIcon),
      TradeEntry('Printer/Photocopier Technician', electronicsIcon),
      TradeEntry('Caterer', hospitalityIcon),
      TradeEntry('Baker', hospitalityIcon),
      TradeEntry('Decorator', hospitalityIcon),
      TradeEntry('Photographer', hospitalityIcon),
      TradeEntry('Videographer', hospitalityIcon),
      TradeEntry('DJ / Sound Provider', hospitalityIcon),
      TradeEntry('Canopy/Chair Rental', hospitalityIcon),
      TradeEntry('Potter', artsIcon),
      TradeEntry('Weaver', artsIcon),
      TradeEntry('Wood Carver', artsIcon),
      TradeEntry('Drum Maker', artsIcon),
      TradeEntry('Goldsmith / Jeweller', artsIcon),
      TradeEntry('Brass Smith', artsIcon),
      TradeEntry('Signwriter / Printer', artsIcon),
    ];
  }

  void _onAreaSearchChanged() {
    final String query = _areaSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _areaSuggestions = <PlaceSuggestion>[];
        _isSearchingAreas = false;
      });
      return;
    }

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _isSearchingAreas = true);
      try {
        final List<PlaceSuggestion> results =
            await PlaceLookupService.instance.search(query);
        if (mounted) {
          setState(() {
            _areaSuggestions = results;
          });
        }
      } catch (e) {
        debugPrint('Error fetching area suggestions: $e');
      } finally {
        if (mounted) {
          setState(() => _isSearchingAreas = false);
        }
      }
    });
  }

  void _addAreaFromInput([String? val]) {
    final String area = val ?? _areaSearchController.text.trim();
    if (area.isNotEmpty && !_session.serviceAreas.contains(area)) {
      setState(() {
        _session.serviceAreas.add(area);
        _areaSearchController.clear();
        _areaSuggestions = <PlaceSuggestion>[];
      });
    }
  }

  Future<void> _resolveCustomTrade() async {
    final String query = _customTradeController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isResolvingTrade = true;
      _resolveMessage = null;
      _lastQuery = query;
    });

    try {
      final Map<String, dynamic> res = await ApiClient.instance.post(
        '/trades/resolve',
        body: <String, dynamic>{'query': query},
      );

      if (!mounted) return;

      final bool matched = res['matched'] as bool? ?? false;
      final String resolvedTrade = res['resolved_trade'] as String? ?? query;

      setState(() {
        _resolveSuccess = matched;
        if (matched) {
          if (!_session.selectedTrades.contains(resolvedTrade)) {
            _session.selectedTrades.add(resolvedTrade);
            _resolveMessage = "Added standard trade: $resolvedTrade";
          } else {
            _resolveMessage = "Trade '$resolvedTrade' is already selected.";
          }
          _customTradeController.clear();
        } else {
          _resolveMessage =
              "We couldn't match this to a standard trade. You can still add it as a custom trade.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resolveSuccess = false;
        _resolveMessage = "Error checking trade. You can add it manually.";
      });
    } finally {
      if (mounted) {
        setState(() => _isResolvingTrade = false);
      }
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  bool _canProceed() {
    if (_isBecomingWorker) {
      if (_currentIndex == 0) return _session.selectedTrades.isNotEmpty;
      if (_currentIndex == 1) {
        return _session.serviceAreas.isNotEmpty &&
            _session.experienceBand != null;
      }
      if (_currentIndex == 2) {
        return _session.locationLabel != null &&
            _session.locationLabel!.isNotEmpty;
      }
      return true;
    } else {
      if (_session.role == null) return false;
      if (_session.isClient) {
        if (_currentIndex == 1) {
          return _session.locationLabel != null &&
              _session.locationLabel!.isNotEmpty;
        }
        return true;
      } else {
        if (_currentIndex == 1) return _session.selectedTrades.isNotEmpty;
        if (_currentIndex == 2) {
          return _session.serviceAreas.isNotEmpty &&
              _session.experienceBand != null;
        }
        if (_currentIndex == 3) {
          return _session.locationLabel != null &&
              _session.locationLabel!.isNotEmpty;
        }
        return true;
      }
    }
  }

  void _onNext() {
    if (_currentIndex == _totalDots - 1) {
      _finishProfile();
      return;
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
        'full_name':
            _session.fullName?.isNotEmpty == true ? _session.fullName : 'User',
        'phone':
            _session.phone?.isNotEmpty == true ? _session.phone : '0000000000',
        'signup_type': role,
        if (_session.avatarUrl != null &&
            _session.avatarUrl!.startsWith('http'))
          'avatar_url': _session.avatarUrl,
        if (_session.bio != null && _session.bio!.isNotEmpty)
          'bio': _session.bio,
        if (_session.experienceBand != null)
          'experience_band': _session.experienceBand,
        if (_session.locationLabel != null &&
            _session.locationLabel!.isNotEmpty)
          'location_label': _session.locationLabel,
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
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
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                ),
                ListTile(
                  leading:
                      Icon(PhosphorIcons.images, color: DesignTokens.primary),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
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
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
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
                        Icon(PhosphorIcons.trash, color: DesignTokens.error),
                    title: Text('Remove Photo',
                        style: TextStyle(color: DesignTokens.error)),
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
        AppToast.showError(context, e,
            fallback: 'Could not auto detect location.');
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
                        _buildTradeSelectionPageWrapper(),
                        _buildServiceAreasPageWrapper(),
                        _buildPhotoLocationPageWrapper(),
                        _buildBioPageWrapper(),
                      ]
                    : _session.isClient
                        ? <Widget>[
                            _buildRoleSelectionPageWrapper(),
                            _buildPhotoLocationPageWrapper(),
                          ]
                        : <Widget>[
                            _buildRoleSelectionPageWrapper(),
                            _buildTradeSelectionPageWrapper(),
                            _buildServiceAreasPageWrapper(),
                            _buildPhotoLocationPageWrapper(),
                            _buildBioPageWrapper(),
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
        trailingIcon: isLastPage ? null : PhosphorIcons.caretRight,
        isLoading: _isSubmitting,
        onPressed: canProceed ? _onNext : null,
      ),
    );
  }

  // ── Page Wrappers ──────────────────────────────────────────────────────────

  Widget _buildRoleSelectionPageWrapper() {
    return RoleSelectionPage(
      session: _session,
      onRoleSelected: (UserRole role) {
        setState(() => _session.setRole(role));
      },
    );
  }

  Widget _buildTradeSelectionPageWrapper() {
    return TradeSelectionPage(
      session: _session,
      isLoadingTrades: _isLoadingTrades,
      totalDots: _totalDots,
      currentDot: _isBecomingWorker ? 0 : 1,
      customTradeController: _customTradeController,
      isResolvingTrade: _isResolvingTrade,
      resolveMessage: _resolveMessage,
      resolveSuccess: _resolveSuccess,
      lastQuery: _lastQuery,
      trades: _trades,
      onResolveCustomTrade: _resolveCustomTrade,
      onTradeToggled: (String label) {
        setState(() {
          if (_session.selectedTrades.contains(label)) {
            _session.selectedTrades.remove(label);
          } else {
            _session.selectedTrades.add(label);
          }
        });
      },
      onCustomTradeAdded: (String trade) {
        setState(() {
          if (!_session.selectedTrades.contains(trade)) {
            _session.selectedTrades.add(trade);
          }
          _resolveMessage = null;
          _customTradeController.clear();
        });
      },
      onCustomTradeRemoved: (String trade) {
        setState(() {
          _session.selectedTrades.remove(trade);
        });
      },
    );
  }

  Widget _buildServiceAreasPageWrapper() {
    return ServiceAreasPage(
      session: _session,
      totalDots: _totalDots,
      currentDot: _isBecomingWorker ? 1 : 2,
      areaSearchController: _areaSearchController,
      areaSuggestions: _areaSuggestions,
      isSearchingAreas: _isSearchingAreas,
      onAddArea: () => _addAreaFromInput(),
      onAreaSelected: (String area) => _addAreaFromInput(area),
      onAreaRemoved: (String area) {
        setState(() {
          _session.serviceAreas.remove(area);
        });
      },
      onExperienceSelected: (String band) {
        setState(() {
          _session.experienceBand = band;
        });
      },
    );
  }

  Widget _buildPhotoLocationPageWrapper() {
    return PhotoLocationPage(
      session: _session,
      imageFile: _imageFile,
      locationController: _locationController,
      isLoadingLocation: _isLoadingLocation,
      onPickImage: _pickImage,
      onAutoDetectLocation: _autoDetectLocation,
    );
  }

  Widget _buildBioPageWrapper() {
    return BioPage(
      session: _session,
      bioController: _bioController,
      bioFormKey: _bioFormKey,
      totalDots: _totalDots,
      currentDot: _isBecomingWorker ? 3 : 4,
    );
  }
}
