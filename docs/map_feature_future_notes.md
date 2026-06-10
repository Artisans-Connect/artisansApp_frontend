# Map Feature Future Notes

## Current Direction

The app should keep recommendation and pricing logic backend-owned. Google Maps should display locations, support selection, and hand off navigation. This keeps distance, estimated cost, worker rating, verification status, availability, and location freshness available for matching and payment estimation without making the map provider responsible for business rules.

The current implementation is intentionally low-cost:

- Embedded Google Maps for visual context.
- Worker/client/job markers.
- Coordinate-based distance and ETA estimates.
- Supabase-backed nearby workers and dispatched job requests.
- External Google Maps links for turn-by-turn navigation.

## Route Upgrade Path

Initial route previews use haversine distance, which is good enough for ranking, demo estimates, and “nearby” UX. A later version can add Google Directions API or Routes API behind the existing route-estimate abstraction.

When upgrading, keep these rules:

- Cache route results by origin/destination bucket where possible.
- Rate-limit route calls during map movement and live tracking.
- Use paid route distance for display and travel-cost refinement, not for basic matching availability.
- Keep fallback haversine estimates when Google route calls fail or quota is exhausted.

## Recommendation Signals To Preserve

The map UI must not discard or override these backend signals:

- Distance from client/job location.
- Worker rating and completed-job history.
- Verification status.
- Availability status.
- Location freshness.
- Category/skill match.
- Pricing inputs, including location-based travel estimate.

The map can show these signals, but the backend should continue to decide ranking, matching, and payment estimates.

## Future Enhancements

- Add custom marker icons per trade category.
- Add worker clustering for dense map results.
- Add a visible service-radius circle around the client/job location.
- Add a richer worker preview bottom sheet with request/chat/profile actions.
- Add a richer worker request map with accept/decline directly from the expanded map.
- Add PostGIS/geography columns or a database distance function if worker/job volume grows.
- Add privacy controls: approximate worker location before booking, exact tracking only after acceptance.
- Add stale-location messaging everywhere a worker marker appears.
- Add route-aware travel cost once paid route APIs are approved.

## Architectural & Security Recommendations

### 1. Realtime Security & Row Level Security (RLS) for Dispatches
> [!IMPORTANT]
> When using `Supabase.instance.client.channel(...)` to listen to job dispatches in real-time on the client application, **strict Row Level Security (RLS)** is required.
* **Security Risk:** If RLS is misconfigured or disabled on `job_dispatches`, any worker could potentially listen to channels or fetch records meant for other workers.
* **Mitigation:** Ensure the `job_dispatches` table has RLS enabled with a select policy that restricts access only to the authenticated worker:
  ```sql
  ALTER TABLE job_dispatches ENABLE ROW LEVEL SECURITY;
  
  CREATE POLICY "Workers view own dispatches" ON job_dispatches
    FOR SELECT USING (auth.uid() = worker_id);
  ```
* **Client-side Subscription:** The client should use a filtered subscription channel to avoid receiving other workers' events:
  ```dart
  Supabase.instance.client
      .channel('my-dispatches')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'job_dispatches',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'worker_id',
          value: myUserId,
        ),
        callback: (payload) => _onNewDispatch(payload.newRecord),
      )
      .subscribe();
  ```

### 2. Database-Side Proximity Calculation (Supabase RPC)
Instead of retrieving all available workers in Node.js Express memory and doing Haversine math, compute the proximity directly in the PostgreSQL database.
* **Scalability:** Doing JavaScript-based filtering in-memory on every matching round or search request will cause high memory and CPU utilization as the worker base grows.
* **Solution:** Create a Postgres function (RPC) using the standard `earthdistance` extension (which calculates distances based on lat/lng coordinates) to return only the pre-filtered, ordered list of nearby workers within the search radius.

### 3. Background/Foreground Native GPS Tracking
* **App Suspension:** In Flutter, normal Dart streams (e.g., `Geolocator.getPositionStream()`) get suspended by iOS/Android when the screen locks or the application enters the background.
* **Solution:** Implement a native wrapper package such as `flutter_background_geolocation` or `flutter_foreground_task` to run a persistent OS service that continues updating the worker's coordinates on a periodic interval.

### 4. Road-Based Routing and Traffic-Aware ETA
* **Directions API:** Replace the current visual straight-line `Polyline` and flat 25 km/h ETA estimation with real street pathing.
* **Solution:** Call OSRM (Open Source Routing Machine) or Google Routes API to fetch actual street geometries and traffic-adjusted travel times.

## Configuration Checklist

- Android: `GOOGLE_MAPS_API_KEY` in `local.properties`, Maps SDK for Android enabled, key restricted to Android app.
- iOS: `Secrets.plist` with `GOOGLE_MAPS_API_KEY`, Maps SDK for iOS enabled, key restricted to iOS bundle.
- Web: `.env` `GOOGLE_MAPS_API_KEY`, Maps JavaScript API enabled if web demo is required.
- Places: Places API enabled for search/autocomplete and reverse geocoding.
- Billing: alerts and quotas configured before enabling route APIs.

