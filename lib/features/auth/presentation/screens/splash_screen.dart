import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'onboarding_screen.dart';
import 'role_selection_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/auth/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        final user = await AuthService.instance.getCurrentUser();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, shellRouteForRole(user.role));
      } on AuthFailure catch (e) {
        if (!mounted) return;
        if (e.code == AuthFailureCode.profileNotFound) {
          Navigator.pushReplacementNamed(context, RoleSelectionScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, SignInScreen.routeName);
        }
      } catch (_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      }
    } else {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF6366F1), Color(0xFF3B82F6)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.handyman, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            Text(
              'Artisans',
              style: AppTextStyles.displayMd.copyWith(
                color: Colors.white,
                fontSize: 42,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
