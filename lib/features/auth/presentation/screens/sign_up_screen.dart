import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/legal_agreement_text.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../models/onboarding_session.dart';
import '../../models/password_strength.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/password_strength_meter.dart';
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreed = false;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_handlePasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_handlePasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handlePasswordChanged() {
    setState(() {});
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
      AppToast.showError(context, e,
          fallback: 'Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitWithGoogle() async {
    setState(() {
      _isGoogleSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.instance.signInWithGoogle(
        flow: GoogleAuthFlow.signUp,
      );
      if (!mounted) return;
      await Navigator.pushReplacementNamed(context, shellRouteForUser(user));
    } on AuthFailure catch (e) {
      if (!mounted) return;
      if (e.code == AuthFailureCode.profileNotFound) {
        // Prefill onboarding data from Supabase auth user metadata when available.
        final supUser = Supabase.instance.client.auth.currentUser;
        if (supUser != null) {
          final dynamic metaRaw = supUser.userMetadata;
          String? name;
          String? phone;
          if (metaRaw is Map<String, dynamic>) {
            name = (metaRaw['full_name'] ??
                    metaRaw['name'] ??
                    metaRaw['user_name'] ??
                    metaRaw['preferred_username'])
                ?.toString();
            phone = (metaRaw['phone'] ?? metaRaw['phone_number'])?.toString();
          }
          final onboarding = OnboardingSession.instance;
          onboarding.fullName = name ?? supUser.email;
          onboarding.phone = phone ?? supUser.phone ?? '';
          onboarding.avatarUrl = (metaRaw is Map<String, dynamic>
                  ? metaRaw['avatar_url'] ?? metaRaw['picture']
                  : null)
              ?.toString();
        }

        await Navigator.pushReplacementNamed(
            context, RoleSelectionScreen.routeName);
        return;
      }

      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e,
          fallback: 'Google sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleSubmitting = false);
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
                        child: Center(
                            child: Text(
                          'Join CraftMatch',
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
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
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? PhosphorIcons.eyeClosed
                                : PhosphorIcons.eye,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: PasswordPolicy.validate,
                      ),
                      const SizedBox(height: 10),
                      PasswordStrengthMeter(password: _passwordController.text),
                      const SizedBox(height: 14),
                      Text('Confirm Password',
                          style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      AppInput(
                        controller: _confirmPasswordController,
                        hint: '••••••••',
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? PhosphorIcons.eyeClosed
                                : PhosphorIcons.eye,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (String? v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirm your password.';
                          }
                          if (v != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
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
                      const SizedBox(height: 12),
                      SecondaryButton(
                        label: 'Continue with Google',
                        isLoading: _isGoogleSubmitting,
                        onPressed: _submitWithGoogle,
                        leading: SvgPicture.asset('assets/google_logo.svg',
                            width: 20, height: 20),
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
