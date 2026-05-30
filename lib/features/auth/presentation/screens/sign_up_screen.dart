import 'package:flutter/material.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import '../../widgets/auth_error_banner.dart';
import 'role_selection_screen.dart';
import 'verify_email_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = '/auth/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_agreed) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final onboarding = OnboardingSession.instance;
    onboarding.fullName = _nameController.text.trim();
    onboarding.phone = _phoneController.text.trim();

    try {
      final outcome = await AuthService.instance.signUp(
        email: email,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (outcome.needsEmailVerification) {
        Navigator.pushReplacementNamed(
          context,
          VerifyEmailScreen.routeName,
          arguments: email,
        );
        return;
      }

      Navigator.pushNamed(context, RoleSelectionScreen.routeName);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppColors.outline.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.brush_outlined,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text('Join Artisans',
                            style: AppTextStyles.displayMd
                                .copyWith(fontSize: 66 * 0.78)),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Create your account to connect with the best\nlocal talent.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLg,
                        ),
                      ),
                      if (_errorMessage != null) ...<Widget>[
                        const SizedBox(height: 16),
                        AuthErrorBanner(message: _errorMessage!),
                      ],
                      const SizedBox(height: 22),
                      Text('Full Name',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _nameController,
                        hint: 'Your full name',
                        validator: (String? v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Enter your name.'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      Text('Email Address',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _emailController,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? v) =>
                            (v == null || !v.contains('@'))
                                ? 'Enter a valid email.'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      Text('Phone',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _phoneController,
                        hint: '+233…',
                        keyboardType: TextInputType.phone,
                        validator: (String? v) =>
                            (v == null || v.trim().length < 8)
                                ? 'Enter a valid phone number.'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      Text('Password',
                          style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _passwordController,
                        hint: '••••••••',
                        obscureText: true,
                        validator: (String? v) => (v == null || v.length < 6)
                            ? 'Enter at least 6 characters.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Checkbox(
                            value: _agreed,
                            onChanged: (bool? v) =>
                                setState(() => _agreed = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'I agree to the Terms of Service and Privacy Policy.',
                                style: AppTextStyles.bodyMd,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GradientButton(
                        label: 'Create Account',
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/auth/sign-in'),
                          child: const Text('Already have an account? Sign In'),
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
    );
  }
}
