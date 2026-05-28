# Client feature module

## Shell (post-auth root)

`ClientShell` (`/client-shell`) is the only post-auth home. It exposes four tabs:

| Tab | Screen |
|-----|--------|
| Home | `ClientHomeScreen` |
| Bookings | `BookingHistoryScreen(embedInShell: true)` |
| Messages | `MessagesListScreen(embedInShell: true)` |
| Profile | `UserProfileScreen(embedInShell: true)` |

Use `ClientShellScope` / `ClientNavigation.selectTab` to switch tabs without pushing duplicate routes.

## Pushed flows (full-screen, back returns to shell)

- Explore / map / artisan profile
- Job post wizard (`/job-post-category` … `/job-post-summary`)
- Finding artisan → live tracking → rate service

`/client-home` and `/booking-history` deep links resolve to `ClientShell` with the appropriate initial tab.

## Navigation helper

See [`presentation/navigation/client_navigation.dart`](presentation/navigation/client_navigation.dart).

## Booking statuses

`ClientBookingStatus`: `requested`, `accepted`, `inProgress`, `completed`, `cancelled` — aligned with `docs/backend_integration.md`.
