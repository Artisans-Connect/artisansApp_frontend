import 'package:flutter/material.dart';
import '../../../core/navigation/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to client home after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.build,
                size: 40,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Artisans",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "ELITE CRAFTSMANSHIP ON DEMAND",
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // Progress bar
            Container(
              width: 120,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Footer
            Column(
              children: const [
                Text(
                  "POWERED BY",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "ArtisansConnect",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}