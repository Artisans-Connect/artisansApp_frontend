import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/theme/design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper data class for trade entries
// ─────────────────────────────────────────────────────────────────────────────

class TradeEntry {
  const TradeEntry(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable local widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Pill-shaped progress step dots
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? DesignTokens.primary
                : DesignTokens.primary.withAlpha((0.22 * 255).round()),
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          ),
        );
      }),
    );
  }
}

/// Hero band shown at the top of each onboarding page.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.icon,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.totalDots,
    required this.currentDot,
  });

  final Widget icon;
  final Color bgColor;
  final String title;
  final String subtitle;
  final int totalDots;
  final int currentDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(DesignTokens.gutter, 28, DesignTokens.gutter, 22),
      decoration: const BoxDecoration(
        color: DesignTokens.surfaceCard,
        border: Border(
          bottom: BorderSide(color: DesignTokens.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: DesignTokens.borderSubtle, width: 1.5),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 14),
          StepDots(total: totalDots, current: currentDot),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: DesignTokens.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info strip used on the service areas page.
class InfoStrip extends StatelessWidget {
  const InfoStrip({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.primaryTint08,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: DesignTokens.primaryTint12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(PhosphorIcons.info, color: DesignTokens.primary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: DesignTokens.primaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section label (small caps, muted).
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

/// Trust signal chip shown in the Bio page.
class TrustChip extends StatelessWidget {
  const TrustChip({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: DesignTokens.primaryTint08,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(color: DesignTokens.primaryTint12),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: DesignTokens.primary, size: 18),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.05,
                color: DesignTokens.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter for the bio character-count ring
// ─────────────────────────────────────────────────────────────────────────────

class RingPainter extends CustomPainter {
  const RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.5;
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Track
    canvas.drawArc(
      rect,
      -1.5708, // -π/2  (12 o'clock)
      6.2832, // full circle
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Fill arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -1.5708,
        6.2832 * progress,
        false,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}
