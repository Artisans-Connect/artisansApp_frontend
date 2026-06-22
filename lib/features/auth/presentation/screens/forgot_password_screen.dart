import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/gradient_button.dart';
import 'sign_in_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  static const String routeName = '/auth/forgot-password';

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isSending = false;
  bool _isUpdating = false;
  bool _emailSent = false;
  late final bool _hasRecoverySession;

  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _hasRecoverySession = Supabase.instance.client.auth.currentSession != null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 60;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSending = true;
    });

    try {
      await AuthService.instance.sendPasswordResetEmail(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _emailSent = true);
      AppToast.showSuccess(context, 'Password reset email sent. Check your inbox.');
      _startCooldown();
    } on AuthFailure catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not send reset email.');
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not send reset email.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isUpdating = true;
    });

    try {
      await AuthService.instance.updatePassword(_newPasswordController.text);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Password updated successfully.');
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        SignInScreen.routeName,
        (_) => false,
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not update password.');
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not update password.');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showRecoveryForm = _hasRecoverySession;

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
                  onPressed: () => Navigator.maybePop(context),
                  icon: Icon(PhosphorIcons.arrowLeft),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.15),
                    ),
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
                          showRecoveryForm
                              ? 'Set a New Password'
                              : 'Forgot Password?',
                          style: AppTypography.displayMedium.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          showRecoveryForm
                              ? 'Choose a new password for your account.'
                              : _emailSent
                                  ? 'We sent a reset link to your inbox. Open it to finish resetting your password.'
                                  : 'Enter your email and we will send you a password reset link.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (!showRecoveryForm) ...<Widget>[
                        Text(
                          'Email Address',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                        const SizedBox(height: 20),
                        GradientButton(
                          label: _cooldownSeconds > 0
                              ? 'Resend in ${_cooldownSeconds}s'
                              : _emailSent
                                  ? 'Resend Reset Email'
                                  : 'Send Reset Email',
                          isLoading: _isSending,
                          onPressed: _cooldownSeconds > 0 || _isSending
                              ? null
                              : _sendResetEmail,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => unawaited(Navigator.pushNamedAndRemoveUntil(
                            context,
                            SignInScreen.routeName,
                            (_) => false,
                          )),
                          child: const Text('Back to Sign In'),
                        ),
                      ] else ...<Widget>[
                        Text(
                          'New Password',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppInput(
                          controller: _newPasswordController,
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
                          validator: (String? v) =>
                              (v == null || v.length < 6)
                                  ? 'Enter at least 6 characters.'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Confirm Password',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                            if (v == null || v.length < 6) {
                              return 'Confirm your new password.';
                            }
                            if (v != _newPasswordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        GradientButton(
                          label: 'Update Password',
                          isLoading: _isUpdating,
                          onPressed: _updatePassword,
                        ),
                      ],
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