import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/index.dart';
import 'worker_shell.dart';

class WorkerDevRouter extends StatelessWidget {
  const WorkerDevRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artisans — Worker',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Inter',
      ),
      home: const WorkerShell(),
    );
  }
}
