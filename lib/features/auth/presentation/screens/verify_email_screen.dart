import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/gradient_button.dart';
import 'sign_in_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  static const String routeName = '/auth/verify-email';

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isResending = false;

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await AuthService.instance.resendVerificationEmail(widget.email);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Confirmation email sent. Check your inbox.');
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not resend email. Try again shortly.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _goToSignIn() {
    Navigator.pushReplacementNamed(
      context,
      SignInScreen.routeName,
      arguments: widget.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(PhosphorIcons.envelopeSimpleOpen,
                          color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Check your email',
                      style: AppTextStyles.displayMd.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We sent a confirmation link to',
                      style: AppTextStyles.bodyLg,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: AppTextStyles.bodyLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Open the link in that email, then come back here to sign in and finish setting up your profile.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: "I've confirmed — Sign in",
                      onPressed: _goToSignIn,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isResending ? null : _resend,
                      child: Text(
                        _isResending ? 'Sending…' : 'Resend confirmation email',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
