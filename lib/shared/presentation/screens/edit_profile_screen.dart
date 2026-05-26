import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../data/shared_stub_data.dart';
import '../../utils/shared_user_context.dart';
import '../../widgets/app_input.dart';
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

  final List<String> _editableSkills = <String>[];

  void _onBioChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    final session = SharedUserContext.session;
    final base = SharedStubData.currentUserProfile;
    _nameController = TextEditingController(
      text: session.fullName ?? base.fullName,
    );
    _bioController = TextEditingController(text: session.bio ?? base.bio ?? '');
    _locationController = TextEditingController(
      text: session.locationLabel ?? base.locationLabel ?? '',
    );
    _hourlyRateController = TextEditingController(
      text: session.hourlyRateNote ?? 'To be discussed with client',
    );
    _serviceAreasController = TextEditingController(
      text: session.serviceAreas.isNotEmpty
          ? session.serviceAreas.join(', ')
          : base.serviceAreas.join(', '),
    );
    if (session.selectedTrades.isNotEmpty) {
      _editableSkills.addAll(session.selectedTrades);
    } else if (SharedUserContext.isWorker) {
      _editableSkills.addAll(base.skills);
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

  void _save() {
    final session = SharedUserContext.session;
    session.fullName = _nameController.text.trim();
    session.bio = _bioController.text.trim();
    session.locationLabel = _locationController.text.trim();
    if (_isWorker) {
      session.hourlyRateNote = _hourlyRateController.text.trim();
      session.selectedTrades
        ..clear()
        ..addAll(_editableSkills);
      session.serviceAreas
        ..clear()
        ..addAll(
          _serviceAreasController.text
              .split(',')
              .map((String s) => s.trim())
              .where((String s) => s.isNotEmpty),
        );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved locally (stub).')),
    );
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final String phone =
        SharedUserContext.session.phone ?? SharedStubData.currentUserProfile.phone ?? '';

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
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceDim,
                        child: Icon(Icons.person,
                            size: 48, color: AppColors.primary),
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
                            onPressed: () {},
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
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
