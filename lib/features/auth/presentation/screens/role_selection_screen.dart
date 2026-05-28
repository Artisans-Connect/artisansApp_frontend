import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/user_profile_view.dart';
import '../../../client/presentation/client_shell.dart';
import '../../../worker/presentation/worker_shell.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import '../../widgets/dot_indicator.dart';
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
  void dispose() {
    _pageController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  int get _totalDots => _session.isWorker ? 5 : 2;

  String get _stepLabel {
    if (_currentIndex == 0) return 'Step 1 of $_totalDots';
    if (_session.isClient) {
      if (_currentIndex == 1) return 'Step 2 of 3';
      if (_currentIndex == 2) return 'Step 3 of 3';
    } else {
      if (_currentIndex == 1) return 'Step 2 of 5';
      if (_currentIndex == 2) return 'Step 3 of 5';
      if (_currentIndex == 3) return 'Step 4 of 5';
      if (_currentIndex == 4) return 'Step 5 of 5';
    }
    return '';
  }

  void _onNext() {
    if (_session.isClient) {
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

  void _onBack() {
    if (_currentIndex == 0) {
      Navigator.maybePop(context);
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishProfile() async {
    if (_session.isWorker) {
      if (_bioFormKey.currentState?.validate() != true) return;
      _session.bio = _bioController.text.trim();
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile completion saved locally (stub).')),
    );
    final String route =
        _session.isClient ? ClientShell.routeName : WorkerShell.routeName;
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet<void>(
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
                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
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
                  leading: const Icon(Icons.camera_alt, color: AppColors.primary),
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
                    leading: const Icon(Icons.delete, color: AppColors.error),
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
    );
  }

  bool _canProceed() {
    if (_currentIndex == 0) return _session.role != null;
    if (_session.isWorker) {
      if (_currentIndex == 1) return _session.selectedTrades.isNotEmpty;
      if (_currentIndex == 2) {
        return _session.serviceAreas.isNotEmpty && _session.experienceBand != null;
      }
    }
    return true; // Other steps have optional fields or are validated on submit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Header bar ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: _onBack,
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  Text('Artisans',
                      style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),

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
                children: _session.isClient
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
                        : Icons.chevron_right,
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
            'How will you use\nArtisans?',
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
            icon: Icons.desktop_windows_outlined,
            isSelected: _session.isClient,
            onTap: () {
              setState(() => _session.setRole(UserRole.client));
            },
          ),
          const SizedBox(height: 18),
          RoleOptionCard(
            title: 'I offer services',
            subtitle: 'Showcase your skills and find new clients.',
            icon: Icons.work_outline,
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
                selectedColor: AppColors.primary.withOpacity(0.12),
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
                selectedColor: AppColors.primary.withOpacity(0.12),
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
                        const Icon(Icons.check_circle, color: AppColors.primary),
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
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.info_outline,
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
                              : const Icon(Icons.add_a_photo_outlined,
                                  color: AppColors.textSecondary, size: 42),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.secondary,
                            child: const Icon(Icons.edit,
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
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.secondary,
                        child: Icon(
                          _session.isClient
                              ? Icons.desktop_windows_outlined
                              : Icons.badge_outlined,
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
                      const Icon(Icons.check_circle,
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
                  prefixIcon: Icons.location_on_outlined,
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
