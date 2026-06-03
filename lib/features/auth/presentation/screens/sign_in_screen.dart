import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../widgets/auth_error_banner.dart';
import 'role_selection_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.initialEmail});

  static const String routeName = '/auth/sign-in';

  final String? initialEmail;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  AuthFailure? _authError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _emailController.text.isEmpty) {
      _emailController.text = args;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resendVerification() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) return;
    try {
      await AuthService.instance.resendVerificationEmail(email);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Confirmation email sent.');
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not resend email.');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _authError = null;
    });

    try {
      final user = await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, shellRouteForRole(user.role));
    } on AuthFailure catch (e) {
      if (!mounted) return;
      if (e.code == AuthFailureCode.profileNotFound) {
        Navigator.pushReplacementNamed(context, RoleSelectionScreen.routeName);
        return;
      }
      setState(() => _authError = e);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Sign in failed. Please try again.');
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
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
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
                child: Form(
                  key: _formKey,
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
                          'Welcome Back',
                          style: AppTextStyles.displayMd.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Sign in to continue to Artisans.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLg,
                        ),
                      ),
                      if (_authError != null) ...<Widget>[
                        const SizedBox(height: 16),
                        AuthErrorBanner(
                          message: _authError!.message,
                          actionLabel: _authError!.code ==
                                  AuthFailureCode.emailNotConfirmed
                              ? 'Resend confirmation email'
                              : null,
                          onAction: _authError!.code ==
                                  AuthFailureCode.emailNotConfirmed
                              ? _resendVerification
                              : null,
                        ),
                      ],
                      const SizedBox(height: 22),
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?')),
                      ),
                      const SizedBox(height: 4),
                      GradientButton(
                          label: 'Sign In',
                          isLoading: _isSubmitting,
                          onPressed: _submit),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/auth/sign-up'),
                          child: const Text("Don't have an account? Sign Up"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
