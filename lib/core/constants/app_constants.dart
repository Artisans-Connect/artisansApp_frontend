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
  static String get supabasePasswordResetRedirectUrl =>
      _env('SUPABASE_PASSWORD_RESET_REDIRECT_URL') ??
      supabasePasswordResetFallbackUrl;

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

  /// Override in `.env` as `EXPRESS_API_BASE_URL` (e.g. `https://artisansapp-backend.onrender.com/api`).
  static String get expressApiBaseUrl =>
      _env('EXPRESS_API_BASE_URL') ??
      'https://artisansapp-backend.onrender.com/api';

  static String get verificationPortalUrl =>
      _env('VERIFICATION_PORTAL_URL') ??
      'https://craft-match-verification-portal.vercel.app/';

  static const String avatarsBucket = 'avatars';
  static const String jobPhotosBucket = 'job-photos';
  static const String chatMediaBucket = 'chat-media';
  static const String completionPhotosBucket = 'completion-photos';

  /// Set GOOGLE_MAPS_API_KEY in .env; also configure native Android/iOS manifests.
  static String get googleMapsApiKey => _env('GOOGLE_MAPS_API_KEY') ?? '';

  /// Set MAPBOX_ACCESS_TOKEN in .env for client-facing embedded Mapbox maps.
  static String get mapboxAccessToken => _env('MAPBOX_ACCESS_TOKEN') ?? '';
}
