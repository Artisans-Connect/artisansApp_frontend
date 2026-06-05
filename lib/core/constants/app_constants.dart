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

  /// Placeholder redirect for email confirmation (dev). Replace with app deep link in production.
  static const String supabaseRedirectUrl =
      'https://qdeznjpvkhrxesjykovi.supabase.co';

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
}
