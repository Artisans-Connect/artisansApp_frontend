# Future Modification: InDrive-Style Job Acceptance Flow

The current job model uses a "first-to-accept" dispatch system. Workers are pinged in a radius, and the first worker to click "Accept" is instantly assigned the job. To give clients autonomy (inspired by InDrive), we need to transition to an application/bidding system where multiple workers can express interest, and the client chooses the winner.

## Background Context
*   **Database**: The `job_applications` table exists in the schema (from the initial migration) but is completely unused in the backend code. The matching engine relies exclusively on `job_dispatches` and directly updating `jobs.worker_id`.
*   **Backend Routes**: The `POST /workers/accept/:jobId` route currently assigns the job immediately. We need new routes for clients to view and select applicants.
*   **Frontend**: The worker app has an "Accept" button. The client app has no screens for viewing interested workers.

## Proposed Changes

---

### Backend: Database & API

#### [MODIFY] `src/services/workersService.ts`
*   Modify the `acceptJob` function (or create a new `applyToJob` function) so that instead of updating the `jobs` table directly, it inserts a record into the `job_applications` table.
*   Notify the client that a new artisan has shown interest.

#### [NEW] `src/routes/applications.ts` & `src/services/applicationsService.ts`
*   Implement routes for clients to manage applications:
    *   `GET /jobs/:jobId/applications` - Fetch all applications for a specific job, including worker profiles (ratings, distance, stats).
    *   `POST /jobs/:jobId/applications/:appId/accept` - The client accepts a specific application.

#### [MODIFY] `src/services/jobsService.ts`
*   In the new "accept application" logic:
    *   Set `jobs.worker_id` to the selected worker.
    *   Change `jobs.status` from `matching`/`searching` to `matched`.
    *   Mark the chosen application as `accepted`, and all others as `declined`.
    *   Notify the chosen worker.

---

### Frontend: Client App

#### [NEW] `lib/features/client/presentation/screens/job_applicants_screen.dart`
*   Create a new screen accessible from the job details page.
*   Display a list of workers who have applied.
*   Show worker details: Profile picture, name, rating, number of completed jobs, and their proposed rate/message (if applicable).
*   Add an "Accept Artisan" button for each card.

#### [MODIFY] `lib/features/client/presentation/screens/client_job_detail_screen.dart`
*   Add a UI element (e.g., a banner or button) showing the number of applicants.
*   Link this to the new `JobApplicantsScreen`.

#### [MODIFY] `lib/core/services/applications_service.dart`
*   Flesh out the existing service to integrate with the new backend routes for fetching and accepting applications.

---

### Frontend: Worker App

#### [MODIFY] `lib/features/worker/presentation/screens/job_detail_screen.dart`
*   Change the "Accept Job" flow. Instead of instantly getting the job, it should act as an "Apply" button.
*   Optionally, show a bottom sheet allowing the worker to propose a rate or leave a quick message before submitting.

#### [MODIFY] `lib/features/worker/presentation/screens/worker_jobs_screen.dart`
*   Add a tab or section for "Pending Applications" so workers can track jobs they've applied for but haven't been selected for yet.

## Verification Plan

### Automated Tests
*   We'll ensure unit tests cover the new application creation and client selection logic without race conditions.

### Manual Verification
1.  **Worker Flow**: Log in as a worker, view an open job, and submit an application. Verify the job does not instantly switch to "Matched".
2.  **Client Flow**: Log in as the client, navigate to the job details, view the list of applicants, and select one.
3.  **Result**: Verify the job is assigned to the correct worker, the status updates to "Matched", and the worker receives a push notification.
