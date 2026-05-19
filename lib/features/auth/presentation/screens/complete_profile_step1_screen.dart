import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import '../../widgets/dot_indicator.dart';

/// Photo upload and location — role comes from [OnboardingSession] (read-only).
class CompleteProfileStep1Screen extends StatefulWidget {
  const CompleteProfileStep1Screen({super.key});

  static const String routeName = '/auth/complete-profile-step1';

  @override
  State<CompleteProfileStep1Screen> createState() =>
      _CompleteProfileStep1ScreenState();
}

class _CompleteProfileStep1ScreenState
    extends State<CompleteProfileStep1Screen> {
  final TextEditingController _locationController = TextEditingController();
  final OnboardingSession _session = OnboardingSession.instance;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  bool get _isClient => _session.isClient;
  bool get _isWorker => _session.isWorker;

  String get _stepLabel =>
      _isWorker ? 'Photo & location' : 'Step 2 of 3';

  int get _activeDot => _isWorker ? 0 : 1;
  int get _totalDots => _isWorker ? 2 : 3;

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
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => _imageFile = File(image.path));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() => _imageFile = File(image.path));
                    }
                  },
                ),
                if (_imageFile != null) ...<Widget>[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete, color: AppColors.error),
                    title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _imageFile = null);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Header bar ───────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text('Artisans',
                      style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(_stepLabel,
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Complete Your Profile',
                      style: AppTextStyles.displayMd
                          .copyWith(fontSize: 58 * 0.78),
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
                          // ── Profile picture ─────────────────────
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
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      ),
                                    ),
                                    child: _imageFile != null
                                        ? ClipOval(
                                            child: Image.file(
                                              _imageFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_a_photo_outlined,
                                            color: AppColors.textSecondary,
                                            size: 42),
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

                          // ── Account type — read-only from session ──
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
                                  backgroundColor: _isClient
                                      ? AppColors.primary.withOpacity(0.15)
                                      : AppColors.secondary,
                                  child: Icon(
                                    _isClient
                                        ? Icons.desktop_windows_outlined
                                        : Icons.badge_outlined,
                                    color: _isClient
                                        ? AppColors.primary
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'SELECTED ROLE',
                                        style: AppTextStyles.labelCaps.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        _isClient
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

                          // ── Location ────────────────────────────
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
                          const SizedBox(height: 28),
                          GradientButton(
                            label: 'SAVE & CONTINUE',
                            trailingIcon: Icons.arrow_forward,
                            onPressed: () {
                              _session.locationLabel =
                                  _locationController.text.trim();
                              Navigator.pushNamed(
                                context,
                                '/auth/complete-profile-step2',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Dot indicator ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: DotIndicator(totalDots: _totalDots, activeIndex: _activeDot),
            ),
          ],
        ),
      ),
    );
  }
}
