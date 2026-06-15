# Map Feature Future Notes

## Current Direction

The app should feel like a modern dispatch platform without depending on paid Google routing APIs in the first version. Google Maps displays locations, markers, and navigation handoff. Supabase and the backend remain responsible for recommendation, dispatch, pricing, and privacy rules.

The target visual level is **Route Rich+**:

- Uber-inspired map interactions.
- Custom role/status marker states.
- Expanded maps and bottom-sheet previews.
- Distance, ETA, rating, verification, availability, and freshness shown as trust signals.
- External Google Maps navigation for turn-by-turn directions.
- No required Google Routes, Directions, Distance Matrix, or Navigation SDK calls in v1.

## Already Implemented

- Backend Haversine worker matching and scoring in `matchingService.ts`.
- Ranking signals include distance, rating, verification, location freshness, and completed-job experience.
- Dispatch RLS is enabled for `job_dispatches` with workers restricted to their own dispatches.
- Worker dispatch realtime subscriptions are filtered by `worker_id`.
- Client live tracking reads assigned worker coordinates with freshness awareness.
- Basic map helper models exist for map points, route estimates, marker states, actions, and a default Haversine route provider.
- Worker map scope is dispatched jobs first, not all nearby open jobs.

## Current Cost-Control Strategy

Use Google Maps for:

- Embedded map display.
- Markers and camera movement.
- Places/geocoding only where needed for location search.
- External Google Maps links for navigation.

Avoid in v1:

- In-app road route drawing from Google Routes/Directions.
- Automatic traffic-aware ETA refresh.
- High-frequency route recalculation during live tracking.
- Any feature that repeatedly calls paid route APIs as the worker moves.

## Next Build Priorities

- Improve client map discovery with richer worker preview sheets, service filters, radius context, and trust badges.
- Improve worker dispatched-job maps with selected/urgent marker states, job preview cards, budget/distance context, details/accept path, and external navigation.
- Improve live tracking with animated status, stale-location messaging, and a clean route-estimate provider boundary.
- Keep frontend map screens display-only for recommendation signals. They may show rank factors but must not replace backend scoring.

## Recommendation And Pricing Signals To Preserve

The map UI must preserve these backend-owned signals:

- Distance from client/job location.
- Worker rating.
- Worker verification status.
- Worker availability status.
- Location freshness.
- Category or skill match.
- Worker experience/completed-job history.
- Pricing inputs, including travel or distance allowance.

The current payment estimate uses coordinate distance from the job location to a Kumasi CBD proxy. That is acceptable for the current controlled version, but it is not yet true worker-to-job distance or road-distance pricing.

## Later Roadmap

- Add database-side proximity filtering through PostGIS, `earthdistance`, or a Supabase RPC once worker volume grows.
- Add route-aware travel pricing after a route provider is approved.
- Add Google Routes API or OSRM behind the route-provider interface for road-distance polyline and ETA.
- Add marker clustering when dense worker data makes the map crowded.
- Add native background/foreground GPS service only if product requirements demand tracking while the app is locked or backgrounded.
- Add privacy controls for approximate worker location before booking and exact tracking only after acceptance.
- Add quota, budget alerts, and per-feature API call limits before enabling paid route APIs.

## Google Cloud Configuration Checklist

- Android: Maps SDK for Android, restricted API key in `local.properties`.
- iOS: Maps SDK for iOS, restricted API key in `Secrets.plist`.
- Web: Maps JavaScript API only if web demo is required.
- Optional: Places API and Geocoding API for search/reverse geocoding.
- Avoid initially: Routes API, Directions API, Distance Matrix-style routing, Navigation SDK.
- Always configure billing alerts and quotas before exposing a map build to real users.
