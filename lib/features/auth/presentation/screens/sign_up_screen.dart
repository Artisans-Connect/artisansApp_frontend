import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/legal_agreement_text.dart';
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
        await Navigator.pushReplacementNamed(
          context,
          VerifyEmailScreen.routeName,
          arguments: email,
        );
        return;
      }

      await Navigator.pushNamed(context, RoleSelectionScreen.routeName);
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  onPressed: () => unawaited(Navigator.maybePop(context)),
                  icon: Icon(PhosphorIcons.arrowLeft),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.15)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          'assets/ArtisanConnect Logo - 1.png',
                          width: 76,
                          height: 76,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Join ArtisansConnect',
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Join our premium community of vetted experts\nand clients today.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge,
                        ),
                      ),
                      if (_errorMessage != null) ...<Widget>[
                        const SizedBox(height: 16),
                        AuthErrorBanner(message: _errorMessage!),
                      ],
                      const SizedBox(height: 22),
                      Text('Full Name',
                          style: AppTypography.bodyLarge.copyWith(
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
                          style: AppTypography.bodyLarge.copyWith(
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
                          style: AppTypography.bodyLarge.copyWith(
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
                          style: AppTypography.bodyLarge.copyWith(
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
                              child: LegalAgreementText(
                                prefix: 'I agree to the ',
                                textStyle: AppTypography.bodyMedium,
                                linkColor: AppColors.primary,
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
                          onPressed: () => unawaited(
                            Navigator.pushNamed(context, '/auth/sign-in'),
                          ),
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
