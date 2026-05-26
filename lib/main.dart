import 'package:flutter/material.dart';

import 'app.dart';
import 'features/worker/presentation/worker_dev_router.dart';

/// Set `--dart-define=WORKER_DEV=true` to preview worker UI.
void main() {
  const workerDev = bool.fromEnvironment('WORKER_DEV', defaultValue: false);
  runApp(workerDev ? const WorkerDevRouter() : const MyApp());
}
