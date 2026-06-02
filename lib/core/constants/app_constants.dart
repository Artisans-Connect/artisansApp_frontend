import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
  
  // Assuming localhost for now as requested by user
  static const String expressApiBaseUrl = 'http://localhost:3000/api'; 
  // Note: 10.0.2.2 is the alias for localhost in Android Emulator. 
  // For iOS Simulator, it would be 127.0.0.1 or localhost.
  
  static const String avatarsBucket = 'avatars';
  static const String jobPhotosBucket = 'job-photos';

  /// Set GOOGLE_MAPS_API_KEY in .env; also configure native Android/iOS manifests.
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}
