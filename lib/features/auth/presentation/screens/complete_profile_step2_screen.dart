import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../client/presentation/client_shell.dart';
import '../../../worker/presentation/worker_shell.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import '../../widgets/dot_indicator.dart';

/// Final onboarding step — bio only (worker trade/areas captured earlier).
class CompleteProfileStep2Screen extends StatefulWidget {
  const CompleteProfileStep2Screen({super.key});

  static const String routeName = '/auth/complete-profile-step2';

  @override
  State<CompleteProfileStep2Screen> createState() =>
      _CompleteProfileStep2ScreenState();
}

class _CompleteProfileStep2ScreenState extends State<CompleteProfileStep2Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bioController = TextEditingController();
  final OnboardingSession _session = OnboardingSession.instance;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  bool get _isClient => _session.isClient;

  String get _stepLabel => _isClient ? 'Step 3 of 3' : 'Bio';

  int get _activeDot => _isClient ? 2 : 1;
  int get _totalDots => _isClient ? 3 : 2;

  Future<void> _finishProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _session.bio = _bioController.text.trim();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile completion saved locally (stub).')),
    );
    final String route = _isClient
        ? ClientShell.routeName
        : WorkerShell.routeName;
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
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
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          _isClient ? 'Tell Us About You' : 'Your bio',
                          style: AppTextStyles.displayMd
                              .copyWith(fontSize: 58 * 0.7),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isClient
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
                                _isClient ? 'ABOUT YOU' : 'PROFESSIONAL BIO',
                                style: AppTextStyles.labelCaps.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              AppInput(
                                controller: _bioController,
                                hint: _isClient
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
