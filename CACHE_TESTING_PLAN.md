# Cache Implementation: Testing & Validation Guide

## Pre-Launch Testing Checklist

### 1. Basic Cache Operations ✅
- [ ] **Cache write & read**: Post a job, close app, reopen → should see job from cache immediately
- [ ] **Cache expiry**: Wait for job cache (5 min TTL) to expire, verify request made on refresh
- [ ] **Cache hit logging**: Check logs for `[Cache] [DEBUG] Cache hit` entries

### 2. Background Refresh Testing ✅
- [ ] **Stale-while-revalidate**: View conversations list (cached), should show data, then refresh in background
- [ ] **Refresh error handling**: Go offline, trigger stale-while-revalidate, check logs for error (not crash)
- [ ] **Profile refresh**: Sign in, navigate away/back to home, check logs show background refresh

### 3. Auth Token Validation ✅
- [ ] **Valid token with cache**: Sign in, verify cached profile shown + background refresh happens
- [ ] **Expired token**: Manually expire token in Supabase, navigate away/back to home, should force API call
- [ ] **No session**: Sign out, then close app, reopen → no profile cached

### 4. Cache Versioning ✅
- [ ] **Version match**: Run with current version, check logs `[Cache] [DEBUG] Cache box already open`
- [ ] **Version mismatch**: Change `_cacheVersion = 2`, rebuild, should see `[Cache] [INFO] Cache version mismatch... Clearing cache`
- [ ] **Old cache cleared**: With version mismatch, all old cache keys should be deleted

### 5. Type Validation ✅
- [ ] **Valid cached data**: Cache hit should return correct type (List, Map, etc)
- [ ] **Invalid cached data**: Manually corrupt cache file, app should not crash on read
- [ ] **Decode errors**: Add invalid decoder, should log error and delete cache entry

### 6. Concurrent Requests ✅
- [ ] **Duplicate prevention**: Trigger rapid API calls for same key, check only one HTTP request in Network tab
- [ ] **Shared result**: Both requests should get identical result
- [ ] **Error handling**: If request fails, second caller should also get error (not stale cache)

### 7. Sign-Out Cleanup ✅
- [ ] **User-scoped cache cleared**: Sign in, cache profile/jobs/messages, then sign out
- [ ] **Verify prefixes cleared**: Check logs show all `profile:`, `jobs:`, `chat:`, `explore:` cleared
- [ ] **Categories remain**: Categories cache (24h TTL) should NOT be cleared on sign out
- [ ] **After sign-out navigation**: Sign in as different user, should not see previous user's data

### 8. Logging & Debugging ✅
- [ ] **Cache logs visible**: Run `flutter run` and grep for `[Cache]`
- [ ] **Error details**: Check that errors include full message, not just `Exception: null`
- [ ] **Debug utilities**: Call `CacheDebug.printCacheStats()` and verify output
- [ ] **Size tracking**: Run `CacheDebug.printCacheStats()` and note cache size

## Performance Testing

### Benchmark: Splash Screen
**Scenario**: User is signed in with cached profile

| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Time to show home (with cache) | < 1s | ___ | ☐ |
| Time to show home (no cache, first run) | < 3s | ___ | ☐ |
| Background profile refresh time | < 2s | ___ | ☐ |

**Test Steps**:
1. Sign in (user logged in, cache exists)
2. Kill and restart app
3. Measure time from app launch to home screen visible
4. Check network tab shows profile API call in background

### Benchmark: Conversations List
**Scenario**: User views chat with cached conversations

| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Time to show conversations (cached) | < 500ms | ___ | ☐ |
| Time to show conversations (force refresh) | < 2s | ___ | ☐ |
| Background refresh completes | < 1s | ___ | ☐ |

**Test Steps**:
1. View conversations (should load from cache immediately)
2. Pull-to-refresh (forceRefresh: true)
3. Check Network tab to verify API call

---

## Failure Scenarios (Intentional Testing)

### Scenario 1: Network Error During Background Refresh
**Setup**: 
1. Cache conversations (3 min TTL)
2. Go offline
3. Wait for cache to be exactly 2 min old
4. Come online, navigate to conversations

**Expected**: 
- Conversations shown from cache immediately
- Background refresh attempted, fails gracefully
- Error logged but no crash
- User can still use app

**Verify**:
- [ ] No crash
- [ ] Logs show error: `[Cache] [ERROR] Background refresh failed`
- [ ] Conversations still visible

---

### Scenario 2: Concurrent Rapid Requests
**Setup**:
1. Rapidly switch between two artisans on explore screen
2. Each switch triggers fetch for profile cards

**Expected**:
- Only one API call made (not two)
- Both requests get same result
- No race conditions in UI

**Verify**:
- [ ] Network tab shows single request
- [ ] No duplicate API calls
- [ ] UI displays correctly without flicker

---

### Scenario 3: Cache Corruption
**Setup**:
1. Start app, cache some data
2. Manually edit Hive database file to corrupt JSON
3. Restart app

**Expected**:
- App doesn't crash
- Corrupted cache deleted
- Fresh data fetched from API

**Verify**:
- [ ] App starts normally
- [ ] Logs show: `[Cache] [ERROR] Error reading cache`
- [ ] Data eventually displays correctly

---

### Scenario 4: Token Expiry During App Use
**Setup**:
1. Sign in, cache profile
2. In Supabase console, set user's session to expire
3. Wait 30 seconds
4. Navigate away and back to home screen

**Expected**:
- Cached profile NOT shown
- Fresh profile fetched (even though cache valid)
- Current user sees their profile, not stale data

**Verify**:
- [ ] Logs show: `[Cache] [DEBUG] Auth token expired`
- [ ] API request made to get fresh profile
- [ ] Correct user data displayed

---

## Regression Testing

### Must Not Break
- [ ] Sign in flow
- [ ] Sign out flow
- [ ] Job creation/cancellation
- [ ] Message sending
- [ ] Pull-to-refresh functionality
- [ ] Offline mode (JobPostQueue)

### Integration Points to Verify
- [ ] `AuthService.signIn()` still works
- [ ] `AuthService.signOut()` clears cache correctly
- [ ] `JobsService` clears job cache on create/cancel
- [ ] `ChatService` clears conversation cache on send
- [ ] `CategoriesService` respects 24h TTL

---

## Performance Profiling

### Use DevTools Profiler

1. **Enable profiling in Flutter DevTools**
2. **Record session with typical user flow**:
   - Sign in
   - View home (categories from cache)
   - View explore/nearby (uses stale-while-revalidate)
   - View messages (conversation list cached)
   - Send message (cache cleared)

3. **Check for**:
   - No jank or frame drops from cache operations
   - Cache reads complete in < 50ms
   - No memory leaks

4. **Memory monitoring**:
   - Initial memory (before cache): _____ MB
   - After caching (1 week of use): _____ MB
   - Growth rate acceptable: ☐

---

## Production Monitoring Checklist

### Metrics to Track
- [ ] Cache hit rate (%), target > 70%
- [ ] Cache size growth over time
- [ ] Background refresh error rate
- [ ] Type decode errors
- [ ] Version mismatch occurrences

### Logging to Monitor
```
grep "[Cache] \[ERROR\]" logs/
# Should be rare; if frequent, indicates bug
```

---

## Sign-Off Checklist

Before merging to main:

- [ ] All basic cache operations tested
- [ ] Background refresh error handling verified
- [ ] Auth token expiry validation works
- [ ] Cache versioning tested (manual version bump)
- [ ] Type validation prevents crashes
- [ ] Concurrent requests deduplicated
- [ ] Sign-out clears user data correctly
- [ ] Debug utilities accessible
- [ ] No new crash logs from cache operations
- [ ] Performance benchmarks acceptable
- [ ] Logs are clear and actionable
- [ ] Code reviewed for thread safety
