import 'package:flutter/material.dart';
import 'theme/worker_colors.dart';
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
        scaffoldBackgroundColor: WorkerColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: WorkerColors.primary,
          primary: WorkerColors.primary,
          surface: WorkerColors.surface,
        ),
        fontFamily: 'Inter',
      ),
      home: const WorkerShell(),
    );
  }
}
