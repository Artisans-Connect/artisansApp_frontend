import 'package:flutter/material.dart';

import '../screens/legal_document_screen.dart';

abstract final class LegalNavigation {
  static const String privacyTitle = 'Privacy Policy';
  static const String privacyAssetPath = 'assets/legal/privacy_policy.txt';
  static const String termsTitle = 'Terms of Service';
  static const String termsAssetPath = 'assets/legal/terms&conditions.txt';

  static Future<void> openPrivacyPolicy(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          title: privacyTitle,
          assetPath: privacyAssetPath,
        ),
      ),
    );
  }

  static Future<void> openTermsOfService(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LegalDocumentScreen(
          title: termsTitle,
          assetPath: termsAssetPath,
        ),
      ),
    );
  }
}
