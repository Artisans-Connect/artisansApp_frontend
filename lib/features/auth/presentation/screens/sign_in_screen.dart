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
import '../../../../shared/widgets/secondary_button.dart';
import '../../widgets/auth_error_banner.dart';
import 'forgot_password_screen.dart';
import 'role_selection_screen.dart';
import '../../models/onboarding_session.dart';

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
  bool _isGoogleSubmitting = false;
  AuthFailure? _authError;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_redirectIfAlreadySignedIn());
    });
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

  Future<void> _redirectIfAlreadySignedIn() async {
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('[SignInScreen] _redirectIfAlreadySignedIn triggered. Session exists: ${session != null}');
    if (session == null) return;

    try {
      debugPrint('[SignInScreen] Session accessToken: ${session.accessToken}');
      final user = await AuthService.instance.getCurrentUser();
      debugPrint('[SignInScreen] Current user fetched successfully: id=${user.id}, email=${user.email}, mode=${user.lastActiveMode}');
      if (!mounted) {
        debugPrint('[SignInScreen] Widget not mounted, aborting redirect');
        return;
      }
      final targetRoute = shellRouteForUser(user);
      debugPrint('[SignInScreen] Redirecting to target route: $targetRoute');
      await Navigator.pushReplacementNamed(context, targetRoute);
    } on AuthFailure catch (e) {
      debugPrint('[SignInScreen] AuthFailure during auto-redirect: ${e.code} - ${e.message}');
      if (!mounted) return;
      if (e.code == AuthFailureCode.profileNotFound) {
        debugPrint('[SignInScreen] Profile not found, redirecting to RoleSelectionScreen');
        await Navigator.pushReplacementNamed(
          context,
          RoleSelectionScreen.routeName,
        );
      }
    } catch (e, stack) {
      debugPrint('[SignInScreen] Staging error restoring session: $e\n$stack');
      // Stay on sign in when an existing session cannot be restored.
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
      await Navigator.pushReplacementNamed(context, shellRouteForUser(user));
    } on AuthFailure catch (e) {
      if (!mounted) return;
      if (e.code == AuthFailureCode.profileNotFound) {
        await Navigator.pushReplacementNamed(
            context, RoleSelectionScreen.routeName);
        return;
      }
      if (e.code == AuthFailureCode.accountSuspended) {
        AppToast.showError(context, e);
      }
      setState(() => _authError = e);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e,
          fallback: 'Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitWithGoogle() async {
    setState(() {
      _isGoogleSubmitting = true;
      _authError = null;
    });

    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      await Navigator.pushReplacementNamed(context, shellRouteForUser(user));
    } on AuthFailure catch (e) {
      if (!mounted) return;
      debugPrint('[SignIn] Google AuthFailure: ${e.code} - ${e.message}');
      if (e.code == AuthFailureCode.profileNotFound) {
        final supUser = Supabase.instance.client.auth.currentUser;
        if (supUser != null) {
          final dynamic metaRaw = supUser.userMetadata;
          String? name;
          String? phone;
          if (metaRaw is Map<String, dynamic>) {
            name = (metaRaw['full_name'] ?? metaRaw['name'])?.toString();
            phone = metaRaw['phone']?.toString();
          }
          final onboarding = OnboardingSession.instance;
          onboarding.fullName = name ?? supUser.email;
          onboarding.phone = phone ?? '';
          onboarding.avatarUrl = (metaRaw is Map<String, dynamic>
                  ? metaRaw['avatar_url'] ?? metaRaw['picture']
                  : null)
              ?.toString();
        }
        await Navigator.pushReplacementNamed(
            context, RoleSelectionScreen.routeName);
        return;
      }
      setState(() => _authError = e);
    } catch (e) {
      if (!mounted) return;
      debugPrint('[SignIn] Google sign-in error: $e');
      debugPrint('[SignIn] Error type: ${e.runtimeType}');
      AppToast.showError(
        context,
        e,
        fallback: 'Google sign in failed: $e',
      );
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
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Sign in to continue to CraftMatch.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge,
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
                        validator: (String? v) => (v == null || v.length < 6)
                            ? 'Enter at least 6 characters.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () => unawaited(
                                  Navigator.pushNamed(
                                    context,
                                    ForgotPasswordScreen.routeName,
                                    arguments:
                                        _emailController.text.trim().isEmpty
                                            ? null
                                            : _emailController.text.trim(),
                                  ),
                                ),
                            child: const Text('Forgot Password?')),
                      ),
                      const SizedBox(height: 4),
                      GradientButton(
                          label: 'Sign In',
                          isLoading: _isSubmitting,
                          onPressed: _submit),
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
                            Navigator.pushNamed(context, '/auth/sign-up'),
                          ),
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
