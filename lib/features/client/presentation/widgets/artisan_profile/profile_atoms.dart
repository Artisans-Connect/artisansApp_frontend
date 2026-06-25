import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../../core/theme/design_tokens.dart';

/// Small caps section label
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08,
          color: DesignTokens.textSecondary,
        ),
      ),
    );
  }
}
 
/// Star row — filled vs unfilled based on rating integer.
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 14});
  final int rating;
  final double size;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int i) {
        return Icon(
          i < rating ? PhosphorIcons.starFill : PhosphorIcons.star,
          size: size,
          color: i < rating ? DesignTokens.accentGold : DesignTokens.warmBorder,
        );
      }),
    );
  }
}
 
/// Service chip pill
class ServiceChip extends StatelessWidget {
  const ServiceChip(this.label, {super.key});
  final String label;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DesignTokens.warmTint,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(color: DesignTokens.warmBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: DesignTokens.primaryDark,
        ),
      ),
    );
  }
}
 
/// Quick action button (Call / Chat) shown in the identity strip.
class QuickActionBtn extends StatelessWidget {
  const QuickActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
  });
 
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool loading;
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: DesignTokens.surfaceBase,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(color: DesignTokens.borderSubtle),
          ),
          child: loading
              ? const SizedBox(
                  height: 18,
                  child: Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(DesignTokens.primary),
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, color: DesignTokens.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
 
/// Hero fallback — shown when no image URL or image fails to load
class HeroFallback extends StatelessWidget {
  const HeroFallback({super.key, required this.initials});
  final String initials;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignTokens.warmTint,
      alignment: Alignment.center,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: DesignTokens.primaryTint08,
          shape: BoxShape.circle,
          border: Border.all(color: DesignTokens.warmBorder, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: DesignTokens.primary,
          ),
        ),
      ),
    );
  }
}
