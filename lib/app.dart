import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artisans_app/core/theme/app_theme.dart';
import 'package:artisans_app/core/navigation/app_router.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/navigation/app_navigation.dart';
import 'package:artisans_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:artisans_app/core/services/notification_service.dart';
import 'package:artisans_app/core/services/auth_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(AuthService.instance.loadCachedUser());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.drainPendingNavigation();
    });

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      AuthState data,
    ) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        final navigatorContext =
            NotificationService.instance.navigatorKey.currentContext;
        if (navigatorContext != null) {
          AppNavigation.resetToPasswordRecovery(
            navigatorContext,
            arguments: const ForgotPasswordScreenArgs(isRecoveryFlow: true),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'CraftMatch',
      theme: buildAppTheme(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
