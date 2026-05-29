import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'features/worker/presentation/worker_dev_router.dart';

/// Set `--dart-define=WORKER_DEV=true` to preview worker UI.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  const workerDev = bool.fromEnvironment('WORKER_DEV', defaultValue: false);
  runApp(workerDev ? const WorkerDevRouter() : const MyApp());
}

