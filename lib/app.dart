import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/complete_profile_step1_screen.dart';
import 'features/auth/presentation/screens/complete_profile_step2_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/role_selection_screen.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'shared/presentation/screens/chat_detail_screen.dart';
import 'shared/presentation/screens/messages_list_screen.dart';
import 'shared/presentation/screens/settings_screen.dart';
import 'shared/presentation/screens/user_profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artisans',
      theme: buildAppTheme(),
      initialRoute: SplashScreen.routeName,
      routes: <String, WidgetBuilder>{
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        RoleSelectionScreen.routeName: (_) => const RoleSelectionScreen(),
        SignInScreen.routeName: (_) => const SignInScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        CompleteProfileStep1Screen.routeName: (_) =>
            const CompleteProfileStep1Screen(),
        CompleteProfileStep2Screen.routeName: (_) =>
            const CompleteProfileStep2Screen(),
        MessagesListScreen.routeName: (_) => const MessagesListScreen(),
        ChatDetailScreen.routeName: (_) => const ChatDetailScreen(),
        UserProfileScreen.routeName: (_) => const UserProfileScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
