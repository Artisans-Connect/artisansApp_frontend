import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/widgets/app_input.dart';
import '../../../models/onboarding_session.dart';
import 'onboarding_atoms.dart';

class BioPage extends StatelessWidget {
  const BioPage({
    super.key,
    required this.session,
    required this.bioController,
    required this.bioFormKey,
    required this.totalDots,
    required this.currentDot,
  });

  final OnboardingSession session;
  final TextEditingController bioController;
  final GlobalKey<FormState> bioFormKey;
  final int totalDots;
  final int currentDot;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Hero header
          HeroHeader(
            icon: const Icon(
              PhosphorIcons.userCircle,
              color: DesignTokens.primary,
              size: 34,
            ),
            bgColor: DesignTokens.primaryTint12,
            title: session.isClient
                ? 'Tell us about\nyourself'
                : 'Write your\nprofessional bio',
            subtitle: session.isClient
                ? 'A quick intro helps artisans know\nwho they\'re working with.'
                : 'A great bio gets you hired faster.\nKeep it honest and specific.',
            totalDots: totalDots,
            currentDot: currentDot,
          ),

          // Body
          Form(
            key: bioFormKey,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.gutter),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.gutter),
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceCard,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                  border: Border.all(color: DesignTokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Label + character ring row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SectionLabel(
                          session.isClient ? 'About you' : 'Professional bio',
                        ),
                        // Character count ring
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: bioController,
                          builder: (BuildContext context,
                              TextEditingValue value, Widget? _) {
                            final int count = value.text.length;
                            const int maxLen = 250;
                            final double progress = count / maxLen;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CustomPaint(
                                    painter: RingPainter(
                                      progress: progress.clamp(0, 1),
                                      trackColor: DesignTokens.borderSubtle,
                                      fillColor: progress > 0.9
                                          ? DesignTokens.error
                                          : DesignTokens.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$count/$maxLen',
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 11,
                                    color: DesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                    // Textarea
                    AppInput(
                      controller: bioController,
                      hint: session.isClient
                          ? 'What kind of help do you usually need?'
                          : 'Tell clients about your background and work ethic…',
                      maxLines: 4,
                      maxLength: 250,
                      validator: (String? value) {
                        if ((value ?? '').trim().length < 10) {
                          return 'Bio should be at least 10 characters.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Trust signal chips
                    const SectionLabel('Your profile will show'),
                    Row(
                      children: const <Widget>[
                        TrustChip(
                          icon: PhosphorIcons.star,
                          label: 'Verified\ntrades',
                        ),
                        SizedBox(width: 8),
                        TrustChip(
                          icon: PhosphorIcons.clock,
                          label: 'Response\ntime',
                        ),
                        SizedBox(width: 8),
                        TrustChip(
                          icon: PhosphorIcons.checkCircle,
                          label: 'Job\nhistory',
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Guidelines note
                    const Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'By continuing you agree to our ',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 12,
                            color: DesignTokens.textSecondary,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Community Guidelines',
                              style: TextStyle(
                                color: DesignTokens.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
