import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/platform_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../models/picked_media.dart';
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

  static const List<String> _trades = <String>[
    'Mason',
    'Carpenter',
    'Tiler',
    'Painter',
    'Welder / Metal Fabricator',
    'Electrician',
    'Solar Technician',
    'Plumber',
    'Borehole / Pump Technician',
    'Auto Mechanic',
    'Vulcanizer',
    'General Handyman',
    'Cleaner',
    'Gardener',
    'Hairdresser',
    'Barber',
    'Tailor / Dressmaker',
    'Shoemaker / Cobbler',
    'Phone Repairer',
    'Laptop Technician',
    'Caterer',
    'Baker',
    'Photographer',
    'Wood Carver',
    'Other',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _hourlyRateController;
  late final TextEditingController _serviceAreasController;

  PickedMedia? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

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
    _phoneController = TextEditingController(
      text: session.phone ?? profile.phone ?? '',
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
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _hourlyRateController.dispose();
    _serviceAreasController.dispose();
    super.dispose();
  }

  bool get _isWorker => SharedUserContext.isWorker;

  Future<void> _save() async {
    if (_isSaving) return;

    final String fullName = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String bio = _bioController.text.trim();
    final String locationLabel = _locationController.text.trim();

    if (fullName.isEmpty) {
      AppToast.showError(context, 'Full name is required.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? avatarUrl;
      if (_imageFile != null) {
        avatarUrl = await StorageService.instance.uploadAvatar(_imageFile!);
      }

      final Map<String, dynamic> body = <String, dynamic>{
        'full_name': fullName,
        if (phone.isNotEmpty) 'phone': phone,
        if (bio.isNotEmpty) 'bio': bio,
        'location_label': locationLabel,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      await ProfileService.instance.updateProfile(body);
      await ProfileService.instance.getMyProfile(forceRefresh: true);
      final session = SharedUserContext.session;
      session.fullName = fullName;
      if (phone.isNotEmpty) session.phone = phone;
      session.bio = bio;
      session.locationLabel = locationLabel;
      if (avatarUrl != null) session.avatarUrl = avatarUrl;
      if (!mounted) return;
      AppToast.showSuccess(context, 'Profile updated.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not save profile.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet<void>(
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
                      final PickedMedia media =
                          await PickedMedia.fromXFile(image);
                      setState(() {
                        _imageFile = media;
                      });
                    }
                  },
                ),
                if (PlatformService.supportsCamera)
                  ListTile(
                    leading: Icon(PhosphorIcons.camera, color: AppColors.primary),
                    title: const Text('Take a Photo'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        final PickedMedia media =
                            await PickedMedia.fromXFile(image);
                        setState(() {
                          _imageFile = media;
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

  Future<void> _addCustomSkill() async {
    final String? skill = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Custom Skill'),
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
      return DecorationImage(
        image: MemoryImage(_imageFile!.bytes),
        fit: BoxFit.cover,
      );
    }
    final String? sessionUrl = SharedUserContext.session.avatarUrl;
    if (sessionUrl != null) {
      if (sessionUrl.startsWith('http')) {
        return DecorationImage(image: NetworkImage(sessionUrl), fit: BoxFit.cover);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        showBackButton: true,
        actions: <Widget>[
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTypography.bodyLarge.copyWith(
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
                            ? Icon(PhosphorIcons.user, size: 48, color: AppColors.primary)
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
                            icon: Icon(PhosphorIcons.pencilSimple,
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
            AppInput(
              controller: _phoneController,
              hint: 'Phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: PhosphorIcons.phone,
            ),
            if (_isWorker) ...<Widget>[
              const SizedBox(height: 16),
              _fieldLabel('SKILLS'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ..._trades.map((String trade) {
                    final bool selected = _editableSkills.contains(trade);
                    return FilterChip(
                      label: Text(trade),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          if (selected) {
                            _editableSkills.remove(trade);
                          } else {
                            if (trade == 'Other') {
                              _addCustomSkill();
                            } else {
                              _editableSkills.add(trade);
                            }
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
                  }),
                  ..._editableSkills.where((String s) => !_trades.contains(s) && s != 'Other').map(
                    (String skill) => InputChip(
                      label: Text(skill),
                      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      deleteIconColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      onDeleted: () => setState(() => _editableSkills.remove(skill)),
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
                prefixIcon: PhosphorIcons.money,
              ),
              const SizedBox(height: 6),
              Text(
                'This value is managed through contract negotiations.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),
              _fieldLabel('SERVICE AREAS'),
              const SizedBox(height: 8),
              AppInput(
                controller: _serviceAreasController,
                hint: 'Adum, Bantama, Suame',
                prefixIcon: PhosphorIcons.mapPin,
              ),
            ] else ...<Widget>[
              const SizedBox(height: 16),
              _fieldLabel('LOCATION'),
              const SizedBox(height: 8),
              AppInput(
                controller: _locationController,
                hint: 'Neighborhood or city',
                prefixIcon: PhosphorIcons.mapPin,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(child: _fieldLabel('BIO')),
                Text(
                  '${_bioController.text.length} / $_bioMaxLength',
                  style: AppTypography.bodyMedium,
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
                prefixIcon: PhosphorIcons.house,
              ),
            ],
            const SizedBox(height: 28),
            GradientButton(
              label: 'Save Changes',
              onPressed: _isSaving ? null : _save,
              isLoading: _isSaving,
            ),
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
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

