import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artisans_app/core/theme/app_theme.dart';
import 'package:artisans_app/core/navigation/app_router.dart';
import 'package:artisans_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:artisans_app/features/worker/presentation/worker_shell.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_bottom_nav.dart';
import 'package:artisans_app/features/client/presentation/client_shell.dart';
import 'package:artisans_app/shared/presentation/screens/chat_detail_screen.dart';
import 'package:artisans_app/shared/presentation/screens/edit_profile_screen.dart';
import 'package:artisans_app/shared/presentation/screens/job_receipt_screen.dart';
import 'package:artisans_app/shared/presentation/screens/messages_list_screen.dart';
import 'package:artisans_app/shared/presentation/screens/settings_screen.dart';
import 'package:artisans_app/shared/presentation/screens/user_profile_screen.dart';
import 'package:artisans_app/core/services/notification_service.dart';
import 'package:artisans_app/features/trust_safety/presentation/screens/my_reports_screen.dart';
import 'package:artisans_app/features/trust_safety/presentation/screens/blocked_users_screen.dart';
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
        NotificationService.instance.navigatorKey.currentState?.pushNamed(
          ForgotPasswordScreen.routeName,
          arguments: const ForgotPasswordScreenArgs(isRecoveryFlow: true),
        );
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
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
