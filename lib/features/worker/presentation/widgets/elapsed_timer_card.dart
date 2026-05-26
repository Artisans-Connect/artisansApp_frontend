import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class ElapsedTimerCard extends StatefulWidget {
  const ElapsedTimerCard({super.key});

  @override
  State<ElapsedTimerCard> createState() => _ElapsedTimerCardState();
}

class _ElapsedTimerCardState extends State<ElapsedTimerCard> {
  Duration _elapsed = const Duration(hours: 0, minutes: 23, seconds: 47);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(WorkerSpacing.lg),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('TIME ELAPSED', style: WorkerTextStyles.labelCaps),
          const SizedBox(height: WorkerSpacing.sm),
          Text(
            _format(_elapsed),
            style: WorkerTextStyles.displayMd.copyWith(
              fontSize: 36,
              color: WorkerColors.primary,
            ),
          ),
          const SizedBox(height: WorkerSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: WorkerColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Active Session',
                style: WorkerTextStyles.bodyMd.copyWith(
                  color: WorkerColors.successDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
