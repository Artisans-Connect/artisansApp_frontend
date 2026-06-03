import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/navigation/auth_navigation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/index.dart';
import 'onboarding_screen.dart';
import 'role_selection_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _minSplashDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final bool fastBoot = await _tryFastBootFromCache();
    if (fastBoot) return;

    await Future.wait<void>(<Future<void>>[
      Future<void>.delayed(_minSplashDuration),
      _routeAfterAuth(),
    ]);

    if (!mounted) return;
  }

  /// Skip the 3s splash when we already have a cached profile for this session.
  Future<bool> _tryFastBootFromCache() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;

    final user = await AuthService.instance.loadCachedUser();
    if (user == null || !mounted) return false;

    Navigator.pushReplacementNamed(context, shellRouteForUser(user));
    AuthService.instance.getCurrentUser(forceRefresh: true);
    return true;
  }

  Future<void> _routeAfterAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        final user = await AuthService.instance.getCurrentUser();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, shellRouteForUser(user));
      } on AuthFailure catch (e) {
        if (!mounted) return;
        if (e.code == AuthFailureCode.profileNotFound) {
          Navigator.pushReplacementNamed(context, RoleSelectionScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, SignInScreen.routeName);
        }
      } on NetworkException {
        if (!mounted) return;
        await AuthService.instance.signOut();
        Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      } on ApiException catch (e) {
        if (!mounted) return;
        if (e.isUnauthorized) {
          await AuthService.instance.tryRefreshSession();
          try {
            final user = await AuthService.instance.getCurrentUser();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, shellRouteForUser(user));
            return;
          } catch (_) {
            await AuthService.instance.signOut();
          }
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      } catch (_) {
        if (!mounted) return;
        await AuthService.instance.signOut();
        Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      }
    } else {
      if (!mounted) return;
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
          color: AppColors.primary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 172,
              height: 172,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF6ED),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/ArtisanConnect Logo - 1.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ArtisansConnect',
              style: AppTypography.displayMd.copyWith(
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
