# CraftMatch — Technical Project Overview

This document provides a comprehensive technical breakdown of the **CraftMatch** platform, a localized on-demand service marketplace designed to connect clients with local skilled artisans in Ghana. This guide is structured to help technical reviewers, examiners, and advisors quickly understand the architecture, database schema, and data flows.

*Status: Implemented as of June 2026.*
---

## 1. System Architecture

The CraftMatch ecosystem is built on a modern, decoupled architecture that separates client-facing applications from backend services and administrative tools.

```
┌───────────────────────────┐      ┌──────────────────────────────┐      ┌───────────────────────────┐
│     Flutter App           │      │   React Verification Portal  │      │      Express.js Backend     │
│ (Client & Worker Modules) │      │      (Admin facing)          │      │ (Coordination & Business Logic) │
└─────────────┬─────────────┘      └──────────────┬───────────────┘      └─────────────┬─────────────┘
              │                                    │                                  │
              │ HTTPS (JWT, RLS)                   │ HTTPS (JWT)                      │ HTTPS (JWT)
              │                                    │                                  │
              └─────────────────┬──────────────────┴───────────────────┬──────────────┘
                                │                Supabase Realtime     │
                                │              (Job/Location Sync)     │
                                ▼                                      ▼
                 ┌──────────────────────────────────────────────────────────┐
                 │                      Supabase BaaS                       │
                 │ (Auth, PostgreSQL DB, RLS, Storage, FCM Triggers)        │
                 └──────────────────────────────────────────────────────────┘
```

### Key Components

1.  **Frontend (Flutter App)**: The primary mobile application for both clients and workers, built from a single multi-role codebase. It includes modules for job discovery, posting, real-time tracking, messaging, and profile management.
2.  **Backend (Express.js & TypeScript)**: The central coordination layer that handles complex business logic, including the smart dispatch matching engine, scheduled tasks, and dispatching push notifications via Firebase Cloud Messaging (FCM).
3.  **Admin Frontend (React Verification Portal)**: A web-based dashboard for internal teams to manage the artisan verification process, review submitted documents, and oversee platform activity.
4.  **Backend-as-a-Service (Supabase)**: Provides the core backend infrastructure, including PostgreSQL database, passwordless OTP phone authentication, real-time data sync, media storage, and database triggers for automated tasks like recalculating ratings.

---

## 2. Core Workflows

### A. Multi-Role Authentication & Authorization
- **Authentication**: All three frontends (Flutter, React, Express) use Supabase for authentication. The mobile app uses passwordless phone OTP, while the verification portal uses standard email/password logins.
- **Authorization**: The Express.js server validates the JWT on every secured request. It fetches the user's role and permissions from the `profiles` table in PostgreSQL to authorize actions, ensuring, for example, that only a user with a `client` role can post a job.

### B. Artisan Verification Workflow
1.  **Submission**: A worker submits their identity documents (e.g., Ghana Card) and qualifications through the Flutter app. The files are uploaded directly to a private Supabase Storage bucket.
2.  **Admin Review**: A new entry appears in the React Verification Portal. An administrator can view the uploaded documents, cross-reference the information, and either approve or reject the artisan.
3.  **Status Update**: On approval, the `is_verified` flag in the `workers` table is set to `true`, granting the worker a significant trust and visibility boost in the platform's matching algorithm.

### C. Smart Dispatch & Matching Engine (ASAP Mode)
The "secret sauce" of the platform is a scheduled, multi-round worker notification sequence using a multi-factor scoring algorithm:

1.  **Job Submission**: A client creates a job with `job_mode = 'asap'`.
2.  **Candidate Retrieval & Scoring**: The Express server queries the database for workers within a target radius (using the Haversine formula), filtering by matching category and `is_verified`. Candidates are then scored based on multiple factors:
    -   **Proximity**: Closer workers score higher.
    -   **Ratings**: Higher-rated workers receive a boost.
    -   **Verification**: Verified workers receive a significant score multiplier.
    -   **Location Freshness**: Workers with recently updated locations are preferred.
3.  **Dispatch Rounds**: The Express backend notifies the top-ranked workers in rounds via FCM. If a worker accepts, the job is assigned, and the process stops. If no one accepts after several rounds, the job expires.

### D. Real-Time Job Tracking & Chat
- **Tracking**: While a job is active, the worker's device pings its current latitude and longitude to the backend every 10 seconds. The client's UI subscribes to Supabase Realtime to receive these updates and render the worker's route and ETA on a map.
- **Chat**: Clients and workers can communicate directly within the app. Supabase Realtime is used to deliver messages instantly, and FCM is used to send push notifications for new messages when the app is in the background.

---

## 3. Data Schema Contract

Our relational database structure is designed to enforce data integrity across the ecosystem.

-   **`profiles`**: Central user table linked to `auth.users`. Contains shared data like names, phone numbers, and roles (`client`, `worker`, `admin`).
-   **`workers`**: Extension table for worker-specific data: `skills`, `is_verified`, `current_location`, and average `rating`.
-   **`jobs`**: Contains all details of a job request, including its `status` (`searching`, `matched`, `in_progress`, `completed`).
-   **`reviews`**: Client-provided ratings and comments. A database trigger automatically recalculates the average rating in the `workers` table after a new review is inserted.
-   **`verification_documents`**: Securely stores metadata about documents submitted by workers for verification.

---

**CraftMatch — Empowering Local Skill through Reliable Technology.**
