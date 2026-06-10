# CraftMatch – On‑Demand Artisan Platform (Ghana)

**Status:** IMPLEMENTED (June 2026)

The CraftMatch platform is a localized on-demand service marketplace designed to connect clients with local skilled artisans in Ghana. This ecosystem consists of a Flutter mobile application for clients and workers, a Node.js Express backend, and a dedicated React-based verification portal for administrative management.

---

## Ecosystem Structure

The project is organized into the following main repositories:

- **`artisansApp_frontend`**: The primary Flutter mobile application.
- **`artisansApp_backend`**: The Express.js + TypeScript coordination layer.
- **`artisans_verification_portal`**: A React application for managing artisan verifications and platform statistics.
- **`docs`**: Centralized documentation and planning assets.

---

## Tech Stack

- **Frontend (Mobile):** Flutter, Riverpod, GoRouter, Google Maps SDK
- **Frontend (Web):** React, Tailwind CSS, Vite (Verification Portal)
- **Backend:** Node.js, Express.js, TypeScript
- **Database:** Supabase (PostgreSQL) with Row Level Security (RLS)
- **Realtime:** Supabase Realtime (for job status & location updates)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Storage:** Supabase Storage (avatars, job photos, identity documents)

---

## Core Features

- **Multi-Role Authentication**: Passwordless Phone OTP authentication via Supabase.
- **Smart Dispatch Engine**: Multi-factor matching algorithm (proximity, ratings, verification, freshness).
- **Real-Time Tracking**: Live worker location updates and ETA calculation on the map.
- **In-App Messaging**: Real-time chat with push notification support.
- **Verification Workflow**: Dedicated portal for verifying artisan credentials and managing the workforce.
- **Ratings & Reviews**: Post-service feedback system with automatic rating updates.

---

## Setup & Running

### 1. CraftMatch App (Flutter)
```bash
cd artisansApp_frontend
flutter pub get
flutter run
```

### 2. Backend (Express)
```bash
cd artisansApp_backend
npm install
npm run dev
```

### 3. Verification Portal (React)
```bash
cd artisans_verification_portal
npm install
npm run dev
```

---

## Testing & Quality Assurance

- **E2E Testing**: Full job lifecycle validation (Job post → Match → Accept → Track → Complete → Rate).
- **Concurrency**: Verified atomic job acceptance handling.
- **Offline Resilience**: Idempotency and error handling for poor network conditions.
- **Performance**: Optimized matching logic and cache management.

---

## Final Notes

- Focus on **reliability** and **trust** through the verification portal.
- Haversine-based matching for efficient discovery.
- Scalable decoupled architecture.

**CraftMatch — Empowering Local Skill.**

