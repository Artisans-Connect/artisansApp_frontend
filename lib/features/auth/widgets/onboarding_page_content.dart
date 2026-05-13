import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A single onboarding page rendered inside the [PageView] of the
/// onboarding screen.
///
/// Each page shows a large icon-based hero card, a floating badge chip,
/// a title, and a subtitle — matching the deprecated onboarding mockups
/// while remaining self-contained (no external image assets).
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.heroIcon,
    required this.heroGradientColors,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.badgeSubtitle,
    required this.title,
    required this.subtitle,
  });

  /// Primary icon displayed in the hero card.
  final IconData heroIcon;

  /// Gradient colors for the hero card background.
  final List<Color> heroGradientColors;

  /// Icon for the floating badge chip.
  final IconData badgeIcon;

  /// Label text for the badge chip.
  final String badgeLabel;

  /// Subtitle text for the badge chip.
  final String badgeSubtitle;

  /// Page headline.
  final String title;

  /// Page body copy.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 24),

          // ── Hero card ──────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: heroGradientColors,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: heroGradientColors.last.withOpacity(0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    // Decorative circles
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    // Main icon
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Icon(heroIcon, color: Colors.white, size: 56),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating badge chip
              Positioned(
                bottom: -22,
                left: 24,
                right: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        child: Icon(badgeIcon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              badgeLabel,
                              style: AppTextStyles.bodyLg.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(badgeSubtitle, style: AppTextStyles.bodyMd),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 44),

          // ── Title ──────────────────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMd.copyWith(fontSize: 28),
          ),

          const SizedBox(height: 12),

          // ── Subtitle ───────────────────────────────────────────────
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLg,
          ),
        ],
      ),
    );
  }
}
