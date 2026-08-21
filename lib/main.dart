import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:artisans_app/app.dart';
import 'package:artisans_app/core/cache/cache_store.dart';
import 'package:artisans_app/core/constants/app_constants.dart';
import 'package:artisans_app/core/maps/google_maps_loader.dart';
import 'package:artisans_app/core/offline/job_post_queue.dart';
import 'package:artisans_app/core/services/auth_service.dart';
import 'package:artisans_app/core/services/notification_service.dart';
import 'package:artisans_app/features/client/data/job_draft_store.dart';
import 'package:artisans_app/features/client/data/hidden_bookings_store.dart';
import 'package:artisans_app/features/worker/presentation/worker_dev_router.dart';

/// Set `--dart-define=WORKER_DEV=true` to preview worker UI.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await CacheStore.instance.init();
  await JobPostQueue.instance.init();
  await JobDraftStore.instance.init();
  await HiddenBookingsStore.instance.init();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabasePublishableKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  // Pre-initialize Google Sign-in asynchronously to avoid popup blockers on Web
  AuthService.instance.preInitializeGoogleSignIn().catchError((e) {
    // Silently ignore or log pre-initialization failures
  });

  try {
    await Firebase.initializeApp();
    await NotificationService.instance.initialize();
  } catch (_) {
    // Local builds can run without Firebase platform config.
  }

  await ensureGoogleMapsLoaded(AppConstants.googleMapsApiKey);
  if (AppConstants.mapboxAccessToken.isNotEmpty && !kIsWeb) {
    MapboxOptions.setAccessToken(AppConstants.mapboxAccessToken);
  }

  const workerDev = bool.fromEnvironment('WORKER_DEV', defaultValue: false);
  runApp(workerDev ? const WorkerDevRouter() : const MyApp());
}

