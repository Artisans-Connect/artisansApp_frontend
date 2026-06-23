import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/cache/cache_store.dart';
import 'core/constants/app_constants.dart';
import 'core/maps/google_maps_loader.dart';
import 'core/offline/job_post_queue.dart';
import 'core/services/notification_service.dart';
import 'features/client/data/job_draft_store.dart';
import 'features/worker/presentation/worker_dev_router.dart';

/// Set `--dart-define=WORKER_DEV=true` to preview worker UI.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await CacheStore.instance.init();
  await JobPostQueue.instance.init();
  await JobDraftStore.instance.init();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabasePublishableKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  try {
    await Firebase.initializeApp();
    await NotificationService.instance.initialize();
  } catch (_) {
    // Local builds can run without Firebase platform config.
  }

  await ensureGoogleMapsLoaded(AppConstants.googleMapsApiKey);
  if (AppConstants.mapboxAccessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(AppConstants.mapboxAccessToken);
  }

  const workerDev = bool.fromEnvironment('WORKER_DEV', defaultValue: false);
  runApp(workerDev ? const WorkerDevRouter() : const MyApp());
}

