import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../utils/shared_user_context.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/gradient_button.dart';

/// Shared edit profile — worker form (64) vs slimmer client form on the same route.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const String routeName = '/shared/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _bioMaxLength = 150;

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _hourlyRateController;
  late final TextEditingController _serviceAreasController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _editableSkills = <String>[];

  void _onBioChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    final session = SharedUserContext.session;
    final profile = SharedUserContext.buildOwnProfile();
    _nameController = TextEditingController(
      text: session.fullName ?? profile.fullName,
    );
    _bioController = TextEditingController(text: session.bio ?? profile.bio ?? '');
    _locationController = TextEditingController(
      text: session.locationLabel ?? profile.locationLabel ?? '',
    );
    _hourlyRateController = TextEditingController(
      text: session.hourlyRateNote ?? 'To be discussed with client',
    );
    _serviceAreasController = TextEditingController(
      text: session.serviceAreas.isNotEmpty
          ? session.serviceAreas.join(', ')
          : profile.serviceAreas.join(', '),
    );
    if (session.selectedTrades.isNotEmpty) {
      _editableSkills.addAll(session.selectedTrades);
    } else if (SharedUserContext.isWorker) {
      _editableSkills.addAll(profile.skills);
    }
    _bioController.addListener(_onBioChanged);
  }

  @override
  void dispose() {
    _bioController.removeListener(_onBioChanged);
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _hourlyRateController.dispose();
    _serviceAreasController.dispose();
    super.dispose();
  }

  bool get _isWorker => SharedUserContext.isWorker;

  Future<void> _save() async {
    final session = SharedUserContext.session;
    session.fullName = _nameController.text.trim();
    session.bio = _bioController.text.trim();
    session.locationLabel = _locationController.text.trim();

    try {
      await ProfileService.instance.updateProfile(<String, dynamic>{
        'full_name': _nameController.text.trim(),
        if (_bioController.text.trim().isNotEmpty)
          'bio': _bioController.text.trim(),
      });
      if (!mounted) return;
      AppToast.showSuccess(context, 'Profile updated.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not save profile.');
    }
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
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addSkill() async {
    final String? skill = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add skill'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'e.g. Electrical'),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (skill != null && skill.isNotEmpty && !_editableSkills.contains(skill)) {
      setState(() => _editableSkills.add(skill));
    }
  }

  DecorationImage? _getAvatarImage() {
    if (_imageFile != null) {
      return DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover);
    }
    final String? sessionUrl = SharedUserContext.session.avatarUrl;
    if (sessionUrl != null) {
      if (sessionUrl.startsWith('http')) {
        return DecorationImage(image: NetworkImage(sessionUrl), fit: BoxFit.cover);
      } else {
        return DecorationImage(image: FileImage(File(sessionUrl)), fit: BoxFit.cover);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String phone =
        SharedUserContext.session.phone ?? SharedUserContext.buildOwnProfile().phone ?? '';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        showBackButton: true,
        actions: <Widget>[
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceDim,
                          image: _getAvatarImage(),
                        ),
                        child: _getAvatarImage() == null
                            ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.secondary,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            onPressed: _pickImage,
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Change photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _fieldLabel('FULL NAME'),
            const SizedBox(height: 8),
            AppInput(controller: _nameController, hint: 'Your name'),
            const SizedBox(height: 16),
            _fieldLabel('PHONE NUMBER'),
            const SizedBox(height: 8),
            _LockedField(value: phone),
            if (_isWorker) ...<Widget>[
              const SizedBox(height: 16),
              _fieldLabel('SKILLS'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ..._editableSkills.map(
                    (String skill) => InputChip(
                      label: Text(skill),
                      labelStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.primary),
                      backgroundColor: AppColors.surfaceDim,
                      deleteIconColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide.none,
                      ),
                      onDeleted: () => setState(() => _editableSkills.remove(skill)),
                    ),
                  ),
                  InkWell(
                    onTap: _addSkill,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.add, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Add skill',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _fieldLabel('HOURLY RATE'),
              const SizedBox(height: 8),
              AppInput(
                controller: _hourlyRateController,
                hint: 'To be discussed with client',
                prefixIcon: Icons.payments_outlined,
              ),
              const SizedBox(height: 6),
              Text(
                'This value is managed through contract negotiations.',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 16),
              _fieldLabel('SERVICE AREAS'),
              const SizedBox(height: 8),
              AppInput(
                controller: _serviceAreasController,
                hint: 'Adum, Bantama, Suame',
                prefixIcon: Icons.location_on_outlined,
              ),
            ] else ...<Widget>[
              const SizedBox(height: 16),
              _fieldLabel('LOCATION'),
              const SizedBox(height: 8),
              AppInput(
                controller: _locationController,
                hint: 'Neighborhood or city',
                prefixIcon: Icons.location_on_outlined,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(child: _fieldLabel('BIO')),
                Text(
                  '${_bioController.text.length} / $_bioMaxLength',
                  style: AppTextStyles.bodyMd,
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppInput(
              controller: _bioController,
              hint: _isWorker
                  ? 'Tell clients about your experience…'
                  : 'Tell artisans what you usually need…',
              maxLines: 4,
              maxLength: _bioMaxLength,
            ),
            if (_isWorker) ...<Widget>[
              const SizedBox(height: 16),
              _fieldLabel('PRIMARY LOCATION'),
              const SizedBox(height: 8),
              AppInput(
                controller: _locationController,
                hint: 'Where you are based',
                prefixIcon: Icons.home_outlined,
              ),
            ],
            const SizedBox(height: 28),
            GradientButton(label: 'Save Changes', onPressed: _save),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelCaps.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      style: AppTextStyles.bodyLg.copyWith(color: AppColors.outline),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceDim.withOpacity(0.5),
        suffixIcon: const Icon(Icons.lock_outline, color: AppColors.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
