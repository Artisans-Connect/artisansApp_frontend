import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';

class ClientContactRow extends StatelessWidget {
  const ClientContactRow({
    super.key,
    required this.onMessage,
    required this.onCall,
    this.showOnlineDot = true,
  });

  final VoidCallback onMessage;
  final VoidCallback onCall;
  final bool showOnlineDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(icon: PhosphorIcons.chatCircle(), onTap: onMessage),
        const SizedBox(width: AppSpacing.sm),
        _ActionButton(icon: PhosphorIcons.phone(), onTap: onCall),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryFixed,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}
