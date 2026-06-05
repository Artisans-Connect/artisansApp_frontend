import 'dart:async';

import '../utils/cache_logger.dart';

/// Deduplicates concurrent API requests to prevent duplicate calls for the same cache key.
/// If a request for key K is already in-flight, subsequent callers wait for that result
/// instead of making another API call.
class RequestDeduplicator {
  RequestDeduplicator._();
  static final RequestDeduplicator instance = RequestDeduplicator._();

  final Map<String, Future<dynamic>> _pendingRequests = {};

  /// Executes [fetch] with automatic deduplication.
  ///
  /// If a request for [key] is already in-flight, returns that Future instead
  /// of making a duplicate call. This prevents race conditions and wasted bandwidth.
  Future<T> deduplicate<T>({
    required String key,
    required Future<T> Function() fetch,
  }) async {
    // Check if request is already in-flight
    if (_pendingRequests.containsKey(key)) {
      CacheLogger.debug('Request in-flight for key: $key, waiting...');
      try {
        final dynamic value = await _pendingRequests[key]!;
        return value as T;
      } catch (e) {
        // If pending request failed, allow a retry
        final removed = _pendingRequests.remove(key);
        if (removed != null) unawaited(removed);
        rethrow;
      }
    }

    // Start new fetch
    CacheLogger.debug('Starting new request for key: $key');
    final future = fetch();
    _pendingRequests[key] = future;

    try {
      final result = await future;
      CacheLogger.debug('Request completed for key: $key');
      return result;
    } catch (e) {
      CacheLogger.error('Request failed for key: $key', e);
      rethrow;
    } finally {
      final removed = _pendingRequests.remove(key);
      if (removed != null && !identical(removed, future)) {
        unawaited(removed);
      }
    }
  }

  /// Clears all pending request tracking (use with caution).
  void clearPending() {
    _pendingRequests.clear();
    CacheLogger.info('Cleared all pending requests');
  }

  /// Gets count of currently pending requests.
  int get pendingRequestCount => _pendingRequests.length;

  /// Gets list of keys with pending requests.
  List<String> get pendingKeys => _pendingRequests.keys.toList();
}
