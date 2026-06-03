import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
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
        _ActionButton(icon: PhosphorIcons.chatCircle, onTap: onMessage),
        const SizedBox(width: AppSpacing.sm),
        _ActionButton(icon: PhosphorIcons.phone, onTap: onCall),
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