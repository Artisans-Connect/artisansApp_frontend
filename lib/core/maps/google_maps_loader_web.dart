import 'dart:async';

import 'package:web/web.dart' as web;

const String _scriptMarker = 'data-artisans-google-maps';

/// Injects the Maps JavaScript API so [GoogleMap] works on Flutter web.
Future<void> ensureGoogleMapsLoaded(String apiKey) async {
  if (apiKey.isEmpty) return;

  final web.Element? existing =
      web.document.querySelector('script[$_scriptMarker]');
  if (existing != null) return;

  final completer = Completer<void>();
  final script = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..async = true
    ..defer = true
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
    ..setAttribute(_scriptMarker, 'true');

  script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError('Failed to load Google Maps JavaScript API'),
      );
    }
  });

  web.document.head!.appendChild(script as web.Node);

  try {
    await completer.future.timeout(const Duration(seconds: 15));
  } on TimeoutException {
    // Map widgets may still retry once the script finishes loading.
  }
}
