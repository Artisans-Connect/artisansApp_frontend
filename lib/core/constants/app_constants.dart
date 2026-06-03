import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';

  /// Placeholder redirect for email confirmation (dev). Replace with app deep link in production.
  static const String supabaseRedirectUrl =
      'https://qdeznjpvkhrxesjykovi.supabase.co';

  /// Override in `.env` as `EXPRESS_API_BASE_URL` (e.g. `http://localhost:3000/api`).
  static String get expressApiBaseUrl =>
      dotenv.env['EXPRESS_API_BASE_URL'] ?? 'http://localhost:3000/api';

  static const String avatarsBucket = 'avatars';
  static const String jobPhotosBucket = 'job-photos';

  /// Set GOOGLE_MAPS_API_KEY in .env; also configure native Android/iOS manifests.
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}
