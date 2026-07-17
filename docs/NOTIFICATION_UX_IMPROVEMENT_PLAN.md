# Notification UX Improvement Plan

This document analyzes the current notification experience and proposes a practical improvement plan. The goal is to make notifications feel useful, timely, trustworthy, and clearly connected to the job lifecycle for both client and worker users.

## Current State

The system already has the foundation for notifications:

- Backend stores notifications in the `notifications` table.
- Backend sends push notifications through FCM when device tokens exist.
- Frontend fetches notifications from `/notifications`.
- Frontend supports marking one notification or all notifications as read.
- The notification list has loading, empty, error, unread, icon, and timestamp states.
- Worker job request push can open the worker shell and request detail flow.
- Some client job notifications can deep-link to live tracking when a `jobId` is available.

The current experience still feels thin because notifications behave mostly like a passive list. They do not yet strongly guide the user toward the next useful action.

## Main UX Problems Found

### 1. Some notifications cannot route correctly

Several backend notification events do not include `jobId`, even though the frontend expects `jobId` before routing to job screens.

Examples:

- `job_matched`
- `worker_on_the_way`
- `worker_arrived`
- `job_started`
- `job_completed`
- `job_completion_submitted`
- `job_expired`
- `scheduled_reminder`

Impact:

- User taps a notification and nothing visible may happen.
- The notification feels broken even if it was delivered correctly.
- Client and worker users lose trust in the bell.

### 2. Notification tap destinations are too generic

Current push tap behavior:

- `new_job` opens worker request flow.
- `chat_message` opens the messages list.
- Some job events open live tracking if they have `jobId`.

Needed behavior:

- Chat notifications should open the exact conversation when possible.
- Completion notifications should open the completion approval area, not only the generic tracking screen.
- Worker application accepted should open the worker active booking.
- Termination request should open the worker termination response screen.
- Job expired/cancelled should open a useful job/history state instead of a dead or stale tracking screen.

### 3. Home notification bell is not state-aware

The client home bell currently shows a dot visually, but it is not clearly tied to the real unread notification count.

Impact:

- Users may see an unread signal even when there is nothing new.
- The bell loses meaning.

### 4. No realtime in-app notification refresh

The database table is added to Supabase realtime, but the notification screen currently fetches manually and refreshes by pull-to-refresh.

Impact:

- A user on the notifications screen may not see new notifications arrive immediately.
- The home bell cannot update instantly unless it has a separate unread-count mechanism.

### 5. No notification grouping or job context

Notifications are shown as a flat list. During a job, users can receive several events in quick succession:

- Artisan interested
- Application accepted
- Artisan on the way
- Artisan arrived
- Work started
- Work submitted
- Completion approved

Impact:

- The list can feel noisy.
- Users cannot easily see which job a notification belongs to.
- Repeated status updates do not form a coherent story.

### 6. Notification copy is functional but not action-oriented

The current copy is short and clear, but often misses the next action.

Examples:

- "Work submitted for approval" is useful, but the body should lead the client to review.
- "Application accepted" is useful, but the worker should know to prepare/start going.
- "New message" should ideally include the sender and job context.

### 7. Preferences UI appears local only

The settings screen shows push/email toggles, but the current visible behavior is local UI state. It does not appear connected to persisted backend notification preferences.

Impact:

- User expectation may not match actual behavior.
- Turning off push notifications may not actually change delivery rules.

### 8. Notification priority is not represented

All notifications are visually similar apart from icon/color. A job request expiring soon, a termination request, and a general message should not feel equal.

Impact:

- Urgent events do not stand out enough.
- Worker-side request notifications may be missed.

## Product Goal

Notifications should answer three questions quickly:

1. What happened?
2. Which job or person does it relate to?
3. What should I do next?

For the job lifecycle, the notification system should feel like a guided timeline, not a generic inbox.

## Recommended UX Direction

Use three notification classes:

| Class | Purpose | Examples | UI Treatment |
|---|---|---|---|
| Action Required | User must respond or decide | New job request, completion approval, termination request | High emphasis, action label, persistent unread |
| Status Update | Important lifecycle progress | On the way, arrived, work started, job completed | Medium emphasis, routes to job |
| Informational | Useful but not urgent | Rating posted, reminder, general update | Low emphasis |

## Proposed Notification Metadata Contract

Keep using the existing `data` JSON field, but standardize it.

Every notification should include:

```json
{
  "type": "job_completion_submitted",
  "jobId": "uuid",
  "actorId": "uuid",
  "actorName": "Kwame Mensah",
  "roleTarget": "client",
  "priority": "action_required",
  "route": "client_live_tracking",
  "actionLabel": "Review work",
  "groupKey": "job:uuid",
  "expiresAt": null
}
```

Field meanings:

| Field | Purpose |
|---|---|
| `type` | Stable event type |
| `jobId` | Allows deep-linking and grouping |
| `actorId` | User who caused the event when relevant |
| `actorName` | Better copy and display |
| `roleTarget` | `client` or `worker`; prevents wrong routing |
| `priority` | `action_required`, `status`, or `info` |
| `route` | Frontend destination hint |
| `actionLabel` | CTA text shown on the tile |
| `groupKey` | Groups related job notifications |
| `expiresAt` | Useful for expiring job request notifications |

This does not require an immediate database migration because `data` is already JSON.

## Notification Event Matrix

| Event Type | Target | Required Data | Destination | Action Label |
|---|---|---|---|---|
| `new_job` | Worker | `jobId`, `expiresAt` | Worker request detail/sheet | View request |
| `job_application_received` | Client | `jobId`, `actorName`, `actorId` | Job applicants | View artisan |
| `job_application_accepted` | Worker | `jobId` | Worker active booking | View job |
| `job_matched` | Client | `jobId`, `actorName` | Live tracking | Track job |
| `worker_on_the_way` | Client | `jobId` | Live tracking | Track artisan |
| `worker_arrived` | Client | `jobId` | Live tracking | View status |
| `job_started` | Client | `jobId` | Live tracking | View progress |
| `job_completion_submitted` | Client | `jobId` | Completion approval section | Review work |
| `job_completed` | Client | `jobId` | Rate service or completed job | Rate artisan |
| `client_cancelled_job` | Worker | `jobId`, `stage`, `feeAmount` | Worker history/detail | View cancellation |
| `worker_cancelled_job` | Client | `jobId` | Live tracking/recoverable cancelled state | Request another |
| `job_expired` | Client | `jobId` | Finding/applicants expired state | Try again |
| `termination_requested` | Worker | `jobId` | Worker termination response | Respond |
| `termination_resolved` | Client | `jobId`, `accepted` | Live tracking/history | View update |
| `chat_message` | Client/Worker | `jobId`, `conversationId`, `actorName` | Exact chat thread | Reply |
| `scheduled_reminder` | Client/Worker | `jobId`, `scheduledFor` | Job detail/tracking | View job |

## Screen Improvements

### Notifications List

Improve the list from a simple inbox into a job-aware activity feed.

Recommended changes:

- Add unread count in the app bar: `Notifications (3)` or a compact badge.
- Add filter chips: `All`, `Unread`, `Action needed`, `Jobs`, `Messages`.
- Add sections by recency: `Today`, `Yesterday`, `Earlier`.
- Show job context line where available: `Fix leaking bathroom tap`.
- Show CTA text on actionable notifications: `Review work`, `Respond`, `Track artisan`.
- Add swipe or trailing action to mark a single notification as read/unread.
- Add empty states per filter, not only global empty state.
- Add a "Mark all read" confirmation only when unread count is high, otherwise keep it one tap.

Suggested tile layout:

```text
[icon] Work submitted for approval        3m
       Fix leaking bathroom tap
       Review the completed work and approve it.
       [Review work]                 unread dot
```

### Home Bell

Recommended changes:

- Replace static dot with real unread count.
- Show no badge when unread count is zero.
- Cap display at `9+`.
- Refresh unread count after sign-in, app resume, and notification realtime insert.
- Use a small animation only when a new notification arrives while the app is open.

### In-App Toast/Banner

When the app is open, important events should not only appear in the notification list.

Recommended behavior:

| Event | In-App Treatment |
|---|---|
| New worker request | Existing request sheet, plus request sound/vibration if allowed |
| Completion submitted | Top banner with `Review work` |
| Termination requested | Blocking/high-priority banner for worker |
| Worker cancelled | Banner with `Request another` |
| Chat message | Lightweight banner unless already in the chat |

### Notification Detail Or Group View

Do not build a separate notification-detail screen first. Instead, deep-link to the relevant job/chat screen.

Later enhancement:

- A job activity timeline can group all notifications for one job.
- This could live inside Live Tracking or Booking Detail.

## Routing Improvements

Create a single notification routing mapper in the frontend.

Recommended structure:

```dart
class NotificationDestination {
  final String routeName;
  final Object? arguments;
  final bool requiresAuth;
  final String fallbackRoute;
}
```

This mapper should be used by:

- Push tap handler in `NotificationService`.
- Notification list tile tap handler in `NotificationsScreen`.
- Any future in-app notification banner.

This avoids duplicated logic and mismatched behavior.

Routing rules:

- If `type == new_job`, open `WorkerShell` with `openJobRequestId`.
- If `type == job_application_received`, open job applicants for that job.
- If `type == job_application_accepted`, open worker active bookings tab.
- If `type` is a client tracking update, open live tracking with `jobId`.
- If `type == job_completion_submitted`, open live tracking and scroll/focus completion approval.
- If `type == job_completed`, open rate service if not rated; otherwise completed booking.
- If `type == chat_message`, open exact chat when `conversationId` or `jobId` exists.
- If required data is missing, open notifications list and show a non-blocking message: `This update is missing job details.`

## Backend Improvements

### Phase 1 backend fixes

- Add `jobId` to every job lifecycle notification.
- Add `roleTarget`, `priority`, `route`, `actionLabel`, and `groupKey` inside `data`.
- Include actor name where relevant.
- For chat notifications, include `conversationId` or make `jobId` reliably usable as the chat conversation id.
- Add job title to notification data or body where useful.

### Phase 2 backend improvements

- Add unread-count endpoint: `GET /notifications/unread-count`.
- Add optional endpoint filters: `GET /notifications?status=unread&type=job&limit=50`.
- Add mark unread endpoint if the UI supports it.
- Add preference persistence:
  - `push_enabled`
  - `email_updates_enabled`
  - optional per-category settings: jobs, messages, reminders, promotions.
- Respect preferences before sending push/email.

### Phase 3 backend improvements

- Add notification deduplication for noisy events.
- Add grouping rules for repeated job status updates.
- Add expiry handling for expired worker request notifications.

## Frontend Implementation Plan

### Phase 1: Make existing notifications reliable

Priority: High

Tasks:

- Centralize notification tap routing.
- Support all current backend event types in the mapper.
- Add graceful fallback when `jobId` is missing.
- Fix home bell badge to use real unread count or hide until count is known.
- Make notification list tap behavior match push tap behavior.
- Add `job_application_received` and `job_application_accepted` routing.
- Improve chat push tap to open exact chat when data allows.

Expected result:

- Tapping a notification always does something predictable.
- The bell no longer lies about unread state.

### Phase 2: Improve the notification list feel

Priority: High

Tasks:

- Add filters: `All`, `Unread`, `Action needed`.
- Add section headers: `Today`, `Yesterday`, `Earlier`.
- Add action labels on tiles.
- Add job context line when `jobTitle` exists.
- Improve empty states for filters.
- Improve unread visual treatment so it is noticeable but not noisy.
- Add loading skeleton polish consistent with the rest of the app.

Expected result:

- Notifications feel organized and easier to scan.

### Phase 3: Add realtime and in-app feedback

Priority: Medium

Tasks:

- Subscribe to `notifications` realtime inserts for the signed-in user.
- Update unread badge immediately when a new notification arrives.
- Show an in-app banner for important events when user is not already on the relevant screen.
- Avoid duplicate banners when the user is already viewing that job/chat.
- Refresh notification list automatically on insert.

Expected result:

- Notifications feel alive while the app is open.

### Phase 4: Make preferences real

Priority: Medium

Tasks:

- Persist notification preferences in the backend.
- Load preferences in Settings.
- Respect preferences in push delivery.
- Keep critical job safety notifications enabled or clearly explain if they cannot be disabled.

Expected result:

- Settings match actual behavior.

### Phase 5: Group by job activity

Priority: Low to Medium

Tasks:

- Use `groupKey` to group multiple updates for the same job.
- Show compact grouped rows such as `3 updates for Fix leaking bathroom tap`.
- Add a job activity timeline inside live tracking or booking detail.

Expected result:

- The notification list becomes less noisy during active jobs.

## Copy Improvements

Use direct, action-led copy.

| Event | Current Style | Better Direction |
|---|---|---|
| New job | New job request | New request nearby |
| Worker applied | New artisan interested | Kwame wants to take your job |
| Application accepted | Application accepted | You were selected for this job |
| On the way | Artisan on the way | Kwame is on the way |
| Arrived | Artisan arrived | Kwame has arrived |
| Work started | Work started | Work has started |
| Completion submitted | Work submitted for approval | Review the completed work |
| Worker cancelled | Artisan cancelled | Your artisan cancelled. Request another worker |
| Termination requested | Client requests job termination | Client wants to stop the job |
| Chat | New message | New message from Ama |

Guidelines:

- Put the actor name in the title/body when known.
- Mention the job title in the second line or body.
- Use the CTA to state the next action.
- Avoid vague text like `View update` for high-priority actions.

## UX Acceptance Criteria

The improved notification system should pass these checks:

- The notification bell shows a badge only when unread notifications exist.
- Tapping every notification type leads to the right screen or a clear fallback.
- Every job lifecycle notification includes `jobId`.
- Action-required notifications are visually distinct.
- Completion-submitted notification takes the client to approval context.
- Termination-requested notification takes the worker to the response context.
- Chat notification opens the exact relevant chat where possible.
- Mark all as read updates the badge immediately.
- Realtime insert updates the list/badge without manual refresh.
- Preferences shown in Settings match actual delivery behavior.

## Manual Test Scenarios

| ID | Scenario | Expected |
|---|---|---|
| NUX-01 | Client has no unread notifications | Home bell shows no badge |
| NUX-02 | Client receives worker application | Bell badge increments; notification opens applicants |
| NUX-03 | Client accepts worker | Worker receives accepted notification; tap opens active job |
| NUX-04 | Worker marks on the way | Client receives update; tap opens live tracking |
| NUX-05 | Worker submits completion | Client receives action-required notification; tap opens approval context |
| NUX-06 | Client requests termination | Worker receives high-priority notification; tap opens termination response |
| NUX-07 | Chat message arrives | Recipient sees banner/list update; tap opens exact chat |
| NUX-08 | Mark all read | All unread visuals clear; badge becomes zero |
| NUX-09 | Missing `jobId` fallback | App does not dead-end; user sees clear fallback behavior |
| NUX-10 | Push disabled in settings | Non-critical push notifications stop after preference save |

## Recommended First Implementation Batch

Do these first:

1. Add missing `jobId` to backend job lifecycle notifications.
2. Centralize frontend notification routing.
3. Fix home bell unread badge.
4. Add action labels and better tile metadata handling.
5. Add list filters for `All`, `Unread`, and `Action needed`.

This batch gives the biggest perceived UX gain without needing a database migration.

## Open Decisions

- Should critical job notifications always bypass user push preferences?
- Should completed jobs route to rating first or booking history if the user already rated?
- Should worker request notifications expire visually after dispatch expiry?
- Should notification grouping happen in the notification list first, or inside job detail as an activity timeline?
- Should chat notifications include message preview text, or only sender and job context for privacy?

