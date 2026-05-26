import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import '../../widgets/dot_indicator.dart';
import '../../widgets/role_option_card.dart';
import 'complete_profile_step1_screen.dart';
import 'worker_trade_selection_screen.dart';

/// Step 1 of 3 in profile completion — role selection.
///
/// The user chooses whether they are a **client** (looking for workers)
/// or a **worker** (offering services).  The selection is passed forward
/// to subsequent profile-completion screens.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  static const String routeName = '/auth/role-selection';

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // ── Header bar ─────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  Text('Artisans',
                      style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('Step 1 of 3',
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 14),
                    Text(
                      'How will you use\nArtisans?',
                      textAlign: TextAlign.center,
                      style:
                          AppTextStyles.displayMd.copyWith(fontSize: 50 * 0.78),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select your primary role to customize your\nexperience and connect with the right people.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLg,
                    ),
                    const SizedBox(height: 24),
                    RoleOptionCard(
                      title: 'I need a worker',
                      subtitle:
                          'Find skilled professionals for your next project.',
                      icon: Icons.desktop_windows_outlined,
                      isSelected: _selectedRole == 'client',
                      onTap: () => setState(() => _selectedRole = 'client'),
                    ),
                    const SizedBox(height: 18),
                    RoleOptionCard(
                      title: 'I offer services',
                      subtitle: 'Showcase your skills and find new clients.',
                      icon: Icons.work_outline,
                      isSelected: _selectedRole == 'worker',
                      onTap: () => setState(() => _selectedRole = 'worker'),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Continue with Selection',
                      onPressed: _selectedRole == null
                          ? null
                          : () {
                              final OnboardingSession session =
                                  OnboardingSession.instance;
                              session.setRoleFromString(_selectedRole!);
                              if (_selectedRole == 'worker') {
                                Navigator.pushNamed(
                                  context,
                                  WorkerTradeSelectionScreen.routeName,
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  CompleteProfileStep1Screen.routeName,
                                );
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),

            // ── Dot indicator ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: const DotIndicator(totalDots: 3, activeIndex: 0),
            ),
          ],
        ),
      ),
    );
  }
}
