import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/location/place_lookup_service.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/shared/widgets/app_input.dart';
import 'package:artisans_app/shared/models/onboarding_session.dart';
import 'package:artisans_app/features/auth/presentation/widgets/role_selection/experience_option_card.dart';
import 'package:artisans_app/features/auth/presentation/widgets/role_selection/onboarding_atoms.dart';

class ServiceAreasPage extends StatelessWidget {
  const ServiceAreasPage({
    super.key,
    required this.session,
    required this.totalDots,
    required this.currentDot,
    required this.areaSearchController,
    required this.areaSuggestions,
    required this.isSearchingAreas,
    required this.onAddArea,
    required this.onAreaSelected,
    required this.onAreaRemoved,
    required this.onExperienceSelected,
  });

  final OnboardingSession session;
  final int totalDots;
  final int currentDot;
  final TextEditingController areaSearchController;
  final List<PlaceSuggestion> areaSuggestions;
  final bool isSearchingAreas;
  final VoidCallback onAddArea;
  final ValueChanged<String> onAreaSelected;
  final ValueChanged<String> onAreaRemoved;
  final ValueChanged<String> onExperienceSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Hero header
          HeroHeader(
            icon: const Icon(
              PhosphorIcons.mapPin,
              color: Color(0xFF1D9E75),
              size: 34,
            ),
            bgColor: const Color(0xFFE1F5EE),
            title: 'Where do\nyou work?',
            subtitle:
                'Choose the areas you cover and how\nlong you\'ve been in the trade.',
            totalDots: totalDots,
            currentDot: currentDot,
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(DesignTokens.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── Areas ──
                const SectionLabel('Service areas'),
                AppInput(
                  controller: areaSearchController,
                  hint: "Search area (e.g. KNUST, Kumasi)",
                  prefixIcon: PhosphorIcons.mapPin,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (String val) => onAreaSelected(val),
                  suffixIcon: isSearchingAreas
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DesignTokens.primary,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            PhosphorIcons.plusCircle,
                            color: DesignTokens.primary,
                          ),
                          onPressed: onAddArea,
                        ),
                ),
                if (areaSuggestions.isNotEmpty ||
                    areaSearchController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: DesignTokens.surfaceCard,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(color: DesignTokens.borderSubtle),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withAlpha((0.04 * 255).round()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ...areaSuggestions.map((PlaceSuggestion suggestion) {
                            return ListTile(
                              dense: true,
                              leading: const Icon(PhosphorIcons.mapPin,
                                  size: 16, color: DesignTokens.textSecondary),
                              title: Text(
                                suggestion.description,
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: DesignTokens.textPrimary,
                                ),
                              ),
                              onTap: () => onAreaSelected(suggestion.description),
                            );
                          }),
                          if (areaSearchController.text.trim().isNotEmpty)
                            ListTile(
                              dense: true,
                              leading: const Icon(PhosphorIcons.plusCircle,
                                  size: 16, color: DesignTokens.primary),
                              title: Text(
                                "Add '${areaSearchController.text.trim()}' as custom area",
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.primary,
                                ),
                              ),
                              onTap: onAddArea,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (session.serviceAreas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: session.serviceAreas.map((String area) {
                      return Chip(
                        label: Text(
                          area,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.primaryDark,
                          ),
                        ),
                        backgroundColor: DesignTokens.primaryTint08,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusMd),
                          side: const BorderSide(
                              color: DesignTokens.primaryTint12),
                        ),
                        deleteIcon: const Icon(
                          PhosphorIcons.x,
                          size: 14,
                          color: DesignTokens.primary,
                        ),
                        onDeleted: () => onAreaRemoved(area),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: DesignTokens.lg),

                // ── Experience ──
                const SectionLabel('Experience level'),
                Column(
                  children: experienceDetails.map((ExperienceDetail detail) {
                    final bool isSelected =
                        session.experienceBand == detail.band;
                    return ExperienceOptionCard(
                      title: detail.title,
                      subtitle: detail.subtitle,
                      icon: detail.icon,
                      isSelected: isSelected,
                      onTap: () => onExperienceSelected(detail.band),
                    );
                  }).toList(),
                ),

                const SizedBox(height: DesignTokens.md),
                const InfoStrip(
                  text:
                      'Hourly rates are negotiated per job — you set them after accepting a request.',
                ),
                const SizedBox(height: DesignTokens.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
