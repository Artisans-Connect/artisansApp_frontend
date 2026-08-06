# CraftMatch Flutter Web/Desktop Frontend Documentation

This repository contains the cross-platform frontend client written in Dart using the Flutter framework, configured for Web, Mobile, and Desktop target compilation. It serves as the user-facing web portal for Clients looking to find artisans and Workers (artisans) looking to manage their availability and work schedules.

---

## 1. Architecture Overview

### Modular Feature Directory Design
The app is built with a feature-first architectural pattern under [lib/](file:///c:/Users/user/Downloads/FinalYearProject/artisansApp_frontend/lib):

- **`lib/features/auth/`**: Sign-up flow, email OTP/magic-link verification, worker sign-up, credentials, and password resets.
- **`lib/features/client/`**: Client dashboards, map views for tracking, checkout portals, review forms, and reservation requests.
- **`lib/features/worker/`**: Artisan scheduling panels, live location updating services, active job logs, and earnings history.
- **`lib/features/shared/`**: Real-time chat widgets, push notification feed, and user settings pages.
- **`lib/core/`**: Central application configurations, themes, network clients, Supabase adapters, and global constants.
- **`lib/shared/`**: Reusable generic widgets (buttons, loaders, search bars, inputs).

### Routing & State Management
- **Routing**: Configured centrally in [lib/app.dart](file:///c:/Users/user/Downloads/FinalYearProject/artisansApp_frontend/lib/app.dart) (using `go_router` or standard Navigator routes) resolving screen destinations dynamically by parsing the authenticated user's metadata role.
- **State Management**: Manages state queries (location tracking, active job statuses, and chat lists) by integrating reactive providers bound to backend API triggers.

---

## 2. Getting Started & Development

### Prerequisites
- Flutter SDK `>=3.22.0` (ensure `flutter` is on your system environment `PATH`).
- Web compiler or Chrome for web testing.

### Installation
1. Navigate to the project directory:
   ```bash
   cd artisansApp_frontend
   ```
2. Pull down Dart dependencies:
   ```bash
   flutter pub get
   ```
3. Set up environment variables by copying `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
   Modify the values in `.env` to match your local setup:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `EXPRESS_API_BASE_URL`

### Development Scripts
* **Run Locally**: `flutter run` (or `flutter run -d chrome` to specifically run on Google Chrome web mode).
* **Production Build**: `flutter build web --release` (Compiles and compiles static web assets under `build/web/`).
