import 'package:flutter/foundation.dart';

class PlatformService {
  PlatformService._();

  /// Whether the app is running on Flutter Web (either browser tab or PWA).
  static bool get isWeb => kIsWeb;

  /// Whether the app is running on native mobile (Android/iOS).
  static bool get isMobile => !kIsWeb;

  /// Whether camera hardware capture (`ImageSource.camera`) is supported.
  /// On Web browsers, gallery file input is supported, but native camera capture stream via image_picker is unreliable.
  static bool get supportsCamera => !kIsWeb;

  /// Whether native device location/app settings dialogs can be launched.
  static bool get supportsNativeSettings => !kIsWeb;

  /// Whether background location stream tracking is supported.
  /// PWA location streams stop when browser tabs/apps go into background.
  static bool get supportsBackgroundLocation => !kIsWeb;
}
