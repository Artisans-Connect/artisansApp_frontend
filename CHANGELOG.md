# Changelog

All notable changes to the CraftMatch Flutter client (`artisansApp_frontend`).

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
with the Flutter `version: <semver>+<build>` convention in `pubspec.yaml`.

> **Note on reconstruction.** Versions below 1.0.0 were reconstructed on 2026-08-21 from
> git history (192 commits, 2026-05-11 → 2026-08-16). No git tags existed at the time of
> writing and `pubspec.yaml` read `1.0.0+1` from the initial commit onward, so these
> version numbers were never actually published. Each entry is anchored to a real commit
> SHA so the mapping is auditable. Dates are commit dates.

---

## [Unreleased]

### Changed
- `lib/` structure and naming cleanup, phases 1–3: removed 10 dead files, renamed 7 files
  whose names no longer matched their contents, and resolved the duplicate `GradientButton`
  by differentiating the worker copy as `WorkerGradientButton`. Net 257 → 247 files.
  No functional or visual change. See `docs/STRUCTURE_AUDIT.md`.

### Deprecated
- Escrow / "held in escrow" user-facing copy pending Bank of Ghana PSP approval and Ghana
  counsel sign-off. Code exists; the customer-facing claim must not ship.

---

## [0.9.0] — 2026-08-13 — Wallet, cashout & payment resilience
Anchor: `3a5f192`

### Added
- In-app wallet for both client and worker, with dispute-resolution entry points and
  auto-release UI (`e42226c`).
- Client-side cashout button and wallet screen branding (`3ebfd2b`).
- Automatic payment verification on app lifecycle resume, so a user returning from the
  Paystack tab no longer sees a stale pending state (`36b30b3`).
- `platform` parameter passed to the backend for dynamic post-payment redirection, fixing
  the web-vs-mobile return path (`bac3bf2`).

### Changed
- Unified the wallet available-balance card and button treatment across client and worker
  (`7942d29`, `750d8ac`).
- Worker online-toggle behaviour and admin blocked-accounts view (`354aa7f`).

### Fixed
- Payment checkout now surfaces the real error message instead of a generic failure (`d7f7211`).
- Payments verify by `jobId` rather than reference, so retried sessions resolve (`ec9ef0d`).
- Proposed-rate field uses a floating `labelText` to remove focused-state confusion (`3a5f192`).

---

## [0.8.0] — 2026-08-09 — Trust & safety, negotiation, componentization
Anchor: `6550c7f`

### Added
- Trust & safety features across user screens: reporting and safety surfaces (`8cf5bd3`).
- Price-bargaining chat UI with realtime negotiation-engine integration and settlement
  details (`e788594`, `dcc6d2d`).
- Counter-offer flow for both client and worker; `ClientBookingStatus` extended with
  `awaiting_payment` (`1f86711`).

### Changed
- Modularized explore components, worker dashboard cards, map overlay controls and the
  settlement negotiation UI (`8afd58b`); live-tracking dialogs, booking summary, extra-charge
  card and chat composer (`6550c7f`).
- Standardized screen header appbars on unified theme typography and colours (`820bb45`).

### Fixed
- Theme typography and design-token compilation errors (`0222e54`).
- Declined job-alert IDs retained when dispatches close, preventing re-popup (`598b0cf`).

---

## [0.7.0] — 2026-08-05 — Paystack checkout
Anchor: `44c5e30`

### Added
- Paystack payment checkout screens, escrow triggers and worker payout setup UI (`44c5e30`).
- AI search bar embedded in the client hero header; `ClientBookingCard` extracted (`a2ca5de`).
- Booking pagination, swipe-to-hide with a local hidden store, and fixed-mode routing (`d100ee1`).
- Worker cancellation alert modal and duplicate-popup prevention (`9682809`).
- Enhanced worker live-tracking map with ETA calculation (`30496d9`).

### Changed
- Replaced AI-style sparkle icons with professional utility icons (`a343f4f`).
- Dynamic time-of-day greetings; redesigned worker active-bookings experience (`a249518`).
- Launcher icon background aligned to brand surface `#FFF8F0` (`aa302f0`).

---

## [0.6.0] — 2026-07-30 — Web PWA launch & OAuth hardening
Anchor: `032566f`

### Added
- Flutter Web PWA deployment to Vercel via GitHub Actions, with compilation delegated to
  CI (`539ae4c`, `2ab0d8b`, `98e8f11`).
- Password strength meter and policy validation (`5a1d19f`).
- Google sign-on phone sync, swipe-to-delete for chats and notifications, scrolling
  pagination (`168dd28`).
- Firebase VAPID key template and web messaging service-worker config (`0fc0774`).
- Cross-platform picked-media model with web support (`04175af`).
- Real-time payout preview card on the worker completion form (`b71faa9`).
- Worker withdrawal of pending applications (`908c7db`).

### Changed
- Google OAuth on web/PWA uses a full-page redirect instead of a popup (`ff62eb3`).
- Seamless PWA splash screen (`c047937`); launcher icons, splash screens and PWA assets
  refreshed across Android, iOS and Web (`c2762dc`).
- Category auto-resolution from worker skill aliases at booking time (`13bc9d3`, `43f30a7`).

### Fixed
- `path_provider_foundation` pinned to resolve a web build lock timeout (`fe10afe`).
- Resilient `signOut`/`deleteAccount` with timeouts; forced Google account picker on
  web (`6bc6ed1`).
- Correct `acceptJob` endpoint mapping in `workers_service.dart` (`a7190af`).
- Compilation errors from duplicate merge blocks in `worker_requests_screen.dart` (`c9495d6`).

---

## [0.5.0] — 2026-07-17 — Scheduled jobs, quotes & notification UX
Anchor: `0904b5f`

### Added
- Scheduled jobs and worker quotes UI (`0904b5f`).
- Notification UX and supporting services (`877ff45`).
- Improved location-permission UX (`7c7fb70`).
- Recoverable service-interruption handling on the client (`058d1d0`).
- Job termination flow in the client UI (`dc1f4ec`).

---

## [0.4.0] — 2026-06-25 — Mapbox, smart search & negotiation groundwork
Anchor: `c80fb20`

### Added
- Mapbox for the client map and worker tracking, replacing the prior provider (`5a0886b`).
- Smart search with service updates (`3910b9d`).
- Job tracking, the negotiation layer, and multiple applications per job (`c80fb20`).
- Job applications flow and map enhancements (`e1341ad`).
- Google Sign-In via Supabase (`3528d5f`, `2270636`).

### Changed
- Password reset moved to the web portal instead of deep links (`1ee3a99`).
- `withAlpha` replaces the deprecated `withOpacity` for colour creation (`d027e01`).

### Fixed
- Mapbox initialization guarded on web (`c41f12e`).
- Splash initialization deferred post-frame to avoid a `MediaQuery` `initState` error (`1fba17c`).
- Back navigation blocked during job post (`a69d10e`).

---

## [0.3.0] — 2026-06-12 — Dynamic categories & job lifecycle
Anchor: `46c7a89`

### Added
- Dynamic job categories in client home and job posting, replacing hardcoded lists
  (`544174b`, `46c7a89`).
- Job lifecycle screens: tracking, ongoing and completion (`305edbd`).
- Notification service, realtime worker dispatch and job alert sheet (`4fe8d5d`).
- Worker verification UI and app-journey hardening (`984c6dc`).
- Cancellation and rescheduling handling (`0cd0dc5`).
- Legal documents (`e561f9d`).

### Changed
- Auth features refactored; themes and client/worker screens updated (`cee75a1`).
- Mocks replaced with real models across client and worker screens (`e561f9d`).

### Fixed
- Navigation issues in auth screens (`a2f37c3`).
- Auth security improvements (`abafd81`).

---

## [0.2.0] — 2026-06-03 — Ghanaian theme, caching & proximity
Anchor: `4c6d815`

### Added
- Custom application fonts — Satoshi, Clash Display, Inter (`36303d8`).
- Solid Ghanaian theme with PhosphorIcons (`9a1589c`).
- Hive-based API cache with TTL strategies and error handling (`223fdda`).
- Proximity map integration (`1273776`).
- ArtisanConnect logo, launcher icons and favicons (`7b3be12`).

### Changed
- Live `ExploreService` wired; empty featured-artisans state handled (`c6ccb5b`).

### Fixed
- Double-logout bug; edit-profile skills sync (`c6ccb5b`).
- Missing profile fields parsed in `AppUser` (`f9fb4fa`).
- Critical lint issues resolved (`0f5d019`).

### Security
- iOS Google Maps API key moved to a git-ignored `Secrets.plist` (`62a5431`).

---

## [0.1.0] — 2026-05-29 — First backend-integrated build
Anchor: `cce04db`

### Added
- Complete frontend–backend integration with Supabase and Express (`cce04db`).
- Full auth and onboarding UI flow (`349302a`).
- All shared screens (`66b03f9`); worker onboarding and role-based screens (`5a6c1ac`).
- Client UI v1 (`aa56948`) and v2 (`c10ef64`); worker UI aligned to design mocks (`df19c1a`).
- Widget tests for worker UI (`e5279b1`).
- Error-handling upgrade (`06a57e7`).

---

## [0.0.1] — 2026-05-11 — Project scaffold
Anchor: `8bc965c`

### Added
- Initial Flutter project setup (`8bc965c`).
- `artisans_screens` UI assets (`5b3ec1f`).

---

[Unreleased]: https://github.com/Artisans-Connect/artisansApp_frontend/compare/v0.9.0...HEAD
