# CraftMatch App — Technical Project Overview & Consultation

This document provides a comprehensive technical breakdown of the **CraftMatch App**, a localized on-demand service marketplace designed to connect clients/customers with local skilled artisans (workers) in Ghana (e.g., plumbers, electricians, carpenters). 

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
The "secret sauce" of the matching platform is a scheduled, multi-round worker notification sequence using a multi-factor scoring algorithm:

1. **Job Submission**: A client creates a job with `job_mode = 'asap'`.
2. **Candidate Retrieval & Scoring**: The Express server queries the database for workers within a target radius (using the Haversine formula) filtering by matching category and availability. Candidates are then scored based on multiple factors:
   - **Proximity**: Closer workers score higher.
   - **Ratings**: Higher-rated workers receive a boost.
   - **Verification**: Verified workers receive a significant score multiplier.
   - **Location Freshness**: Workers with recently updated locations are preferred.
   - **Experience Band**: More experienced workers receive a slight edge.
3. **Ranking**: Candidates are ranked by their aggregate score (Descending).
4. **Dispatch Rounds (3-rounds-of-3)**:
   - **Round 1**: Express notifies the top 3 ranked workers simultaneously via Firebase Cloud Messaging (FCM) and sets the job status to `matching`.
   - **Acceptance Window**: The system waits 90 seconds. If any worker accepts, the job status changes to `matched`, assigning the worker ID, and the dispatch loop stops.
   - **Round 2/3**: If no worker accepts within 90 seconds, the system notifies the next 3 best-scored workers.
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

*This technical overview reflects the implemented state of the Artisans App as of June 2026.*

