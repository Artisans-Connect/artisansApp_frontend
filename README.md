# CraftMatch - On-Demand Artisan Platform (Ghana)

**Status:** IMPLEMENTED (June 2026)

CraftMatch is a localized on-demand service marketplace that connects clients with local skilled artisans in Ghana. The app is built with Flutter for Android, iOS, and temporary web/PWA access while native store deployment is pending.

---

## Ecosystem Structure

- **`artisansApp_frontend`**: Flutter app for Android, iOS, and web/PWA access.
- **`artisansApp_backend`**: Express.js + TypeScript coordination layer.
- **`CraftMatch_Verification_Portal`**: React app for artisan verification and platform administration.
- **`docs`**: Technical documentation and planning assets.

---

## Tech Stack

- **Frontend (App):** Flutter for Android, iOS, and web/PWA access
- **Frontend (Admin Web):** React, Tailwind CSS, Vite
- **Backend:** Node.js, Express.js, TypeScript
- **Database:** Supabase PostgreSQL with Row Level Security
- **Realtime:** Supabase Realtime for job status, messaging, and location updates
- **Push Notifications:** Firebase Cloud Messaging, best-effort on web
- **Storage:** Supabase Storage for avatars, job photos, chat media, and completion photos

---

## Setup & Running

### CraftMatch App

```bash
cd artisansApp_frontend
flutter pub get
flutter run
```

Run native targets:

```bash
flutter run -d android
flutter run -d ios
```

Build the temporary PWA:

```bash
flutter build web --release
```

Deploy `build/web` to static hosting such as Vercel. If the app is hosted under a subpath, pass the matching base path:

```bash
flutter build web --release --base-href /your-subpath/
```

### Auth And Environment

For Supabase auth, make sure `.env` includes `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_OAUTH_REDIRECT_URL`, and `SUPABASE_PASSWORD_RESET_REDIRECT_URL`.

For PWA access, add the deployed PWA origin to the Supabase Auth redirect allow-list and Google Maps JavaScript API referrers. Keep Android/iOS bundle IDs and native SDK restrictions configured separately for native builds.

### Backend

```bash
cd artisansApp_backend
npm install
npm run dev
```

### Verification Portal

```bash
cd CraftMatch_Verification_Portal
npm install
npm run dev
```

---

## Testing & Quality Assurance

- **E2E Testing:** Job post, match, accept, track, complete, and rate.
- **Concurrency:** Atomic job acceptance handling.
- **Offline Resilience:** Idempotency and error handling for poor network conditions.
- **Performance:** Optimized matching logic and cache management.

---

## Final Notes

- Keep the PWA focused on core flows while native deployment remains the long-term target.
- Validate both `flutter build web --release` and native builds before release.
- CraftMatch empowers local skill through reliable dispatch, verification, and communication.
