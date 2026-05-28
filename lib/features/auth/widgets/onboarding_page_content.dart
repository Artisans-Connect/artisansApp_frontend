import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A single onboarding page rendered inside the [PageView] of the
/// onboarding screen.
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

  final IconData heroIcon;
  final List<Color> heroGradientColors;
  final IconData badgeIcon;
  final String badgeLabel;
  final String badgeSubtitle;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxHeight = constraints.maxHeight;
        final double maxWidth = constraints.maxWidth;

        // Scale hero and typography for short viewports (e.g. small phones).
        final double heroHeight = (maxHeight * 0.46).clamp(160.0, 300.0);
        final double heroIconSize = (heroHeight * 0.22).clamp(40.0, 56.0);
        final double heroIconBox = (heroHeight * 0.32).clamp(72.0, 120.0);
        final double topGap = (maxHeight * 0.02).clamp(4.0, 20.0);
        final double afterHeroGap =
            (maxHeight * 0.06).clamp(28.0, 40.0) + 22; // badge overhang
        final double titleSize =
            maxHeight < 520 ? 22.0 : (maxWidth < 340 ? 24.0 : 28.0);
        final double horizontalPad = maxWidth < 360 ? 16.0 : 24.0;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: topGap),
                _HeroSection(
                  height: heroHeight,
                  heroIcon: heroIcon,
                  heroIconSize: heroIconSize,
                  heroIconBox: heroIconBox,
                  heroGradientColors: heroGradientColors,
                  badgeIcon: badgeIcon,
                  badgeLabel: badgeLabel,
                  badgeSubtitle: badgeSubtitle,
                ),
                SizedBox(height: afterHeroGap),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.displayMd.copyWith(
                    fontSize: titleSize,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: maxHeight < 520 ? 14.0 : null,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: topGap),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.height,
    required this.heroIcon,
    required this.heroIconSize,
    required this.heroIconBox,
    required this.heroGradientColors,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.badgeSubtitle,
  });

  final double height;
  final IconData heroIcon;
  final double heroIconSize;
  final double heroIconBox;
  final List<Color> heroGradientColors;
  final IconData badgeIcon;
  final String badgeLabel;
  final String badgeSubtitle;

  @override
  Widget build(BuildContext context) {
    final double badgeAvatarRadius = (height * 0.055).clamp(18.0, 22.0);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: height,
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
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -height * 0.12,
                right: -height * 0.12,
                child: Container(
                  width: height * 0.42,
                  height: height * 0.42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -height * 0.08,
                left: -height * 0.08,
                child: Container(
                  width: height * 0.32,
                  height: height * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: heroIconBox,
                  height: heroIconBox,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(heroIconBox * 0.3),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Icon(heroIcon, color: Colors.white, size: heroIconSize),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -20,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: badgeAvatarRadius,
                  backgroundColor: AppColors.primary,
                  child: Icon(badgeIcon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        badgeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        badgeSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
