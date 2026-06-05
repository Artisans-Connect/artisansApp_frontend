import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/verify_email_screen.dart';
import 'features/worker/presentation/worker_shell.dart';
import 'features/client/presentation/client_shell.dart';
import 'shared/presentation/screens/chat_detail_screen.dart';
import 'shared/presentation/screens/edit_profile_screen.dart';
import 'shared/presentation/screens/job_receipt_screen.dart';
import 'shared/presentation/screens/messages_list_screen.dart';
import 'shared/presentation/screens/settings_screen.dart';
import 'shared/presentation/screens/user_profile_screen.dart';
import 'core/services/notification_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.drainPendingNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ArtisansConnect',
      theme: buildAppTheme(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashScreen(),
        '/auth/splash': (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        RoleSelectionScreen.routeName: (_) => const RoleSelectionScreen(),
        SignInScreen.routeName: (_) => const SignInScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        VerifyEmailScreen.routeName: (BuildContext context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          return VerifyEmailScreen(email: args is String ? args : '');
        },
        MessagesListScreen.routeName: (_) => const MessagesListScreen(),
        ChatDetailScreen.routeName: (_) => const ChatDetailScreen(),
        UserProfileScreen.routeName: (_) => const UserProfileScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        JobReceiptScreen.routeName: (_) => const JobReceiptScreen(),
        WorkerShell.routeName: (BuildContext context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          final String? jobId = args is Map
              ? args['openJobRequestId'] as String?
              : null;
          return WorkerShell(initialJobRequestId: jobId);
        },
        ClientShell.routeName: (_) => const ClientShell(),
      },
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
