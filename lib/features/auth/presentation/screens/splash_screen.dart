import 'dart:async';

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
  static const Duration _minSplashDuration = Duration(seconds: 4);

  /// Onboarding hero images to precache during splash so they display
  /// instantly when the user reaches the onboarding screen.
  static const List<String> _onboardingImageUrls = <String>[
    'https://images.unsplash.com/photo-1614213951697-a45781262acf?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1638262052640-82e94d64664a?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  /// Precache onboarding images so they're in Flutter's image cache when needed.
  Future<void> _precacheOnboardingImages() async {
    if (!mounted) return;
    await Future.wait(
      _onboardingImageUrls.map(
        (String url) => precacheImage(NetworkImage(url), context)
            .catchError((_) {}), // Silently ignore failures
      ),
    );
  }

  Future<void> _initializeApp() async {
    // Start image precaching immediately (needs context, available after initState).
    final Future<void> precacheFuture = _precacheOnboardingImages();

    final bool fastBoot = await _tryFastBootFromCache();
    if (fastBoot) return;

    await Future.wait<void>(<Future<void>>[
      Future<void>.delayed(_minSplashDuration),
      precacheFuture,
      _routeAfterAuth(),
    ]);

    if (!mounted) return;
  }

  /// Skip the splash when we already have a cached profile for this session.
  Future<bool> _tryFastBootFromCache() async {
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('[SplashScreen] _tryFastBootFromCache triggered. Session exists: ${session != null}');
    if (session == null) return false;

    final user = await AuthService.instance.loadCachedUser();
    debugPrint('[SplashScreen] Cached user loaded: ${user?.email}');
    if (user == null || !mounted) return false;

    final targetRoute = shellRouteForUser(user);
    debugPrint('[SplashScreen] Fast booting to cached user route: $targetRoute');
    await Navigator.pushReplacementNamed(context, targetRoute);
    unawaited(AuthService.instance.getCurrentUser(forceRefresh: true));
    return true;
  }

  Future<bool> _routeCachedUserIfAvailable() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      debugPrint('[SplashScreen] Cannot route to cached user: No active session');
      return false;
    }
    final user = await AuthService.instance.loadCachedUser();
    debugPrint('[SplashScreen] Routing cached user if available. Found: ${user?.email}');
    if (user == null || !mounted) return false;
    await Navigator.pushReplacementNamed(context, shellRouteForUser(user));
    return true;
  }

  Future<void> _routeAfterAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('[SplashScreen] _routeAfterAuth triggered. Session exists: ${session != null}');
    if (session != null) {
      try {
        final user = await AuthService.instance.getCurrentUser();
        debugPrint('[SplashScreen] Current user fetched: ${user.email}, mode: ${user.lastActiveMode}');
        if (!mounted) return;
        final targetRoute = shellRouteForUser(user);
        debugPrint('[SplashScreen] Redirecting to target route: $targetRoute');
        await Navigator.pushReplacementNamed(context, targetRoute);
      } on AuthFailure catch (e) {
        debugPrint('[SplashScreen] AuthFailure: ${e.code} - ${e.message}');
        if (!mounted) return;
        if (e.code == AuthFailureCode.profileNotFound) {
          debugPrint('[SplashScreen] Profile not found, redirecting to RoleSelectionScreen');
          await Navigator.pushReplacementNamed(context, RoleSelectionScreen.routeName);
        } else {
          debugPrint('[SplashScreen] Redirecting to SignInScreen');
          await Navigator.pushReplacementNamed(context, SignInScreen.routeName);
        }
      } on NetworkException {
        debugPrint('[SplashScreen] NetworkException during _routeAfterAuth');
        if (!mounted) return;
        if (await _routeCachedUserIfAvailable()) return;
        if (!mounted) return;
        debugPrint('[SplashScreen] Redirecting to SignInScreen (offline & no cache)');
        await Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      } on ApiException catch (e) {
        if (!mounted) return;
        if (e.code == 'ACCOUNT_SUSPENDED') {
          await AuthService.instance.signOut();
          if (!mounted) return;
          await Navigator.pushReplacementNamed(context, SignInScreen.routeName);
          return;
        }
        if (e.isUnauthorized) {
          final bool refreshed = await AuthService.instance.tryRefreshSession();
          if (refreshed) {
            try {
              final user = await AuthService.instance.getCurrentUser(
                forceRefresh: true,
              );
              if (!mounted) return;
              await Navigator.pushReplacementNamed(
                context,
                shellRouteForUser(user),
              );
              return;
            } catch (_) {
              await AuthService.instance.signOut();
            }
          } else {
            await AuthService.instance.signOut();
          }
        }
        if (!mounted) return;
        if (await _routeCachedUserIfAvailable()) return;
        if (!mounted) return;
        await Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      } catch (_) {
        if (!mounted) return;
        if (await _routeCachedUserIfAvailable()) return;
        if (!mounted) return;
        await Navigator.pushReplacementNamed(context, SignInScreen.routeName);
      }
    } else {
      if (!mounted) return;
      await Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primary,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Exact 2D screen center alignment matching native splash
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF6ED),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/ArtisanConnect Logo - 1.png',
                  width: 108,
                  height: 108,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Branding and progress indicator positioned below center
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'CraftMatch',
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontSize: 38,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
