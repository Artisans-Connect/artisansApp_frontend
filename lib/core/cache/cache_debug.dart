import 'package:hive_flutter/hive_flutter.dart';

import 'package:artisans_app/core/cache/cache_keys.dart';
import 'package:artisans_app/core/cache/cache_store.dart';

/// Debug utilities for the cache system.
abstract final class CacheDebug {
  /// Lists all cache keys and their approximate sizes.
  static Future<void> printCacheStats() async {
    final box = Hive.box<String>('api_cache');
    final keys = box.keys.whereType<String>().toList();
    
    print('\n=== Cache Statistics ===');
    print('Total keys: ${keys.length}');
    
    int totalSizeBytes = 0;
    for (final key in keys) {
      final value = box.get(key);
      if (value != null) {
        totalSizeBytes += value.length;
      }
    }
    
    print('Approximate total size: ${totalSizeBytes / 1024}.2 KB');
    print('\nCache keys:');
    for (final key in keys) {
      final value = box.get(key);
      final sizeKb = (value?.length ?? 0) / 1024;
      print('  $key (${sizeKb.toStringAsFixed(2)} KB)');
    }
    print('========================\n');
  }

  /// Clears all cache entries (for testing).
  static Future<void> clearAllCache() async {
    final box = Hive.box<String>('api_cache');
    await box.clear();
    print('Cache cleared');
  }

  /// Clears specific cache key.
  static Future<void> clearKey(String key) async {
    await CacheStore.instance.remove(key);
    print('Cleared cache key: $key');
  }

  /// Clears cache by prefix pattern.
  static Future<void> clearPrefix(String prefix) async {
    await CacheStore.instance.invalidatePrefix(prefix);
    print('Cleared cache keys with prefix: $prefix');
  }

  /// Inspects cached data for a specific key (returns raw Map).
  static Future<Map<String, dynamic>?> inspectKey(String key) async {
    final box = Hive.box<String>('api_cache');
    final raw = box.get(key);
    if (raw == null) {
      print('Cache key not found: $key');
      return null;
    }
    
    try {
      // Return the raw JSON to inspect
      print('Raw cache for $key:');
      print(raw);
      return null; // Already printed
    } catch (e) {
      print('Error inspecting key $key: $e');
      return null;
    }
  }

  /// Simulates a cache expiration by getting statistics on expiration times.
  static Future<void> printExpirationStatus() async {
    final box = Hive.box<String>('api_cache');
    final keys = box.keys.whereType<String>().toList();
    
    print('\n=== Cache Expiration Status ===');
    
    for (final key in keys) {
      final value = box.get(key);
      if (value != null) {
        try {
          final ttl = _getTtlForKey(key);
          // Simplified: just show TTL info
          print('  $key: TTL = ${ttl.inMinutes} minutes');
        } catch (e) {
          print('  $key: Error reading TTL - $e');
        }
      }
    }
    print('================================\n');
  }

  /// Returns the TTL duration for a given cache key.
  static Duration _getTtlForKey(String key) {
    if (key.startsWith('profile:')) {
      return CacheKeys.profileTtl;
    } else if (key.startsWith('categories:')) {
      return CacheKeys.categoriesTtl;
    } else if (key.startsWith('jobs:')) {
      return CacheKeys.jobsTtl;
    } else if (key.startsWith('chat:')) {
      return CacheKeys.chatTtl;
    } else if (key.startsWith('explore:')) {
      return CacheKeys.exploreTtl;
    }
    return const Duration(minutes: 5); // Default
  }
}
