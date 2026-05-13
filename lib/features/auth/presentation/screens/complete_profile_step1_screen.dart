import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../widgets/dot_indicator.dart';

/// Step 2 of 3 in profile completion — photo, role confirmation, and location.
///
/// Receives the selected role from [RoleSelectionScreen] via route
/// arguments.  The account-type card is **interactive**: tapping it
/// toggles between "Client" and "Worker" inline so the user can change
/// their mind without navigating back.
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
  String _selectedRole = 'worker'; // default; overridden by arguments
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && (arg == 'client' || arg == 'worker')) {
      _selectedRole = arg;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  bool get _isClient => _selectedRole == 'client';

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

  void _showRoleSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Choose Account Type',
                  style: AppTextStyles.displayMd
                      .copyWith(fontSize: 22)),
              const SizedBox(height: 20),
              _RoleSheetOption(
                title: 'Client Profile',
                subtitle: 'Looking for workers',
                icon: Icons.desktop_windows_outlined,
                isSelected: _isClient,
                onTap: () {
                  setState(() => _selectedRole = 'client');
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
              _RoleSheetOption(
                title: 'Worker Profile',
                subtitle: 'Ready to offer services',
                icon: Icons.work_outline,
                isSelected: !_isClient,
                onTap: () {
                  setState(() => _selectedRole = 'worker');
                  Navigator.pop(ctx);
                },
              ),
            ],
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
                  Text('Step 2 of 3',
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

                          // ── Account type — interactive ──────────
                          Text('ACCOUNT TYPE',
                              style: AppTextStyles.labelCaps.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _showRoleSelector,
                            child: Container(
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
                                          style: AppTextStyles.labelCaps
                                              .copyWith(
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
                                  const Icon(Icons.check_circle_outline,
                                      color: AppColors.success, size: 18),
                                  TextButton(
                                    onPressed: _showRoleSelector,
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
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
                              // We could optionally pass image file path and location, 
                              // but since this is UI-focused right now, we'll just pass the role.
                              // Real app would likely store this in a riverpod provider or similar.
                              Navigator.pushNamed(
                                context,
                                '/auth/complete-profile-step2',
                                arguments: _selectedRole,
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
              child: const DotIndicator(totalDots: 3, activeIndex: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
/// Small helper widget used inside the role-change bottom sheet.
// ─────────────────────────────────────────────────────────────────────
class _RoleSheetOption extends StatelessWidget {
  const _RoleSheetOption({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  isSelected ? AppColors.primary : AppColors.outline,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700)),
                  Text(subtitle, style: AppTextStyles.bodyMd),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}
