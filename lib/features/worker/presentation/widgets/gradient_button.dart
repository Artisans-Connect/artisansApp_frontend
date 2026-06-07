import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.haptic = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final bool haptic;
  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed =
        enabled && !isLoading ? onPressed : null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveOnPressed == null
            ? null
            : () {
                if (haptic) {
                  HapticFeedback.lightImpact();
                }
                effectiveOnPressed();
              },
        borderRadius: BorderRadius.circular(12.0),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: effectiveOnPressed != null
                ? AppColors.primaryGradient
                : null,
            color: effectiveOnPressed == null
                ? AppColors.outlineVariant
                : null,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
class OutlineButton extends StatelessWidget {
  const OutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.haptic = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool haptic;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              if (haptic) HapticFeedback.lightImpact();
              onPressed!();
            },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}