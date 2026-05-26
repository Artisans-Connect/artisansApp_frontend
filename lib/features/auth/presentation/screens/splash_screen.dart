import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

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
    // Simulate startup tasks
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),

      // Add your real startup logic here:
      // check authentication
      // preload user data
      // initialize services
      // fetch remote config
    ]);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/auth/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF5B66E8),
              Color(0xFF4A79E6),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            const Spacer(flex: 3),

            // Logo container
            Container(
              height: 132,
              width: 132,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(42),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
              child: const Icon(
                Icons.build_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),

            const SizedBox(height: 28),

            // App title
            Text(
              'Artisans',
              style: AppTextStyles.displayLg.copyWith(
                color: Colors.white,
                fontSize: 72 * 0.78,
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle
            Text(
              'ELITE CRAFTSMANSHIP ON DEMAND',
              style: AppTextStyles.labelCaps.copyWith(
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 92),

            // Infinite flowing loading bar
            SizedBox(
              width: 224,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color.fromRGBO(
                    255,
                    255,
                    255,
                    0.2,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 4),

            // Footer
            Text(
              'POWERED BY',
              style: AppTextStyles.labelCaps.copyWith(
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'ArtisansConnect •',
              style: AppTextStyles.bodyLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 38),
          ],
        ),
      ),
    );
  }
}