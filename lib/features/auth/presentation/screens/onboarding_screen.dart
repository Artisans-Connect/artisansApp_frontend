import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../widgets/dot_indicator.dart';
import '../../widgets/onboarding_page_content.dart';

/// Two-page introductory onboarding screen shown after the splash and
/// before the sign-in / sign-up flow.
///
/// Users swipe through value-proposition pages or tap "Next" / "Get
/// Started".  A "Skip" shortcut in the header jumps directly to the
/// sign-in screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/auth/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalPages = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToSignIn() {
    Navigator.pushReplacementNamed(context, '/auth/sign-in');
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Header ────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: <Widget>[
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Icon(PhosphorIcons.caretLeft(),
                          color: AppColors.primary, size: 20),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 8),
                  Text(
                    'Artisans',
                    style: AppTextStyles.displayMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _goToSignIn,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page content ──────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                children: <Widget>[
                  // Page 1: Client value-proposition
                  OnboardingPageContent(
                    heroIcon: PhosphorIcons.shieldCheck(),
                    heroGradientColors: <Color>[
                      Color(0xFF1B1B2F),
                      Color(0xFF2D3561),
                    ],
                    badgeIcon: PhosphorIcons.shield(),
                    badgeLabel: 'Trusted Experts',
                    badgeSubtitle: 'Vetted for quality',
                    title: 'Find help in minutes',
                    subtitle:
                        'Access a network of elite professionals\nready to solve your problems instantly.',
                  ),

                  // Page 2: Worker value-proposition
                  OnboardingPageContent(
                    heroIcon: PhosphorIcons.trendUp(),
                    heroGradientColors: <Color>[
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                    ],
                    badgeIcon: PhosphorIcons.wallet(),
                    badgeLabel: 'Weekly Earnings',
                    badgeSubtitle: 'Grow your revenue',
                    title: 'Earn as an Artisan',
                    subtitle:
                        'Connect with clients in your neighborhood,\nshowcase your skills, and grow your\nrevenue with our premium toolkit.',
                  ),
                ],
              ),
            ),

            // ── Dot indicator ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DotIndicator(
                totalDots: _totalPages,
                activeIndex: _currentPage,
              ),
            ),

            // ── Action button ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.sizeOf(context).height < 640 ? 16 : 24,
                24,
                8,
              ),
              child: GradientButton(
                label: _currentPage < _totalPages - 1 ? 'Next' : 'Get Started',
                trailingIcon: PhosphorIcons.arrowRight(),
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
