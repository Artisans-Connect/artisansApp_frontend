import '../utils/cache_logger.dart';
import 'cache_store.dart';

/// Cache-first fetch with optional background refresh.
class CachedFetch {
  CachedFetch._();

  /// Returns fresh cache when valid; otherwise calls [fetch], stores, and returns.
  static Future<T> get<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final T? cached = await CacheStore.instance.get<T>(key, ttl);
      if (cached != null) {
        CacheLogger.debug('Cache-first returning cached for: $key');
        return cached;
      }
    }

    CacheLogger.debug('Cache-first fetching fresh for: $key');
    final T fresh = await fetch();
    await CacheStore.instance.put(key, fresh);
    return fresh;
  }

  /// Returns cache immediately when present, then refreshes in the background.
  static Future<T> staleWhileRevalidate<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
    void Function(T fresh)? onRefreshed,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final T? cached = await CacheStore.instance.get<T>(key, ttl);
      if (cached != null) {
        CacheLogger.debug('Stale-while-revalidate returning cached for: $key');
        _refreshInBackground<T>(
          key: key,
          fetch: fetch,
          onRefreshed: onRefreshed,
        );
        return cached;
      }
    }

    CacheLogger.debug('Stale-while-revalidate fetching fresh for: $key');
    final T fresh = await fetch();
    await CacheStore.instance.put(key, fresh);
    return fresh;
  }

  static void _refreshInBackground<T>({
    required String key,
    required Future<T> Function() fetch,
    void Function(T fresh)? onRefreshed,
  }) {
    fetch().then((T fresh) async {
      await CacheStore.instance.put(key, fresh);
      onRefreshed?.call(fresh);
      CacheLogger.debug('Background refresh completed for: $key');
    }).catchError((Object error, StackTrace stackTrace) {
      CacheLogger.error(
        'Background refresh failed for: $key',
        error,
        stackTrace,
      );
    });
  }
}
