import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/index.dart';

/// Shared scaffold: optional top bar, scrollable body, optional bottom bars.
class WorkerScrollScaffold extends StatelessWidget {
  const WorkerScrollScaffold({
    super.key,
    this.topBar,
    required this.body,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor = AppColors.background,
  });

  final Widget? topBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (topBar != null) topBar!,
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
    );
  }
}
