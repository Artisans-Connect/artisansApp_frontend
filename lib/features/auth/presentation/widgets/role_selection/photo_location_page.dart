import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/widgets/app_input.dart';
import '../../../../../shared/widgets/picked_media_image.dart';
import '../../../../../shared/models/picked_media.dart';
import '../../../models/onboarding_session.dart';
import 'onboarding_atoms.dart';

class PhotoLocationPage extends StatelessWidget {
  const PhotoLocationPage({
    super.key,
    required this.session,
    required this.imageFile,
    required this.locationController,
    required this.phoneController,
    required this.isLoadingLocation,
    required this.onPickImage,
    required this.onAutoDetectLocation,
    required this.isGoogleUser,
  });

  final OnboardingSession session;
  final PickedMedia? imageFile;
  final TextEditingController locationController;
  final TextEditingController phoneController;
  final bool isLoadingLocation;
  final VoidCallback onPickImage;
  final VoidCallback onAutoDetectLocation;
  final bool isGoogleUser;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.gutter),
      child: Column(
        children: <Widget>[
          Text(
            'Complete Your Profile',
            style: AppTypography.displayMedium.copyWith(fontSize: 58 * 0.78),
          ),
          const SizedBox(height: 10),
          Text(
            "Let's put a face to the name and finalize\nyour setup.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 22),
          Container(
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
                // Avatar picker
                Center(
                  child: GestureDetector(
                    onTap: onPickImage,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DesignTokens.warmSurface,
                            border: Border.all(
                              color: DesignTokens.borderSubtle,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                          ),
                          child: imageFile != null
                              ? ClipOval(
                                  child: PickedMediaImage(
                                    media: imageFile!,
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                )
                              : Icon(PhosphorIcons.cameraPlus,
                                  color: DesignTokens.textSecondary, size: 42),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: DesignTokens.primary,
                            child: const Icon(
                              PhosphorIcons.pencilSimple,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'UPLOAD PROFILE PICTURE',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.08,
                      color: DesignTokens.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account type display
                const SectionLabel('Account type'),
                Container(
                  padding: const EdgeInsets.all(DesignTokens.md),
                  decoration: BoxDecoration(
                    color: DesignTokens.warmSurface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    border: Border.all(color: DesignTokens.borderSubtle),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: session.isClient
                            ? DesignTokens.primaryTint12
                            : DesignTokens.primaryTint12,
                        child: Icon(
                          session.isClient
                              ? PhosphorIcons.desktop
                              : PhosphorIcons.identificationCard,
                          color: DesignTokens.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'SELECTED ROLE',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.08,
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                            Text(
                              session.isClient
                                  ? 'Client Profile'
                                  : 'Worker Profile',
                              style: const TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: DesignTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(PhosphorIcons.checkCircle,
                          color: DesignTokens.successGreen, size: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Location input
                const SectionLabel('Location'),
                AppInput(
                  controller: locationController,
                  hint: 'e.g., KNUST, Kumasi',
                  prefixIcon: PhosphorIcons.mapPin,
                  suffixIcon: isLoadingLocation
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
                            PhosphorIcons.crosshair,
                            color: DesignTokens.primary,
                          ),
                          onPressed: onAutoDetectLocation,
                        ),
                ),

                if (isGoogleUser ||
                    session.phone == null ||
                    session.phone!.trim().length < 8 ||
                    session.phone!.trim() == '0000000000') ...<Widget>[
                  const SizedBox(height: 22),
                  // Contact input
                  const SectionLabel('Contact Number'),
                  AppInput(
                    controller: phoneController,
                    hint: 'e.g., +233 24 123 4567',
                    prefixIcon: PhosphorIcons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
