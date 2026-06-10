# Cache Implementation: Issues & Solutions

## Implementation Status
*(Updated June 2026)*

**Status: ACTIVE**
The core caching fixes and mechanisms detailed in this document have been successfully implemented and are active in the current build.

## Summary of Fixes Applied

### ✅ Issue 1: Race Condition in Background Profile Refresh
**Problem**: `_refreshProfileInBackground()` called `getCurrentUser(forceRefresh: true)` without await, leading to:
- Unhandled promise rejections
- Errors silently ignored
- Multiple concurrent refreshes possible

**Solution Applied**:
- Added `.then().catchError()` chain to properly handle async completion
- Added logging to track when background refresh completes or fails
- Errors are logged but don't crash the app
- File: `auth_service.dart`, `_refreshProfileInBackground()`

---

### ✅ Issue 2: Unhandled Errors in Stale-While-Revalidate
**Problem**: `_refreshInBackground()` had `.catchError((_) {})` which silently swallowed all errors
- No logging, impossible to debug cache refresh failures
- No metrics on how often refreshes fail

**Solution Applied**:
- Changed to proper error handler with logging
- Logs include error object and stack trace
- Added debug log on successful refresh
- File: `cached_fetch.dart`, `_refreshInBackground()`

---

### ✅ Issue 3: Type Casting Without Validation
**Problem**: `envelope['data']` cast directly to T without type checking
- Could fail at runtime with confusing error messages
- No logging of decode failures

**Solution Applied**:
- Wrapped type casting in try-catch block
- Added detailed error logging when decode fails
- Invalid cache entries are deleted instead of returned
- File: `cache_store.dart`, `get()` method

---

### ✅ Issue 4: Missing Error Logging
**Problem**: No logging in cache operations made debugging impossible
- Cache hits/misses unknown
- Errors silently ignored

**Solution Applied**:
- Created `CacheLogger` utility with debug/info/warning/error levels
- All cache operations logged with context
- All error paths log the actual error and stack trace
- Files: `cache_logger.dart`, `cache_store.dart`, `cached_fetch.dart`, `auth_service.dart`

---

### ✅ Issue 5: No Cache Versioning
**Problem**: App schema changes invalidate cached data, causing deserialization errors
- No way to invalidate cache on app updates
- Old cache entries persist and crash the app

**Solution Applied**:
- Added `_cacheVersion` constant (currently = 1)
- `init()` now validates cache version on startup
- If version mismatch detected, entire cache is cleared
- Each cache envelope now includes version number
- Increment `_cacheVersion` when schema changes
- File: `cache_store.dart`

---

### ✅ Issue 6: Profile Cache Ignores Auth Token Expiry
**Problem**: Cached profile shown even if user's auth token expired
- Security risk: shows another user's profile if session hijacked
- Remote logout not respected

**Solution Applied**:
- Added `_isAuthTokenValid()` method to check token expiry
- `getCurrentUser()` now validates token before using cache
- If token invalid, always fetches fresh profile from API
- Checks both session existence and expiration time
- File: `auth_service.dart`

---

### ✅ Issue 7: Created Debug Utilities
**Problem**: No tools to inspect cache or debug issues in production
- Hard to diagnose cache problems
- No visibility into cache size or contents

**Solution Applied**:
- Created `CacheDebug` utility class with methods:
  - `printCacheStats()` - Lists all keys and sizes
  - `clearAllCache()` - Clears all cache (for testing)
  - `clearKey()` / `clearPrefix()` - Targeted clearing
  - `inspectKey()` - View raw cache content
  - `printExpirationStatus()` - See TTL info for all keys
- File: `cache_debug.dart`

---

## Remaining Issues & Recommendations

### ⚠️ Issue 8: No Cache Size Limits (Low Priority)
**Problem**: Hive has no automatic size limits; cache could grow indefinitely
**Recommendation**:
1. Monitor cache size in analytics
2. If exceeds 50MB, implement LRU (Least Recently Used) eviction
3. Add cleanup task to remove entries older than 7 days

**Implementation**:
```dart
Future<void> enforceMaxCacheSize(int maxSizeBytes) async {
  // Calculate total size
  // If exceeds limit, delete oldest entries first
}
```

---

### ⚠️ Issue 9: Concurrent Request Handling (Medium Priority)
**Problem**: Multiple simultaneous API requests for same key could cause:
- Duplicate API calls (wasted bandwidth)
- Race conditions in cache writes
- Inconsistent UI updates

**Recommendation**:
1. Add request deduplication layer
2. If request for key K is in-flight, wait for it instead of making another
3. Use a Map<String, Future> to track in-flight requests

**Implementation Pattern**:
```dart
final Map<String, Future<dynamic>> _pendingRequests = {};

Future<T> fetchWithDedup<T>(
  String key,
  Future<T> Function() fetch,
) async {
  // If already fetching, wait for that
  if (_pendingRequests.containsKey(key)) {
    return _pendingRequests[key]!.then((value) => value as T);
  }
  
  // Start new fetch
  final future = fetch();
  _pendingRequests[key] = future;
  try {
    return await future;
  } finally {
    _pendingRequests.remove(key);
  }
}
```

---

### 💡 Issue 10: Cache Invalidation on Mutations (Medium Priority)
**Problem**: When user creates/updates data, cache is cleared but UI doesn't update atomically
- User sees "item deleted" momentarily, then stale data returns
- Lists don't reflect new items until refresh

**Recommendation**:
1. On successful mutation (create job, send message), update cache optimistically
2. Don't wait for API call to clear cache
3. Update UI state directly, sync cache in background

**Pattern**:
```dart
// Bad: Clear cache, then API call
await cache.clearPrefix('jobs:');
await api.createJob(data);

// Good: Optimistic update
final newJob = Job.fromInput(data);
uiState.jobs.add(newJob);  // Update UI immediately
await cache.addToList('jobs:', newJob);  // Update cache
final result = await api.createJob(data);  // API call in parallel
// If API fails, revert UI state
```

---

## Testing Recommendations

### 1. **Test Background Refresh Error Handling**
```
1. Start app, cache profile
2. Go offline
3. Wait for TTL to expire
4. Come online, trigger stale-while-revalidate
5. Check logs that error was logged, not silent
```

### 2. **Test Auth Token Expiry**
```
1. Sign in (cache profile)
2. Manually expire token in Supabase console
3. Navigate away and back to home
4. Should fetch fresh profile, not use stale cache
```

### 3. **Test Cache Versioning**
```
1. Build and run app (cache version 1)
2. Change _cacheVersion to 2
3. Rebuild and run
4. Should clear all old cache on startup
```

### 4. **Test Concurrent Requests**
```
1. Create two rapid requests for same cache key
2. Check logs that only one API call made (not two)
3. Both requests should get same result
```

---

## How to Use Debug Utilities in Development

### Access in Code
```dart
// In any widget or service:
import 'package:artisans_app/core/cache/cache_debug.dart';

// Print stats
await CacheDebug.printCacheStats();

// Clear specific key
await CacheDebug.clearKey('profile:me');

// Clear by prefix
await CacheDebug.clearPrefix('jobs:');
```

### In Logcat/Console
All cache operations appear with `[Cache]` prefix:
```
[Cache] [DEBUG] Cache hit for key: profile:me (age: 15s)
[Cache] [INFO] Cache box opened: api_cache
[Cache] [WARNING] Cache expired for key: jobs:mine:all (age: 320s, ttl: 300s)
[Cache] [ERROR] Failed to decode cache for key: categories:all
```

---

## Migration Guide: Incrementing Cache Version

When app schema changes (e.g., new fields added to Job model):

1. **Update the constant**:
```dart
// In cache_store.dart
const int _cacheVersion = 2; // was 1
```

2. **On next app startup**, cache will be cleared automatically
3. All users get fresh data from API on next app run
4. No manual cache clearing needed

---

## Summary of Changed Files

1. ✅ `lib/core/utils/cache_logger.dart` - NEW
2. ✅ `lib/core/cache/cache_debug.dart` - NEW
3. ✅ `lib/core/cache/cache_store.dart` - UPDATED (versioning, validation, logging)
4. ✅ `lib/core/cache/cached_fetch.dart` - UPDATED (error handling, logging)
5. ✅ `lib/core/services/auth_service.dart` - UPDATED (token validation, error handling)

---

## Next Steps

1. ✅ **Immediate**: Test the fixes with new build
2. **Soon**: Implement request deduplication layer (Issue 9)
3. **Future**: Implement cache size limits with LRU (Issue 8)
4. **Future**: Add optimistic mutations pattern (Issue 10)
