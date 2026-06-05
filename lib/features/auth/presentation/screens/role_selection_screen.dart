import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../worker/presentation/worker_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/user_profile_view.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';

import '../../widgets/role_option_card.dart';

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

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  int _currentIndex = 0;
  bool _isBecomingWorker = false;
  bool _parsedRouteArgs = false;

  static const List<String> _trades = <String>[
    'Electrician',
    'Plumber',
    'Carpenter',
    'Mason',
    'Painter',
    'Welder',
    'Appliance Repair',
    'Other',
  ];

  static const List<String> _areas = <String>[
    'Adum',
    'Asokwa',
    'Bantama',
    'Suame',
    'Tafo',
    'Ahodwo',
    'Santasi',
    'KNUST',
  ];

  static const List<String> _experienceBands = <String>[
    '0–1 years',
    '1–3 years',
    '3–5 years',
    '5+ years',
  ];

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
    super.dispose();
  }

  int get _totalDots {
    if (_isBecomingWorker) return 4;
    return _session.isWorker ? 5 : 2;
  }



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



  Future<void> _finishProfile() async {
    if (_session.isWorker) {
      if (_bioFormKey.currentState?.validate() != true) return;
      _session.bio = _bioController.text.trim();
    }

    setState(() => _isSubmitting = true);

    // Upload avatar to Supabase Storage if a local file was picked
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
          if (_session.bio != null && _session.bio!.isNotEmpty) 'bio': _session.bio,
          if (_session.locationLabel != null && _session.locationLabel!.isNotEmpty)
            'location_label': _session.locationLabel,
          if (_session.avatarUrl != null && _session.avatarUrl!.startsWith('http'))
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
        'full_name': _session.fullName?.isNotEmpty == true ? _session.fullName : 'User',
        'phone': _session.phone?.isNotEmpty == true ? _session.phone : '0000000000',
        'signup_type': role,
        if (_session.avatarUrl != null && _session.avatarUrl!.startsWith('http'))
          'avatar_url': _session.avatarUrl,
        if (_session.bio != null && _session.bio!.isNotEmpty) 'bio': _session.bio,
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

  Future<void> _pickImage() async {
    unawaited(showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(PhosphorIcons.images, color: AppColors.primary),
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
                  leading: Icon(PhosphorIcons.camera, color: AppColors.primary),
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
                    leading: Icon(PhosphorIcons.trash, color: AppColors.error),
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

  bool _canProceed() {
    if (_isBecomingWorker) {
      if (_currentIndex == 0) return _session.selectedTrades.isNotEmpty;
      if (_currentIndex == 1) {
        return _session.serviceAreas.isNotEmpty && _session.experienceBand != null;
      }
      return true;
    }
    if (_currentIndex == 0) return _session.role != null;
    if (_session.isWorker) {
      if (_currentIndex == 1) return _session.selectedTrades.isNotEmpty;
      if (_currentIndex == 2) {
        return _session.serviceAreas.isNotEmpty && _session.experienceBand != null;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[

            // ── Content PageView ───────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
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

            // ── Bottom Action & Dot indicator ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientButton(
                    label: _currentIndex == _totalDots - 1
                        ? 'Complete Setup & Explore'
                        : 'Continue',
                    trailingIcon: _currentIndex == _totalDots - 1
                        ? null
                        : PhosphorIcons.caretRight,
                    isLoading: _isSubmitting,
                    onPressed: _canProceed() ? _onNext : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Text(
            'How will you use\nArtisansConnect?',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMd.copyWith(fontSize: 50 * 0.78),
          ),
          const SizedBox(height: 10),
          Text(
            'Select your primary role to customize your\nexperience and connect with the right people.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLg,
          ),
          const SizedBox(height: 24),
          RoleOptionCard(
            title: 'I need a worker',
            subtitle: 'Find skilled professionals for your next project.',
            icon: PhosphorIcons.desktop,
            isSelected: _session.isClient,
            onTap: () {
              setState(() => _session.setRole(UserRole.client));
            },
          ),
          const SizedBox(height: 18),
          RoleOptionCard(
            title: 'I offer services',
            subtitle: 'Showcase your skills and find new clients.',
            icon: PhosphorIcons.briefcase,
            isSelected: _session.isWorker,
            onTap: () {
              setState(() => _session.setRole(UserRole.worker));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTradeSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'What work do you do?',
            style: AppTextStyles.displayMd.copyWith(fontSize: 36),
          ),
          const SizedBox(height: 10),
          Text(
            'Select all that apply to help us find the right jobs for you.',
            style: AppTextStyles.bodyLg,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _trades.map((String trade) {
              final bool selected = _session.selectedTrades.contains(trade);
              return FilterChip(
                label: Text(trade),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _session.selectedTrades.remove(trade);
                    } else {
                      _session.selectedTrades.add(trade);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.outline,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAreasPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Where do you work?',
            style: AppTextStyles.displayMd.copyWith(fontSize: 36),
          ),
          const SizedBox(height: 10),
          Text(
            'Choose neighborhoods you can reach for jobs.',
            style: AppTextStyles.bodyLg,
          ),
          const SizedBox(height: 20),
          Text('Service areas',
              style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _areas.map((String area) {
              final bool selected = _session.serviceAreas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _session.serviceAreas.remove(area);
                    } else {
                      _session.serviceAreas.add(area);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                checkmarkColor: AppColors.primary,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.outline,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text('Experience',
              style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._experienceBands.map((String band) {
            final bool selected = _session.experienceBand == band;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => _session.experienceBand = band),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.outline,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          band,
                          style: AppTextStyles.bodyLg.copyWith(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(PhosphorIcons.checkCircle, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(PhosphorIcons.info,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hourly rates are set per job after you accept a request.',
                    style: AppTextStyles.bodyMd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Text(
            'Complete Your Profile',
            style: AppTextStyles.displayMd.copyWith(fontSize: 58 * 0.78),
          ),
          const SizedBox(height: 10),
          Text(
            "Let's put a face to the name and finalize\nyour setup.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLg,
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                            color: AppColors.surfaceDim,
                            border: Border.all(
                              color: AppColors.outline,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                          ),
                          child: _imageFile != null
                              ? ClipOval(
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(PhosphorIcons.cameraPlus,
                                  color: AppColors.textSecondary, size: 42),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.secondary,
                            child: Icon(PhosphorIcons.pencilSimple,
                                color: Colors.white, size: 16),
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
                    style: AppTextStyles.labelCaps.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('ACCOUNT TYPE',
                    style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _session.isClient
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.secondary,
                        child: Icon(
                          _session.isClient
                              ? PhosphorIcons.desktop
                              : PhosphorIcons.identificationCard,
                          color: _session.isClient
                              ? AppColors.primary
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'SELECTED ROLE',
                              style: AppTextStyles.labelCaps.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _session.isClient
                                  ? 'Client Profile'
                                  : 'Worker Profile',
                              style: AppTextStyles.bodyLg.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(PhosphorIcons.checkCircle,
                          color: AppColors.success, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text('LOCATION',
                    style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                AppInput(
                  controller: _locationController,
                  hint: 'e.g., East Legon, Accra',
                  prefixIcon: PhosphorIcons.mapPin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioPage() {
    return SingleChildScrollView(
      child: Form(
        key: _bioFormKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                _session.isClient ? 'Tell Us About You' : 'Your bio',
                style: AppTextStyles.displayMd.copyWith(fontSize: 58 * 0.7),
              ),
              const SizedBox(height: 10),
              Text(
                _session.isClient
                    ? 'A quick bio helps artisans know who they are working with.'
                    : 'Help clients understand your experience and approach.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg,
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _session.isClient ? 'ABOUT YOU' : 'PROFESSIONAL BIO',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Community\nGuidelines.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMd,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
