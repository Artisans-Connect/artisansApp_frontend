import 'package:flutter/material.dart';
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
        _ActionButton(icon: Icons.chat_bubble_outline_rounded, onTap: onMessage),
        const SizedBox(width: WorkerSpacing.sm),
        _ActionButton(icon: Icons.phone_outlined, onTap: onCall),
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
      color: WorkerColors.primaryFixed,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: WorkerColors.primary, size: 22),
        ),
      ),
    );
  }
}
