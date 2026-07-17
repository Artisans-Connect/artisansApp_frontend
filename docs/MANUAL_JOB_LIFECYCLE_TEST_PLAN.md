# Manual Job Lifecycle Test Plan

This plan is for manually testing the full job journey from the moment a client posts a job until the job is completed, approved, rated, and reflected in history, earnings, and profile stats.

The focus is not only whether each button works. The focus is whether every screen section works, navigation is correct, and the client and worker sides stay in sync during the same job flow.

## Scope

Test these surfaces:

- Client app job flow: home, discovery, job post wizard, matching/applicants, live tracking, completion approval, rating, history.
- Worker app job flow: availability, requests, request detail, application/acceptance, active job, arrival/start, completion, pending approval, history, earnings.
- Shared screens used during the flow: messages, chat detail, notifications, profile, settings.
- Backend state sync visible in the app: job status, assigned worker, worker availability, applications, completion details, notifications, and history.

Out of scope for this document:

- Automated test scripts.
- Admin verification portal testing, except where worker verification affects job visibility.
- Deep API-only testing unless a visible app state needs confirmation.

## Test Accounts And Setup

Use at least these accounts:

| Account | Role | Required State |
|---|---|---|
| Client A | Client | Completed profile, usable location permissions |
| Worker A | Worker | Verified or demo-verified, available, has matching skill/category, fresh location |
| Worker B | Worker | Verified or demo-verified, available, same skill/category, fresh location |
| Worker C | Worker | Unavailable or stale location, same skill/category |

Recommended devices:

| Device | Purpose |
|---|---|
| Device 1 | Client A |
| Device 2 | Worker A |
| Device 3 | Worker B or second worker session |

Before each full run:

- Confirm all test users can sign in.
- Confirm Client A has no active job unless the test case requires one.
- Confirm Worker A has no active or pending-approval job.
- Confirm Worker A availability is on.
- Confirm Worker A location is current.
- Confirm Worker A has the category skill you will select in the job post wizard.
- Keep both client and worker apps visible where possible.

Suggested test job data:

| Field | Value |
|---|---|
| Category | Electrical or Plumbing |
| Subcategory | A real subcategory under the chosen category |
| Title | Fix leaking bathroom tap |
| Description | Tap has been leaking since yesterday. Please check the valve and replace worn parts if needed. |
| Photos | 1 to 3 clear images |
| Location | A location close to Worker A |
| Urgency | ASAP for the main happy path |

## Pass Criteria

A test passes when:

- The user can complete the intended action without app crashes, dead ends, or unclear blocking states.
- Navigation goes to the expected next screen and back navigation returns to the expected previous screen.
- Required sections on each screen display correct and current data.
- Client and worker screens show the same job state within a reasonable realtime refresh window.
- Terminal states are reflected in history, earnings, ratings, and active-job empty states.

## Core Job Status Map

Use this status map while testing sync:

| Backend State | Client Should See | Worker Should See |
|---|---|---|
| `searching` or `matching` | Finding/applicants state; job visible in bookings as active/requested | Job request visible if dispatched or eligible |
| Worker application `pending` | Applicant appears with quote and worker details | Application submitted; request no longer actionable as new |
| `matched` | Live tracking with assigned worker | Active job pre-start |
| `on_the_way` | Live tracking shows worker on the way | Active job pre-start, on-way phase |
| `arrived` | Live tracking shows arrived state | Active job pre-start, arrived/start-work phase |
| `in_progress` | Live tracking shows work in progress | Active in-progress screen with timer/completion action |
| `pending_client_approval` | Completion review/approval controls | Pending approval screen |
| `completed` | Rating flow, then completed history | Success/empty active job; history and earnings updated |
| `cancelled` | Cancelled state and history | Active job cleared if assigned; history updated |

## Full Happy Path Script

Run this first before edge cases.

| Step | Actor | Screen | Action | Expected Client State | Expected Worker State |
|---|---|---|---|---|---|
| 1 | Worker A | Worker Requests | Turn availability on and allow/update location | No change yet | Availability shows on; location-dependent requests can appear |
| 2 | Client A | Client Home | Start posting a job from category/search | Job post wizard opens | No request yet |
| 3 | Client A | Job Post Category | Select matching category | Advances to subcategory | No request yet |
| 4 | Client A | Job Post Subcategory | Select matching subcategory | Advances to details | No request yet |
| 5 | Client A | Job Post Details | Enter title, description, photos | Valid data persists | No request yet |
| 6 | Client A | Location/Schedule | Select location and ASAP | Summary becomes available | No request yet |
| 7 | Client A | Summary | Review and post job | Goes to matching/finding or applicants flow | Worker request appears by sheet or requests list |
| 8 | Worker A | Job Request Detail | Open request | Client still sees matching/applicants wait state | Full job detail shown with quote and Accept/Decline |
| 9 | Worker A | Job Request Detail | Apply/accept request | Applicant appears on client side | Application submitted; request no longer behaves like untouched request |
| 10 | Client A | Job Applicants | Open applicant details and accept Worker A | Live tracking opens or booking becomes matched | Worker active job appears in Bookings |
| 11 | Worker A | Active Pre-Start | Mark on the way | Live tracking changes to on-the-way | Worker phase changes to on-the-way |
| 12 | Worker A | Active Pre-Start | Mark arrived | Live tracking changes to arrived | Worker phase changes to arrived |
| 13 | Worker A | Active Pre-Start | Start job | Live tracking changes to in-progress | In-progress screen appears with timer |
| 14 | Worker A | Completion Form | Submit time/materials/photos/notes | Client sees pending completion approval | Worker sees pending approval |
| 15 | Client A | Live Tracking | Review completion details and approve | Job becomes completed; rating flow available | Worker active job clears or success state appears |
| 16 | Client A | Rate Service | Submit rating and review | Completed job appears in history | Worker stats/reviews update |
| 17 | Worker A | History/Earnings/Stats | Open history, earnings, stats | No change | Completed job and payout/stat changes are visible |

## Module 1: Client Home

Screen reference: `10_client_home.png`

Test sections:

| Section | Checks |
|---|---|
| Header/profile entry | Correct user name/avatar if shown; profile navigation works; back returns to home |
| Search/service entry | Typing works; empty search does not crash; valid search routes to discovery/explore |
| Categories | Categories load; icons/names match backend categories; tap opens correct job/category path |
| Featured/nearby artisans | Cards show name, rating, skill, distance/availability where applicable |
| Active job banner | Hidden when no active job; visible and navigates correctly when a job is active |
| Bottom navigation | Home, Bookings, Messages, Profile tabs switch without pushing duplicate screens |
| Notifications entry | Opens notifications; unread/read state does not break navigation |

Navigation checks:

- Home to category job post.
- Home to explore artisans.
- Home to artisan profile.
- Home to active job tracking when active banner is visible.
- Bottom nav to Bookings, Messages, Profile, then back to Home.

Sync checks:

- After posting a job, returning to Home should show the active job banner.
- After completion, Home should stop showing active job unless another active job exists.

## Module 2: Explore Artisans

Screen reference: `11_explore_artisans.png`

Test sections:

| Section | Checks |
|---|---|
| Search bar | Query filters results; clearing query restores list |
| Category/filter controls | Filter applies; selected filter is visually clear |
| Artisan cards | Name, rating, skill, verification, distance, price/rate if shown |
| Empty state | Shows understandable state for no matching workers |
| Error/loading state | Loading indicator appears; retry works if exposed |
| Card tap | Opens the correct artisan profile |

Navigation checks:

- Back returns to Client Home or previous route.
- Map discovery entry opens the map screen if available.
- Artisan card opens profile with the same worker information.

Sync checks:

- Worker availability off should eventually remove or mark that worker unavailable.
- Worker stale/missing location should not produce misleading accurate distance.

## Module 3: Map Discovery

Screen reference: `12_map_discovery.png`

Test sections:

| Section | Checks |
|---|---|
| Map render | Map loads, centers appropriately, and does not show a blank surface |
| Worker markers | Markers match nearby/eligible workers |
| Location permission | Denied permission shows recoverable message |
| Marker selection | Opens worker preview or profile |
| Current location | Button recenters when available |

Navigation checks:

- Back returns to Explore/Home.
- Marker/profile flow routes to Artisan Profile.

Sync checks:

- Worker A location update changes marker/distance after refresh.
- Worker unavailable does not remain as an active selectable worker without indication.

## Module 4: Artisan Profile And Direct Request

Screen reference: `13_artisan_profile.png`

Test sections:

| Section | Checks |
|---|---|
| Profile header | Name, avatar, skill, verification, rating are correct |
| Availability | Available/busy/unavailable state is accurate |
| Bio/about | Text fits and does not overflow |
| Services/skills | Skills match worker profile |
| Reviews | Review list loads; empty state works |
| Gallery | Images load; broken images do not break screen |
| Book/request button | Disabled or guarded when worker is busy/unavailable |

Navigation checks:

- Back returns to Explore or Map.
- Book/request opens Direct Worker Request or job wizard with worker attached.
- Message/contact entry opens chat when available.

Sync checks:

- If Worker A is assigned to another active job, direct request should be blocked or show busy.
- A direct request should appear only for the requested worker, not all workers.

## Module 5: Job Post Wizard

Screens:

- `20_job_post_category.png`
- `21_job_post_subcategory.png`
- `22_job_post_title.png`
- `23_job_post_description.png`
- `24_job_post_location.png`
- `25_job_post_urgency.png`
- `26_job_post_summary.png`

### 5.1 Category Screen

| Section | Checks |
|---|---|
| Category list/grid | Loads active categories only; labels/icons match backend catalog |
| Selection state | Selected category is clear |
| Continue action | Disabled until selection; routes to subcategory after selection |
| Back | Returns to previous screen without corrupting draft |

### 5.2 Subcategory Screen

| Section | Checks |
|---|---|
| Subcategory list | Shows subcategories for selected category only |
| Selection | Selected subcategory persists |
| Empty state | Handles category with no subcategories |
| Continue/back | Continue routes to details; back preserves category |

### 5.3 Details Screen

| Section | Checks |
|---|---|
| Title field | Required; handles short/long input; no overflow |
| Description field | Required if intended; long text scrolls correctly |
| Photo picker | Add, preview, remove photos; handles permission denial |
| Validation | Prevents moving forward with missing required fields |
| Draft persistence | Back/forward keeps entered data |

### 5.4 Location And Schedule Screen

| Section | Checks |
|---|---|
| Map/location picker | Selects address/coordinates correctly |
| Current location | Permission accepted/denied paths work |
| Address label | Shows readable label |
| Urgency mode | ASAP and scheduled/flexible options behave correctly |
| Scheduled time | Rejects invalid past time; accepts valid future time |
| Continue | Disabled until required location and schedule fields are valid |

### 5.5 Summary Screen

| Section | Checks |
|---|---|
| Summary cards | Category, subcategory, title, description, photos, location, urgency all match draft |
| Edit actions | Each edit returns to correct wizard step and preserves other fields |
| Price/quote hints | If shown, values are consistent with selected category/job mode |
| Submit button | Shows loading once; prevents duplicate posts |
| Error handling | Network/server validation errors are visible and recoverable |

Navigation checks for full wizard:

- Forward path works from every step.
- Back path works from every step.
- Editing from Summary returns to Summary or continues without losing data.
- Device back does not silently post or lose data without warning if the app has a discard prompt.

Sync checks after submit:

- Client sees the new job in matching/finding/applicants/bookings.
- Eligible worker receives request.
- Ineligible worker does not receive request.
- Duplicate tapping submit does not create duplicate active jobs.

## Module 6: Finding Artisan And Applicants

Screens:

- `14_finding_artisan.png`
- `job_applicants_screen.dart`

Test sections:

| Section | Checks |
|---|---|
| Matching progress | Shows current state while no applicant has applied |
| Applicant list | New applications appear without requiring confusing navigation |
| Applicant card | Worker name, rating, quote, distance, message, verification are shown |
| Accept action | Assigns selected worker and routes to tracking |
| Multiple applicants | Accepting one declines/removes other pending applicants correctly |
| Empty/timeout | Handles no workers or expired matching without dead end |

Navigation checks:

- Back from applicants should not abandon the job.
- Opening a worker profile from applicant card returns to applicants.
- Accepting an applicant should not leave user on stale applicant list.

Client-worker sync checks:

- When Worker A applies, Client A sees Worker A in applicants.
- Worker B applying also appears as a separate applicant.
- Client accepting Worker A changes Worker A to active job.
- Worker B should no longer be able to act on the same job after Worker A is accepted.

## Module 7: Worker Requests

Screens:

- `40_worker_requests.png`
- Realtime request bottom sheet

Test sections:

| Section | Checks |
|---|---|
| Availability toggle | On/off state persists and affects request visibility |
| Location requirement | Stale/missing location shows proper message before applying |
| Request list | Eligible jobs appear with title, category, location, urgency, quote if available |
| Realtime sheet | New request opens once; duplicate sheets do not stack |
| Pull-to-refresh/retry | Updates list and handles errors |
| Empty state | Shows useful idle state when no requests exist |

Navigation checks:

- Request card opens Job Request Detail.
- Bottom sheet can be dismissed and job remains available if not expired.
- Bottom nav to Bookings/Messages/Profile works from request screen.

Sync checks:

- Client posts job, Worker A sees request.
- Worker A declines, job remains open for other workers or matching continues.
- Worker A applies, request is no longer treated as a fresh request.
- Worker availability off prevents new requests from being dispatched/displayed.

## Module 8: Worker Job Request Detail

Screen reference: `41_worker_job_detail.png`

Test sections:

| Section | Checks |
|---|---|
| Job header | Title, category, urgency, time posted are correct |
| Client summary | Client name/avatar if shown |
| Location/map | Address and distance are correct enough for test data |
| Description | Full description and photos are visible |
| Quote section | Base fee, distance cost, urgency premium, total quote display correctly |
| Accept/apply | Sends application once and shows loading/confirmation |
| Decline | Removes request and returns to requests list |
| Expired/taken state | Shows clear message if job is no longer available |

Navigation checks:

- Back returns to Worker Requests.
- Accept does not incorrectly route to active job before client acceptance if the product uses an applicant-selection model.

Sync checks:

- Accept/apply creates a pending application on client side.
- Decline does not create an applicant.
- If client accepts another worker before Worker A acts, Worker A sees job unavailable.

## Module 9: Client Live Tracking

Screen reference: `31_live_tracking.png`

Test sections:

| Section | Checks |
|---|---|
| Worker card | Assigned worker details match accepted applicant |
| Job info | Title, category, address, quote/status match posted job |
| Map/tracking | Worker location is shown when available; map is not blank |
| Timeline | Status steps update for matched, on the way, arrived, in progress, pending approval |
| Chat/contact | Opens conversation with assigned worker |
| Cancel section | Cancellation preview and rules match current status |
| Completion actions | Hidden before worker submits completion; shown when pending approval |
| Settlement details | Amounts/details match worker completion details |

Navigation checks:

- Back to bookings, then re-open tracking for same active job.
- Chat opens and back returns to tracking.
- Cancel modal returns to tracking when dismissed.

Sync checks:

- Worker marks on-the-way: client timeline updates.
- Worker marks arrived: client timeline updates.
- Worker starts job: client timeline updates to in-progress.
- Worker submits completion: client sees approval/reopen controls.
- Client approves: worker leaves active job and client moves to rating/completed state.

## Module 10: Worker Active Pre-Start

Screen references:

- `42_worker_active_pre_start.png`
- `60_worker_active_empty.png`

Test sections:

| Section | Checks |
|---|---|
| Active job card | Job title, client, address, category, quote are correct |
| Map/location | Job location visible |
| Contact/chat | Opens correct client chat |
| Phase action | Correct next action appears for matched/on-the-way/arrived |
| Cancel action | Cancels only assigned active job and requires reason if intended |
| Empty state | Shows when no active job exists |

Navigation checks:

- Bookings tab opens active job when assigned.
- Explore tab still works but worker should not accept another blocking job.
- Messages/Profile tabs work without losing active job state.

Sync checks:

- After client accepts Worker A, Worker A active job appears.
- Mark on-the-way updates client.
- Mark arrived updates client.
- Start work updates client and changes worker screen to in-progress.
- Client cancellation clears worker active job.

## Module 11: Worker Active In Progress

Screen reference: `43_worker_active_in_progress.png`

Test sections:

| Section | Checks |
|---|---|
| Timer | Timer starts from job start time and continues after navigation away/back |
| Job/client details | Still correct during in-progress state |
| Completion CTA | Opens completion form |
| Termination request state | If client requests termination, screen changes to termination response |
| Cancel/stop controls | Only valid controls are available for in-progress state |

Navigation checks:

- Completion CTA opens completion form.
- Back from completion form returns to in-progress job.
- Messages/Profile navigation does not reset timer incorrectly.

Sync checks:

- Client sees in-progress while worker timer is active.
- If client requests termination, worker sees termination requested.
- If worker resumes from app restart, active in-progress job still loads.

## Module 12: Worker Completion Form

Screen reference: `44_worker_completion_form.png`

Test sections:

| Section | Checks |
|---|---|
| Time/hours | Auto-calculated or manually displayed hours are reasonable |
| Materials used | Optional/required behavior is correct |
| Notes | Accepts useful completion note; handles long text |
| Photos | Add/remove completion photos; permission denial works |
| Proposed/final amount | Amount field and settlement values are valid if shown |
| Submit | Shows loading; prevents duplicate submission |
| Validation | Missing required fields block submission with clear message |

Navigation checks:

- Submit routes to pending approval/success state.
- Back before submit returns to in-progress without losing the job.

Sync checks:

- Client sees pending approval after submit.
- Worker active tab shows pending approval.
- Job is not marked completed until client approves.
- Worker should not become available for another active job while pending approval.

## Module 13: Worker Pending Approval And Success

Screen references:

- `45_worker_completion_success.png`
- `worker_pending_approval_screen.dart`

Test sections:

| Section | Checks |
|---|---|
| Pending approval message | Clear state while waiting for client |
| Completion details | Submitted notes/photos/amounts remain visible if shown |
| Navigation | Worker can use Messages/Profile while waiting |
| Success state | Appears or active job clears after client approval |
| Active empty state | Bookings shows no active job after completion |

Sync checks:

- Client approval clears Worker A active job.
- Worker A availability becomes available after terminal completion.
- Job appears in Worker A history.
- Earnings update with payout.

## Module 14: Client Completion Approval

Screen: live tracking pending approval state

Test sections:

| Section | Checks |
|---|---|
| Completion summary | Notes, materials, photos, hours, and amount match worker submission |
| Approve action | Marks job completed and routes to rating or completed state |
| Reopen/dispute action | Sends job back to in-progress with note |
| Settlement details | Gross amount, platform fee, payout if shown are correct and readable |
| Error handling | Double approve does not create inconsistent state |

Navigation checks:

- Approve routes to rating.
- Reopen returns to tracking/in-progress state.
- Back to bookings and reopen tracking retains pending approval controls until action.

Sync checks:

- Approve changes worker active job to success/empty.
- Reopen changes worker job back to in-progress.
- Completion details persist after approval.

## Module 15: Rate Service

Screen reference: `32_rate_service.png`

Test sections:

| Section | Checks |
|---|---|
| Rating control | Selects 1 to 5 stars correctly |
| Review field | Accepts comment; handles empty comment if allowed |
| Worker/job summary | Shows correct worker and job |
| Submit | Sends once and shows confirmation/navigation |
| Validation | Blocks invalid rating if rating is required |

Navigation checks:

- Submit returns to booking history/home as intended.
- Back behavior does not allow accidental duplicate rating without guard.

Sync checks:

- Review appears in worker profile/stats/reviews.
- Worker rating/review count updates after refresh.
- Completed job remains completed if rating fails and user retries.

## Module 16: Client Booking History

Screen reference: `30_booking_history.png`

Test sections:

| Section | Checks |
|---|---|
| Active/requested jobs | New job appears after posting |
| Matched/in-progress jobs | Active job status is current |
| Completed jobs | Completed job appears with worker and final amount/status |
| Cancelled jobs | Cancelled jobs appear with correct status if product includes them |
| Detail navigation | Opens live tracking/detail for active jobs and receipt/detail for completed jobs |
| Empty state | Shows when no bookings exist |

Navigation checks:

- Bottom nav Bookings opens this screen.
- Active job tap opens Live Tracking.
- Completed job tap opens receipt/detail/rating if available.

Sync checks:

- Status changes match worker action sequence.
- After completion approval, job moves from active to completed section.

## Module 17: Worker Booking History

Screen reference: `63_worker_booking_history.png`

Test sections:

| Section | Checks |
|---|---|
| Completed jobs | Completed job appears with client, date, status, amount |
| Cancelled jobs | Worker/client cancelled jobs appear correctly |
| Detail view | Opens read-only detail for historical job |
| Empty state | Works for new worker |

Sync checks:

- Job appears only after terminal status: completed or cancelled.
- Completion details and payout match worker completion form.

## Module 18: Worker Earnings

Screen reference: `61_worker_earnings.png`

Test sections:

| Section | Checks |
|---|---|
| Total earned | Includes completed jobs only |
| Job earnings list | Shows completed job, gross amount, platform fee, payout |
| Empty state | Shows zero state for no completed jobs |
| Refresh | Newly completed job appears after approval/refresh |

Sync checks:

- Pending approval job should not be counted as earned.
- Completed job should be counted after client approval.

## Module 19: Worker Stats And Reviews

Screen reference: `62_worker_stats.png`

Test sections:

| Section | Checks |
|---|---|
| Total jobs | Increments after completed job |
| Rating | Updates after client rating |
| Review count | Increments after rating submission |
| Recent reviews | Shows Client A review if visible |
| Response time | Does not show broken/null labels |

Sync checks:

- Stats do not increment before client approval.
- Review does not appear before rating submission.

## Module 20: Shared Messages And Chat

Screens:

- `50_messages_list.png`
- `51_chat_detail.png`

Test sections:

| Section | Checks |
|---|---|
| Conversation list | Conversation appears for client and assigned/applied worker as intended |
| Chat header | Shows correct counterpart |
| Send message | Text sends and appears on both sides |
| Realtime receive | Other side receives without manual restart |
| Empty/error states | No crash with empty conversation |
| Attachments if available | Upload/send behavior works or is clearly unavailable |

Navigation checks:

- Open chat from Live Tracking.
- Open chat from Worker Active job.
- Open chat from bottom Messages tab.
- Back returns to the screen that opened chat.

Sync checks:

- Client message appears on worker side.
- Worker message appears on client side.
- Conversation remains accessible after completion if product intends history.

## Module 21: Notifications

Screen: notifications screen and any push/in-app notification surface

Test events:

| Event | Expected Client Notification | Expected Worker Notification |
|---|---|---|
| Client posts job | None or matching confirmation | New job request |
| Worker applies | Worker applied | Application submitted/none |
| Client accepts worker | Job matched | Application accepted |
| Worker on the way | Worker on the way | None or local state |
| Worker arrived | Worker arrived | None or local state |
| Worker starts job | Job started | None or local state |
| Worker submits completion | Completion submitted | Waiting for approval |
| Client approves | Completed/rating prompt | Completion approved |
| Client cancels | Cancellation confirmation | Client cancelled |
| Worker cancels | Worker cancelled | Cancellation confirmation |

Checks:

- Notification opens the correct screen.
- Notification does not route to 404/not-found.
- Read/unread state updates if supported.
- Notifications do not duplicate excessively for one action.

## Module 22: Cancellation Paths

Run these separately from the happy path.

### 22.1 Client Cancels Before Match

| Step | Expected |
|---|---|
| Client posts job and cancels during searching/matching | Job becomes cancelled; worker requests disappear or become unavailable |
| Worker opens old request | Shows unavailable/expired state |
| Client bookings | Shows cancelled state or removes active job according to product design |

### 22.2 Client Cancels After Match

| Step | Expected |
|---|---|
| Client accepts worker, then cancels | Cancellation preview appears; job becomes cancelled after confirmation |
| Worker side | Active job clears and history shows cancelled |
| Availability | Worker becomes available again |

### 22.3 Client Cancels While Worker On The Way

| Step | Expected |
|---|---|
| Worker marks on-the-way | Client cancellation preview shows travel-compensation stage if configured |
| Client confirms cancellation | Worker notified; active job clears |

### 22.4 Client Requests Termination During Work

| Step | Expected |
|---|---|
| Worker starts job | Client cannot normal-cancel; can request termination |
| Client requests termination | Worker sees termination requested screen |
| Worker accepts termination | Job becomes cancelled and both sides update |
| Worker declines termination | Job returns to in-progress on both sides |

### 22.5 Worker Cancels Assigned Job

| Step | Expected |
|---|---|
| Worker cancels matched/on-way/arrived/in-progress job | Client sees worker cancelled |
| Client requests another worker | Job reopens to matching |
| Old worker | Application withdrawn; active job clears |
| New worker | Can receive/apply for reopened job |

## Module 23: Reopen After Completion Submission

| Step | Actor | Expected |
|---|---|---|
| Worker submits completion | Worker | Job becomes pending approval |
| Client reviews and taps reopen/dispute | Client | Job returns to in-progress |
| Worker checks Bookings | Worker | In-progress screen returns |
| Worker resubmits completion | Worker | Pending approval returns |
| Client approves | Client | Job completes |

Sync checks:

- Worker should not be free for another active job while completion is disputed.
- Completion details update or remain consistent after resubmission.

## Module 24: Multi-Worker And Race Conditions

| Scenario | Steps | Expected |
|---|---|---|
| Two workers apply | Worker A and Worker B apply to same job | Client sees both applicants |
| Accept one worker | Client accepts Worker A | Worker A active; Worker B cannot act on job |
| Late accept attempt | Worker B opens stale request/detail | Shows unavailable/taken state |
| Busy worker applies | Worker with active job tries to apply | Blocked with active job message |
| Duplicate client submit | Client double taps post | Only one job is created |
| Duplicate worker apply | Worker double taps accept/apply | Only one application exists |
| Duplicate completion submit | Worker double taps completion | One pending approval record; no double payout |
| Duplicate client approval | Client double taps approve | One completed job; no duplicate history/earnings |

## Module 25: Scheduled And Flexible Jobs

Run after ASAP is stable.

| Scenario | Expected |
|---|---|
| Scheduled future job | Job should not dispatch immediately if backend keeps scheduled jobs as draft |
| Scheduled job near activation window | Dispatches/appears when activation rules apply |
| Flexible job | Enters matching if configured; applicants behave like ASAP except urgency premium rules |
| Past scheduled time | Validation blocks it |
| Edit schedule before submit | Summary reflects updated schedule |

## Module 26: Offline, Refresh, And Session Recovery

| Scenario | Expected |
|---|---|
| Client loses network during job post submit | Clear error; retry does not duplicate job |
| Worker loses network during apply | Clear error; retry handles already-applied state correctly |
| Client app restart during matching | Active job restored in bookings/finding/applicants |
| Worker app restart after matched | Active job restored in bookings |
| Worker app restart during in-progress | Timer and active job restored |
| Client app restart during pending approval | Approval controls still visible |
| Token/session expiry | User is asked to sign in; no broken partial screen |

## Module 27: Screen-by-Screen Navigation Matrix

| From Screen | Action | Expected Destination | Back Destination |
|---|---|---|---|
| Splash/Auth | Sign in as client | Client Home | Exit/app root |
| Splash/Auth | Sign in as worker | Worker Shell | Exit/app root |
| Client Home | Tap category/post job | Job Post Category | Client Home |
| Client Home | Tap explore/search | Explore Artisans | Client Home |
| Explore Artisans | Tap map | Map Discovery | Explore Artisans |
| Explore Artisans | Tap artisan | Artisan Profile | Explore Artisans |
| Artisan Profile | Book/request | Direct Request or Job Wizard | Artisan Profile |
| Job Post Category | Continue | Job Post Subcategory | Job Post Category |
| Job Post Subcategory | Continue | Job Post Details | Job Post Subcategory |
| Job Post Details | Continue | Location/Schedule | Job Post Details |
| Location/Schedule | Continue | Job Post Summary | Location/Schedule |
| Job Post Summary | Post | Finding/Applicants | Summary should not remain stale |
| Finding/Applicants | Accept applicant | Live Tracking | Booking history or applicants based on design |
| Live Tracking | Chat | Chat Detail | Live Tracking |
| Live Tracking | Approve completion | Rate Service | Completed booking or tracking based on design |
| Rate Service | Submit | Booking History or Home | Should not return to stale rating form |
| Worker Requests | Tap request | Worker Job Detail | Worker Requests |
| Worker Request Sheet | Accept/apply | Sheet closes or confirmation | Worker Requests |
| Worker Bookings | Active job | Active Pre-Start/In-Progress | Bookings tab |
| Active Pre-Start | Start job | Active In-Progress | Active Pre-Start or Bookings |
| Active In-Progress | Complete | Completion Form | Active In-Progress |
| Completion Form | Submit | Pending Approval/Success | Should not return to editable completed form |
| Worker Profile | Earnings | Earnings | Profile |
| Worker Profile | Stats | Stats | Profile |
| Worker Profile | History | Booking History | Profile |
| Messages List | Conversation | Chat Detail | Messages List |
| Notifications | Tap job notification | Relevant job screen | Notifications or prior screen |

## Module 28: Data Consistency Checklist

Use this after every major state transition.

| Data | Client Side | Worker Side | Expected Consistency |
|---|---|---|---|
| Job title | Summary/tracking/history | Request/active/history | Same |
| Category/subcategory | Summary/tracking/history | Request/active/history | Same |
| Description | Summary/details | Request/detail | Same |
| Photos | Summary/tracking | Request/completion where applicable | Same or intentionally scoped |
| Address/location | Summary/tracking | Request/active | Same address and coordinates |
| Job mode | Summary/tracking | Request/detail | Same |
| Worker identity | Applicant/tracking/history | Active job/history | Same assigned worker |
| Client identity | Client account | Request/active/history | Same client |
| Quote/price | Applicant/tracking/completion | Request/detail/completion | Same or explainable by settlement |
| Status | Bookings/tracking | Requests/active/history | Same lifecycle phase |
| Completion details | Approval/history | Pending/history/earnings | Same notes/photos/amounts |
| Rating/review | Submitted review/history | Stats/reviews/profile | Same after refresh |

## Module 29: Visual And Usability Checklist

Run this on every screen in the flow:

- No text overflow on small screens.
- Buttons have enough space and do not cover content.
- Loading indicators appear for slow actions.
- Error messages are readable and actionable.
- Empty states explain what happened.
- Forms keep typed data when navigating back and forward.
- Disabled buttons look disabled and explain missing requirements if needed.
- Maps and images do not render as blank areas without fallback.
- Repeated taps do not create duplicate actions.
- Back navigation never sends the user to a 404/not-found screen.
- Bottom navigation preserves the intended tab state.

## Module 30: Manual Test Run Template

Copy this section for each run.

```text
Run ID:
Date:
Tester:
Build/version:
Backend environment:
Client device:
Worker device:
Client account:
Worker account:
Category/subcategory:
Job ID if available:

Main scenario:

Result:
Pass/Fail:

Failed step:

Observed client state:

Observed worker state:

Expected state:

Screenshots/video captured:

Notes:
```

## Recommended Execution Order

1. Run the full happy path once with Client A and Worker A.
2. Run each screen module while the happy path is fresh in memory.
3. Run cancellation paths.
4. Run reopen/dispute path.
5. Run multi-worker race cases.
6. Run scheduled/flexible job cases.
7. Run offline/session recovery.
8. Re-run the happy path after fixing any defects to confirm no regression.

## Critical Defects To Treat As Release Blockers

- Client and worker show different assigned workers for the same job.
- A worker can accept or start two active jobs at the same time.
- A job is marked completed before client approval.
- Worker earnings update before completion approval.
- Client cannot recover from pending approval, cancellation, or matching timeout.
- Notifications route to a missing or wrong screen.
- Duplicate job creation from repeated submit.
- Duplicate payout/history entries from repeated completion or approval.
- Worker request remains actionable after another worker is accepted.
- App restart loses an active job state.

