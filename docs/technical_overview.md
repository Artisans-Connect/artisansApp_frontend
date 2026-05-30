# Artisans App — Technical Project Overview & Consultation

This document provides a comprehensive technical breakdown of the **Artisans App**, a localized on-demand service marketplace designed to connect clients/customers with local skilled artisans (workers) in Ghana (e.g., plumbers, electricians, carpenters). 

This guide is structured to help technical reviewers, examiners, and advisors quickly understand the architecture, database schema, data flows, and active integration challenges. At the end of this document, we highlight several **architectural decisions** where we seek technical feedback and input.

---

## 1. System Architecture

The application is built using a modern decoupled architecture:

```
                      ┌────────────────────────────────┐
                      │        Flutter Client          │
                      │   (Client/Worker UI Shells)    │
                      └───────────────┬────────────────┘
                                      │
                       HTTPS (JWT)    │   Supabase Realtime
                       & FCM Push     │   (Job State Updates)
                                      ▼
  ┌──────────────────────────────────┐ ┌──────────────────────────────────┐
  │         Express.js API           │ │           Supabase BaaS          │
  │   (Central Coordination Layer)   │ │  (Auth, DB, RLS, Storage, Triggers)│
  └─────────────────┬────────────────┘ └────────────────┬─────────────────┘
                    │                                   │
                    │      Reads / Writes (service_role)│
                    └─────────────────► ┌───────────────▼────────────────┐
                                        │      PostgreSQL Database       │
                                        │   (Unified Schema Contract)    │
                                        └────────────────────────────────┘
```

### Key Components
1. **Frontend (Flutter)**: A single multi-role codebase containing:
   - **Client Module**: Discovering workers nearby (map/list view), job posting flow, real-time worker tracking.
   - **Worker Module**: Location pinging, availability toggles, incoming job dispatch alerts, job completion.
   - **Shared Components**: Chat/messaging UI, profile viewing, and settings pages.
2. **Backend (Express.js & TypeScript)**: Coordinates operations that require central scheduling, push notification dispatching, complex query logic, and atomic matching sequences.
3. **Backend-as-a-Service (Supabase)**: Handles passwordless OTP phone authentication, direct client-to-DB real-time event sync, media storage buckets, and automatic database-level triggers (e.g., ratings recalculation, audit logs).

---

## 2. Core Workflows

### A. Passwordless OTP Authentication
- The Flutter frontend uses Supabase Auth directly to execute Phone OTP authentication.
- Upon successful login, the client receives a JWT.
- For all secured API endpoints hosted on the Express.js server, the frontend attaches this JWT as a Bearer token (`Authorization: Bearer <JWT>`).
- The Express.js server uses the Supabase JWT secret to verify the payload, extracts the user ID/role, and checks permissions.

### B. Smart Dispatch & Matching Engine (ASAP Mode)
The "secret sauce" of the matching platform is a scheduled, multi-round worker notification sequence:

1. **Job Submission**: A client creates a job with `job_mode = 'asap'`.
2. **Candidate Retrieval**: The Express server queries the database for workers within a target radius (using the Haversine formula) filtering by matching category, availability, and verification status.
3. **Ranking**: Candidates are ranked by proximity (Ascending) and ratings (Descending).
4. **Dispatch Rounds (3-rounds-of-3)**:
   - **Round 1**: Express notifies the top 3 ranked workers simultaneously via Firebase Cloud Messaging (FCM) and sets the job status to `matching`.
   - **Acceptance Window**: The system waits 90 seconds. If any worker accepts, the job status changes to `matched`, assigning the worker ID, and the dispatch loop stops.
   - **Round 2/3**: If no worker accepts within 90 seconds, the system notifies the next 3 nearest workers.
   - **Expiry**: If no worker accepts after 3 rounds (4.5 minutes), the job status changes to `expired`, and the client is notified.

### C. Real-Time Tracking & Chat
- **Tracking**: While active, the worker's device pings its current latitude and longitude every 10 seconds to `PUT /api/workers/location`. The client UI listens to these updates to render the worker's route and ETA.
- **Chat**: Clients and workers converse inside the app. Message history is fetched via Express, and new messages are dispatched to PostgreSQL. An FCM push notification is sent to the recipient when a new message is received.

---

## 3. Data Schema Contract (`UNIFIED_SCHEMA.md`)

Our relational database structure is designed to enforce data integrity:

- **`profiles`**: Central profile linked directly to Supabase Auth (`id` maps to `auth.users.id`). Contains names, phones, roles (`client` | `worker`), and FCM tokens.
- **`workers`**: Extension table for worker-specific parameters: `skills` array, `hourly_rate`, `current_lat`/`current_lng`, `rating` (1.00 - 5.00), and availability flags.
- **`categories`**: Authoritative service list (e.g., plumbing, carpentry) with slugs and ordering metrics.
- **`jobs`**: Job requests details: client, category, latitude/longitude coords, budget type (fixed or range), schedule timestamps, and status enums (`draft`, `searching`, `matching`, `matched`, `in_progress`, `completed`, `cancelled`, `expired`).
- **`job_applications`**: Keeps track of workers replying to scheduled/flexible job posts.
- **`messages`**: Chat messages associated with a specific job.
- **`reviews`**: Client-provided ratings (1-5 stars) and comments. Recalculates average ratings in `workers` via database triggers.

---

## 4. Key Gaps Currently Identified (Disjunctions)

During code analysis, we identified several discrepancies between the **Flutter UI mockups** and the **Backend Schema**. These are recorded in our docs to be resolved later:
1. **Category Selection**: The UI uses simple string slugs (e.g., `'plumbing'`), whereas the DB expects UUID foreign keys.
2. **Location Capture**: The UI maps to a text address only, whereas the backend matching engine requires numeric coordinates (`location_lat`, `location_lng`).
3. **Budget Modeling**: The UI collects a single `projectBudget` double, whereas the database schema splits ranges into `budget_min` and `budget_max`.
4. **Scheduling**: The UI captures text time-windows (e.g., `'Morning'`), whereas the DB requires a `timestamptz`.
5. **Dependencies**: The frontend `pubspec.yaml` needs to integrate the `supabase_flutter` SDK to establish JWT generation and authentication.

---

## 5. Architectural Consultations — We Need Your Input!

We would highly value your guidance on the following technical dilemmas:

### Question 1: Atomic Job Acceptance & Concurrency
When 3 workers are notified simultaneously, there is a possibility of a race condition where multiple workers tap "Accept" at the exact same moment. 
- **Our proposed solution**: A conditional single-command SQL update:
  ```sql
  UPDATE jobs 
  SET status = 'matched', worker_id = :workerId 
  WHERE id = :jobId AND status IN ('searching', 'matching')
  ```
- **Discussion**: Does this clean conditional `UPDATE` statement in Postgres guarantee atomicity without requiring transaction locks or PG advisory locks? What is the recommended strategy to return a clean `409 Conflict` (already matched) error to the losing workers?

### Question 2: Real-time Worker Location Update Cadence vs. Battery Life
The system relies on workers pinging their coordinates every 10 seconds via `PUT /api/workers/location` to ensure precise HA/ETA matching and client-side map tracking.
- **Discussion**: A 10-second HTTP request loop will cause heavy battery drain on mobile devices and high request volumes on our server. What strategy do you recommend?
  - Should we switch to a WebSocket/gRPC channel for location pings?
  - Should the frontend implement an adaptive ping frequency (e.g., ping every 10s if moving > 10m, but drop to every 60s if stationary)?

### Question 3: Network Drop & Offline Resilience (Ghana Context)
In regions with unstable mobile internet (e.g., MTN/Telecel networks in Ghana), users will experience random disconnections during crucial steps like posting a job or accepting a match.
- **Discussion**: How should we handle request retries on the Flutter client?
  - For job posting, we planned to implement an `Idempotency-Key` header on `POST /api/jobs/create` to prevent duplicate billing or listings. Is there a preferred pattern for caching and retrying failed requests in Flutter offline stores (e.g., using Hive or SQLite)?
  - How do we handle matching rounds if a notified worker goes offline mid-round? Should the backend drop them from the current active matching round automatically if they miss a location ping?

### Question 4: State Syncing (Supabase Realtime vs. Express API)
Clients need to view live updates on their job status (e.g., `searching` -> `matched` -> `worker arrived`). 
- **Discussion**: 
  - Should the Flutter client listen to status updates directly through Supabase's Realtime DB channel, or should it poll/stream them through the Express API? 
  - If Flutter subscribes directly to Supabase tables, what is the best practice to align security (RLS) policies to make sure clients can only listen to their own job statuses?

### Question 5: Database Triggers vs. Express API Controllers
Currently, certain business rules (e.g., recalculating average worker ratings when a new review is inserted, incrementing total jobs, auto-expiring ASAP jobs) are designed to run as database-level SQL triggers.
- **Discussion**: Database triggers keep data operations atomic and fast, but they make the codebase harder to version-control, test, and debug. Do you recommend keeping these calculations in PostgreSQL triggers, or should we move them entirely into the Express.js business logic layer?

---

*Please review these questions and provide your recommendations. Your feedback will shape the implementation of the matching engine (M4) and the client/worker integration phases (M7).*
