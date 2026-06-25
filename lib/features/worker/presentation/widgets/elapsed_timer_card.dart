import 'package:artisans_app/core/theme/index.dart';
import 'dart:async';
import 'package:flutter/material.dart';
class ElapsedTimerCard extends StatefulWidget {
  const ElapsedTimerCard({super.key, this.startedAt});
  final DateTime? startedAt;

  @override
  State<ElapsedTimerCard> createState() => _ElapsedTimerCardState();
}
class _ElapsedTimerCardState extends State<ElapsedTimerCard> {
  late Duration _elapsed;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    final start = widget.startedAt ?? DateTime.now();
    _elapsed = DateTime.now().difference(start);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          final start = widget.startedAt ?? DateTime.now();
          _elapsed = DateTime.now().difference(start);
        });
      }
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('TIME ELAPSED', style: AppTypography.labelCaps),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _format(_elapsed),
            style: AppTypography.displayMedium.copyWith(
              fontSize: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Active Session',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.success,
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