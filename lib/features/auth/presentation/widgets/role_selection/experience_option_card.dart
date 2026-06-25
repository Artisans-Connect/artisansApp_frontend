import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../../core/theme/design_tokens.dart';

class ExperienceDetail {
  const ExperienceDetail({
    required this.band,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String band;
  final String title;
  final String subtitle;
  final IconData icon;
}

const List<ExperienceDetail> experienceDetails = <ExperienceDetail>[
  ExperienceDetail(
    band: '0–1 years',
    title: 'Entry Level (0–1 years)',
    subtitle: 'Starting out, building experience and portfolio.',
    icon: PhosphorIcons.user,
  ),
  ExperienceDetail(
    band: '1–3 years',
    title: 'Junior (1–3 years)',
    subtitle: 'Completed training, working independently on standard jobs.',
    icon: PhosphorIcons.wrench,
  ),
  ExperienceDetail(
    band: '3–5 years',
    title: 'Intermediate (3–5 years)',
    subtitle: 'Experienced professional with a solid track record.',
    icon: PhosphorIcons.briefcase,
  ),
  ExperienceDetail(
    band: '5+ years',
    title: 'Expert / Master (5+ years)',
    subtitle: 'Seasoned craftsman with deep expertise and master status.',
    icon: PhosphorIcons.star,
  ),
];

class ExperienceOptionCard extends StatelessWidget {
  const ExperienceOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.primaryTint08 : DesignTokens.surfaceCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: isSelected ? DesignTokens.primary : DesignTokens.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isSelected
                  ? DesignTokens.primary.withAlpha((0.08 * 255).round())
                  : Colors.black.withAlpha((0.02 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? DesignTokens.primaryTint12
                    : DesignTokens.surfaceBase,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? DesignTokens.primary
                    : DesignTokens.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? DesignTokens.primary
                          : DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: DesignTokens.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? DesignTokens.primary
                      : DesignTokens.borderSubtle,
                  width: isSelected ? 6.0 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
