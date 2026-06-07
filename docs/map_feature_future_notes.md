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

## Configuration Checklist

- Android: `GOOGLE_MAPS_API_KEY` in `local.properties`, Maps SDK for Android enabled, key restricted to Android app.
- iOS: `Secrets.plist` with `GOOGLE_MAPS_API_KEY`, Maps SDK for iOS enabled, key restricted to iOS bundle.
- Web: `.env` `GOOGLE_MAPS_API_KEY`, Maps JavaScript API enabled if web demo is required.
- Places: Places API enabled for search/autocomplete and reverse geocoding.
- Billing: alerts and quotas configured before enabling route APIs.
