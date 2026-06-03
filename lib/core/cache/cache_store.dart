import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../utils/cache_logger.dart';
import 'cache_keys.dart';

const String _boxName = 'api_cache';
const int _cacheVersion = 1; // Increment when cache schema changes

/// Persistent TTL cache for JSON-serializable API payloads (Hive).
class CacheStore {
  CacheStore._();
  static final CacheStore instance = CacheStore._();

  Box<String>? _box;

  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<String>(_boxName);
        CacheLogger.info('Cache box opened: $_boxName');
      } else {
        _box = Hive.box<String>(_boxName);
        CacheLogger.debug('Cache box already open: $_boxName');
      }
      await _validateCacheVersion();
    } catch (e, st) {
      CacheLogger.error('Failed to initialize cache box', e, st);
      rethrow;
    }
  }

  /// Validates and upgrades cache version if needed.
  Future<void> _validateCacheVersion() async {
    final box = _box;
    if (box == null) return;

    try {
      final storedVersion = box.get('__cache_version__') as int?;
      if (storedVersion == null || storedVersion < _cacheVersion) {
        CacheLogger.info(
          'Cache version mismatch: stored=$storedVersion, current=$_cacheVersion. Clearing cache.',
        );
        await box.clear();
        await box.put('__cache_version__', _cacheVersion);
      }
    } catch (e, st) {
      CacheLogger.error('Error validating cache version', e, st);
    }
  }

  Future<T?> get<T>(
    String key,
    Duration ttl, {
    T Function(dynamic json)? decode,
  }) async {
    final raw = _box?.get(key);
    if (raw == null) {
      CacheLogger.debug('Cache miss for key: $key');
      return null;
    }

    try {
      final Map<String, dynamic> envelope =
          Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final int? cachedAtMs = envelope['cachedAt'] as int?;
      final int? version = envelope['version'] as int? ?? 0;
      final dynamic data = envelope['data'];
      
      if (cachedAtMs == null || data == null) {
        CacheLogger.warning('Invalid cache envelope for key: $key (missing cachedAt or data)');
        await _box?.delete(key);
        return null;
      }

      // Invalidate cache if version doesn't match
      if (version != _cacheVersion) {
        CacheLogger.debug(
          'Cache version mismatch for key: $key (stored=$version, current=$_cacheVersion)',
        );
        await _box?.delete(key);
        return null;
      }

      final DateTime cachedAt =
          DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
      final Duration age = DateTime.now().difference(cachedAt);
      if (age > ttl) {
        CacheLogger.debug('Cache expired for key: $key (age: ${age.inSeconds}s, ttl: ${ttl.inSeconds}s)');
        return null;
      }

      try {
        final T result = decode != null ? decode(data) : data as T;
        CacheLogger.debug('Cache hit for key: $key (age: ${age.inSeconds}s)');
        return result;
      } catch (e, st) {
        CacheLogger.error(
          'Failed to decode cache for key: $key',
          e,
          st,
        );
        await _box?.delete(key);
        return null;
      }
    } catch (e, st) {
      CacheLogger.error(
        'Error reading cache for key: $key',
        e,
        st,
      );
      await _box?.delete(key);
      return null;
    }
  }

  Future<void> put(String key, dynamic data) async {
    try {
      final envelope = <String, dynamic>{
        'version': _cacheVersion,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };
      await _box?.put(key, jsonEncode(envelope));
      CacheLogger.debug('Cache written for key: $key');
    } catch (e, st) {
      CacheLogger.error('Failed to write cache for key: $key', e, st);
    }
  }

  Future<void> remove(String key) async {
    await _box?.delete(key);
    CacheLogger.debug('Cache removed for key: $key');
  }

  Future<void> invalidatePrefix(String prefix) async {
    final box = _box;
    if (box == null) return;
    final keys = box.keys
        .whereType<String>()
        .where((String k) => k.startsWith(prefix))
        .toList();
    for (final key in keys) {
      await box.delete(key);
    }
    CacheLogger.debug('Invalidated ${keys.length} cache keys with prefix: $prefix');
  }

  Future<void> clearOnSignOut() async {
    try {
      for (final prefix in CacheKeys.userScopedPrefixes) {
        await invalidatePrefix(prefix);
      }
      CacheLogger.info('User-scoped cache cleared on sign out');
    } catch (e, st) {
      CacheLogger.error('Failed to clear user-scoped cache on sign out', e, st);
    }
  }
}
