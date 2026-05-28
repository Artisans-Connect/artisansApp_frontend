# Worker Frontend Handoff Notes

This document defines the frontend contract assumptions for worker UI screens while backend integration is pending.

## Scope
- Worker UI only (`lib/features/worker/presentation`).
- No backend/API binding in this phase.
- Mock/local state remains the data source until integration.

## Canonical Worker Lifecycle
- `requested`
- `accepted`
- `in_progress`
- `completed`
- `cancelled`

Lifecycle progression currently represented in UI flow:
- Requests -> Request Details -> Active Booking (pre-start) -> In Progress -> Completion -> Success

## Availability Semantics
- Worker availability is treated as online/offline UI state.
- Offline workers can browse requests but cannot accept them.
- Active-empty status badge reflects this state (`ONLINE` / `OFFLINE`).

## Frontend Contract Keys
Worker request/detail screens assume these payload keys:
- `id`
- `title`
- `category`
- `description`
- `addressLabel`
- `clientName`
- `clientRating`
- `reviewCount`
- `urgency`
- `estimate`
- `distanceKm`

Reference constants are defined in:
- `lib/features/worker/presentation/models/worker_ui_contracts.dart`

## Integration Guidance
- Keep mapping logic in adapter/repository layer, not in widgets.
- Translate backend status values into canonical lifecycle values before passing to presentation state.
- Preserve route and screen boundaries so parallel shared/auth/backend work can plug in without UI rewrites.
