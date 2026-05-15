import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/screens/messages_list_screen.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../widgets/dot_indicator.dart';

/// Step 3 of 3 in profile completion — role-adaptive details.
///
/// Receives the selected role from [CompleteProfileStep1Screen] via
/// route arguments.
/// If Client: Asks for bio and general service preferences.
/// If Worker: Asks for specific skills, category, and experience level.
class CompleteProfileStep2Screen extends StatefulWidget {
  const CompleteProfileStep2Screen({super.key});

  static const String routeName = '/auth/complete-profile-step2';

  @override
  State<CompleteProfileStep2Screen> createState() =>
      _CompleteProfileStep2ScreenState();
}

class _CompleteProfileStep2ScreenState
    extends State<CompleteProfileStep2Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Shared
  final TextEditingController _bioController = TextEditingController();

  // Worker specific
  final TextEditingController _skillsController = TextEditingController();
  String? _selectedCategory;
  String _experienceLevel = 'Beginner';

  bool _isSubmitting = false;
  String _selectedRole = 'worker'; // Default, overridden by args

  final List<String> _categories = const <String>[
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Cleaning',
    'Landscaping',
    'Painting',
    'Other'
  ];

  final List<String> _experienceLevels = const <String>[
    'Beginner',
    'Intermediate',
    'Expert',
    'Master'
  ];

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
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  bool get _isClient => _selectedRole == 'client';

  Future<void> _finishProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isClient && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile completion saved locally (stub).')),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      MessagesListScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildWorkerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('PRIMARY CATEGORY',
            style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select your main trade',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() => _selectedCategory = value);
          },
        ),
        const SizedBox(height: 20),
        Text('SKILLS',
            style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        AppInput(
          controller: _skillsController,
          hint: 'e.g., Pipe fitting, leak repair...',
        ),
        const SizedBox(height: 20),
        Text('EXPERIENCE LEVEL',
            style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _experienceLevels.map((String level) {
            final bool isSelected = _experienceLevel == level;
            return ChoiceChip(
              label: Text(level),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) setState(() => _experienceLevel = level);
              },
              selectedColor: AppColors.primary.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSharedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_isClient ? 'ABOUT YOU' : 'PROFESSIONAL BIO',
            style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        AppInput(
          controller: _bioController,
          hint: _isClient
              ? "Tell us a bit about yourself and what services you usually need..."
              : "Tell clients about your background, work ethic, and why they should hire you...",
          maxLines: 4,
          maxLength: 250,
          validator: (String? value) {
            if ((value ?? '').trim().length < 10) {
              return 'Bio should be at least 10 characters.';
            }
            return null;
          },
        ),
      ],
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text('Artisans',
                      style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('Step 3 of 3',
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Text(
                            _isClient
                                ? 'Tell Us About You'
                                : 'Professional Details',
                            style: AppTextStyles.displayMd
                                .copyWith(fontSize: 58 * 0.7)),
                        const SizedBox(height: 10),
                        Text(
                          _isClient
                              ? 'A quick bio helps artisans know who they are working with.'
                              : 'These details help clients find you for the right jobs.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLg,
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (!_isClient) ...<Widget>[
                                _buildWorkerFields(),
                                const SizedBox(height: 24),
                              ],
                              _buildSharedFields(),
                              const SizedBox(height: 24),
                              GradientButton(
                                label: 'Complete Setup & Explore',
                                isLoading: _isSubmitting,
                                onPressed: _finishProfile,
                              ),
                              const SizedBox(height: 14),
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
              ),
            ),

            // ── Dot indicator ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: const DotIndicator(totalDots: 3, activeIndex: 2),
            ),
          ],
        ),
      ),
    );
  }
}
