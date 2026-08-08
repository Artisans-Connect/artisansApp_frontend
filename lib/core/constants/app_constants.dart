import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String? _env(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  static String get supabaseUrl => _env('SUPABASE_URL') ?? '';
  static String get supabasePublishableKey =>
      _env('SUPABASE_PUBLISHABLE_KEY') ?? '';

  /// Redirect used after Supabase OAuth sign-ins.
  /// Configure `SUPABASE_OAUTH_REDIRECT_URL` for the target platform.
  static String get supabaseOAuthRedirectUrl =>
      _env('SUPABASE_OAUTH_REDIRECT_URL') ?? supabaseRedirectUrl;

  /// Redirect used after password recovery emails.
  /// Configure `SUPABASE_PASSWORD_RESET_REDIRECT_URL` when a separate callback is needed.
  static String get supabasePasswordResetRedirectUrl {
    final String baseUrl = _env('SUPABASE_PASSWORD_RESET_REDIRECT_URL') ??
        supabasePasswordResetFallbackUrl;
    final String separator = baseUrl.contains('?') ? '&' : '?';
    if (kIsWeb) {
      return '$baseUrl${separator}source=web&redirect_to=${Uri.encodeComponent(Uri.base.origin)}';
    } else {
      return '$baseUrl${separator}source=app';
    }
  }

  /// Deep link redirect for email confirmation. Falls back to verification portal if app is not installed.
  static String get supabaseRedirectUrl {
    final String portalUrl = verificationPortalUrl.endsWith('/')
        ? verificationPortalUrl.substring(0, verificationPortalUrl.length - 1)
        : verificationPortalUrl;
    return '$portalUrl/email-verified';
  }

  static String get supabasePasswordResetFallbackUrl {
    final String portalUrl = verificationPortalUrl.endsWith('/')
        ? verificationPortalUrl.substring(0, verificationPortalUrl.length - 1)
        : verificationPortalUrl;
    return '$portalUrl/update-password';
  }

  /// Resolves local backend for development testing across Android emulator (10.0.2.2) and Web/Desktop (localhost).
  static String get expressApiBaseUrl {
    final String? configured = _env('EXPRESS_API_BASE_URL');
    if (configured != null && configured.isNotEmpty) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && configured.contains('localhost')) {
        return configured.replaceAll('localhost', '10.0.2.2');
      }
      return configured;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  /// Resolves local verification portal for development testing across Android emulator (10.0.2.2) and Web/Desktop (localhost).
  static String get verificationPortalUrl {
    final String configured = _env('VERIFICATION_PORTAL_URL') ?? 'http://localhost:5173/';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && configured.contains('localhost')) {
      return configured.replaceAll('localhost', '10.0.2.2');
    }
    return configured;
  }

  static const String avatarsBucket = 'avatars';
  static const String jobPhotosBucket = 'job-photos';
  static const String chatMediaBucket = 'chat-media';
  static const String completionPhotosBucket = 'completion-photos';
  static const String reportEvidenceBucket = 'report-evidence';

  /// Set GOOGLE_MAPS_API_KEY in .env; also configure native Android/iOS manifests.
  static String get googleMapsApiKey => _env('GOOGLE_MAPS_API_KEY') ?? '';

  /// Set MAPBOX_ACCESS_TOKEN in .env for client-facing embedded Mapbox maps.
  static String get mapboxAccessToken => _env('MAPBOX_ACCESS_TOKEN') ?? '';

  /// Set FIREBASE_VAPID_KEY in .env for web FCM push notifications.
  static String get firebaseVapidKey => _env('FIREBASE_VAPID_KEY') ?? '';
}
