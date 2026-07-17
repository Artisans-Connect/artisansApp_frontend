# Manual Job Lifecycle Run Sheet

Use this run sheet beside `MANUAL_JOB_LIFECYCLE_TEST_PLAN.md`. The test plan explains what to inspect; this sheet gives you a practical order for one manual run.

## Run Details

| Field | Value |
|---|---|
| Run ID |  |
| Date |  |
| Tester |  |
| Build/version |  |
| Backend environment |  |
| Client device |  |
| Worker A device |  |
| Worker B device |  |
| Client account |  |
| Worker A account |  |
| Worker B account |  |
| Job ID |  |
| Category/subcategory |  |

## Result Codes

| Code | Meaning |
|---|---|
| Pass | Works as expected |
| Fail | Defect found |
| Blocked | Cannot continue because setup/system is not ready |
| N/A | Not applicable for this run |

## A. Setup Checks

| ID | Check | Expected | Result | Notes |
|---|---|---|---|---|
| SET-01 | Client A signs in | Client home opens |  |  |
| SET-02 | Worker A signs in | Worker shell opens |  |  |
| SET-03 | Worker B signs in | Worker shell opens |  |  |
| SET-04 | Worker A availability is on | Worker can receive requests |  |  |
| SET-05 | Worker B availability is on | Worker can receive requests |  |  |
| SET-06 | Worker A location is fresh | Distance/quote can calculate |  |  |
| SET-07 | Worker B location is fresh | Distance/quote can calculate |  |  |
| SET-08 | Worker A has matching skill | Eligible for selected job category |  |  |
| SET-09 | Worker B has matching skill | Eligible for selected job category |  |  |
| SET-10 | Client has no active job | Clean run can start |  |  |
| SET-11 | Worker A has no active job | Worker can apply/be assigned |  |  |
| SET-12 | Worker B has no active job | Worker can apply/be assigned |  |  |

## B. Client Job Posting

| ID | Screen | Action | Expected Client Result | Expected Worker Result | Result | Notes |
|---|---|---|---|---|---|---|
| CJP-01 | Client Home | Open job post flow | Category screen opens | No worker change |  |  |
| CJP-02 | Category | Select service category | Selection is visible; can continue | No worker change |  |  |
| CJP-03 | Subcategory | Select subcategory | Selection is visible; can continue | No worker change |  |  |
| CJP-04 | Details | Enter title | Title persists after back/forward | No worker change |  |  |
| CJP-05 | Details | Enter description | Description persists after back/forward | No worker change |  |  |
| CJP-06 | Details | Add photos | Photos preview and can be removed | No worker change |  |  |
| CJP-07 | Location/Schedule | Select location | Address/map value shown | No worker change |  |  |
| CJP-08 | Location/Schedule | Select ASAP | Urgency shown as ASAP | No worker change |  |  |
| CJP-09 | Summary | Review all fields | Summary matches draft | No worker change |  |  |
| CJP-10 | Summary | Tap post once | Matching/applicants flow opens | Eligible worker request appears |  |  |
| CJP-11 | Summary | Try rapid duplicate post in separate run | Only one job created | Only one request per worker |  |  |

## C. Worker Request And Application

| ID | Screen | Action | Expected Client Result | Expected Worker Result | Result | Notes |
|---|---|---|---|---|---|---|
| WRA-01 | Worker Requests | Worker A receives request | Client remains in matching/applicants wait state | Request visible or sheet opens |  |  |
| WRA-02 | Worker Request Detail | Worker A opens request | No client assignment yet | Job details match client post |  |  |
| WRA-03 | Worker Request Detail | Check quote | Applicant not yet visible unless already applied | Quote shows total, distance, base fee, urgency premium |  |  |
| WRA-04 | Worker Request Detail | Worker A applies/accepts request | Worker A appears in applicants | Application submitted once |  |  |
| WRA-05 | Worker Requests | Worker B receives/applies | Worker B appears as second applicant | Application submitted once |  |  |
| WRA-06 | Worker Request Detail | Worker C unavailable/stale tries to apply | No bad applicant created | Clear blocked/error state |  |  |

## D. Client Applicant Selection

| ID | Screen | Action | Expected Client Result | Expected Worker Result | Result | Notes |
|---|---|---|---|---|---|---|
| CAS-01 | Job Applicants | View Worker A applicant | Worker data, quote, rating visible | Worker A remains pending |  |  |
| CAS-02 | Job Applicants | View Worker B applicant | Worker data, quote, rating visible | Worker B remains pending |  |  |
| CAS-03 | Job Applicants | Accept Worker A | Live tracking opens or job becomes matched | Worker A active job appears |  |  |
| CAS-04 | Worker B stale request | Worker B tries to act after Worker A accepted | Client job remains assigned to Worker A | Worker B sees unavailable/taken or cannot proceed |  |  |
| CAS-05 | Client Bookings | Open active job | Live tracking opens | Worker A still sees active job |  |  |

## E. Active Job Status Sync

| ID | Worker Action | Expected Client State | Expected Worker State | Result | Notes |
|---|---|---|---|---|---|
| AJS-01 | Worker A opens Bookings | Client tracking shows matched worker | Active pre-start screen appears |  |  |
| AJS-02 | Worker marks on the way | Timeline/status shows on the way | Worker phase shows on the way |  |  |
| AJS-03 | Worker marks arrived | Timeline/status shows arrived | Worker phase shows arrived/start option |  |  |
| AJS-04 | Worker starts job | Timeline/status shows in progress | In-progress timer screen appears |  |  |
| AJS-05 | Client opens bookings during work | Active job has in-progress state | Worker timer remains active |  |  |
| AJS-06 | Worker navigates away/back | Client state unchanged | Timer/job state remains correct |  |  |
| AJS-07 | Client sends chat message | Message visible in client chat | Message appears in worker chat |  |  |
| AJS-08 | Worker sends chat message | Message appears in client chat | Message visible in worker chat |  |  |

## F. Completion And Approval

| ID | Screen | Action | Expected Client Result | Expected Worker Result | Result | Notes |
|---|---|---|---|---|---|---|
| CMP-01 | Worker Completion Form | Open form | Client remains in-progress | Form opens from in-progress job |  |  |
| CMP-02 | Worker Completion Form | Enter materials/notes | Client remains in-progress | Values remain visible before submit |  |  |
| CMP-03 | Worker Completion Form | Add completion photos | Client remains in-progress | Photos preview correctly |  |  |
| CMP-04 | Worker Completion Form | Submit completion | Client sees pending approval controls | Worker sees pending approval |  |  |
| CMP-05 | Worker Pending Approval | Check availability/blocking | Client still pending approval | Worker cannot take another active job |  |  |
| CMP-06 | Client Approval | Review completion details | Completion details match worker submission | Worker still pending approval |  |  |
| CMP-07 | Client Approval | Approve completion | Job becomes completed; rating flow available | Active job clears or success appears |  |  |
| CMP-08 | Worker Bookings | Open Bookings after approval | Client completed/rating state remains | Empty active state appears |  |  |

## G. Rating, History, Earnings, Stats

| ID | Screen | Action | Expected Client Result | Expected Worker Result | Result | Notes |
|---|---|---|---|---|---|---|
| RHS-01 | Rate Service | Select star rating | Rating is selected clearly | No worker change yet |  |  |
| RHS-02 | Rate Service | Enter review | Review text accepted | No worker change yet |  |  |
| RHS-03 | Rate Service | Submit review | Client returns to completed/history flow | Worker review/stat can update after refresh |  |  |
| RHS-04 | Client Booking History | Open completed job | Completed job appears with correct worker/status | No worker change |  |  |
| RHS-05 | Worker Booking History | Open history | No client change | Completed job appears |  |  |
| RHS-06 | Worker Earnings | Open earnings | No client change | Payout appears only after approval |  |  |
| RHS-07 | Worker Stats | Open stats/reviews | No client change | Total jobs/review count/rating update |  |  |
| RHS-08 | Worker Profile | Open public/profile review area | Client review visible if product shows it | Review displayed correctly |  |  |

## H. Cancellation Runs

Run these as separate jobs.

| ID | Scenario | Action | Expected Client Result | Expected Worker Result | Result | Notes |
|---|---|---|---|---|---|---|
| CAN-01 | Before match | Client cancels while matching | Job cancelled or removed from active list | Requests disappear/become unavailable |  |  |
| CAN-02 | After match | Client cancels after accepting worker | Cancel preview then cancelled state | Active job clears; history shows cancelled |  |  |
| CAN-03 | On the way | Client cancels after worker marks on-way | Travel-compensation warning if configured | Worker notified; active clears |  |  |
| CAN-04 | In progress termination accepted | Client requests termination, worker accepts | Job cancelled | Worker active clears |  |  |
| CAN-05 | In progress termination declined | Client requests termination, worker declines | Job returns to in-progress | Worker returns to in-progress |  |  |
| CAN-06 | Worker cancellation | Worker cancels assigned job | Client sees worker cancelled/request another worker option | Worker active clears and availability returns |  |  |
| CAN-07 | Request another worker | Client requests another worker after worker cancellation | Job returns to matching | New eligible worker can apply |  |  |

## I. Reopen/Dispute Run

| ID | Action | Expected Client Result | Expected Worker Result | Result | Notes |
|---|---|---|---|---|---|
| ROP-01 | Worker submits completion | Pending approval shown | Pending approval shown |  |  |
| ROP-02 | Client reopens/disputes completion | Job returns to in-progress | Worker active in-progress returns |  |  |
| ROP-03 | Worker resubmits completion | Pending approval shown again | Pending approval shown again |  |  |
| ROP-04 | Client approves resubmission | Completed/rating available | Worker active clears/history updates |  |  |

## J. Recovery Runs

| ID | Scenario | Expected Result | Result | Notes |
|---|---|---|---|---|
| REC-01 | Restart client app while matching | Job restores in matching/applicants/bookings |  |  |
| REC-02 | Restart worker app after matched | Active job restores in Bookings |  |  |
| REC-03 | Restart worker app in-progress | In-progress job and timer restore |  |  |
| REC-04 | Restart client app during pending approval | Approval controls restore |  |  |
| REC-05 | Lose network during job post | Clear error; retry does not duplicate job |  |  |
| REC-06 | Lose network during worker apply | Clear error; retry does not duplicate application |  |  |
| REC-07 | Lose network during completion submit | Clear error or successful recovery; no duplicate completion |  |  |
| REC-08 | Lose network during client approval | No duplicate completed job/earnings entry |  |  |

## K. Defect Log

| Defect ID | Test ID | Severity | Summary | Client State | Worker State | Evidence | Status |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |

## L. Final Sign-Off

| Area | Result | Notes |
|---|---|---|
| Client posting flow |  |  |
| Worker request flow |  |  |
| Applicant selection |  |  |
| Live status sync |  |  |
| Chat/messages |  |  |
| Completion approval |  |  |
| Rating/reviews |  |  |
| History/earnings/stats |  |  |
| Cancellation paths |  |  |
| Recovery paths |  |  |

Overall result:

Final notes:

