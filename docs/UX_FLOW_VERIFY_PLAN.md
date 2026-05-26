## UX flow & UI fidelity verification plan

> Source: `.cursor/plans/ux-flow-verify_85db40a9.plan.md` (synced copy for docs)

---

## 1. Plan objectives

1. **UX-flow correctness:** confirm users move through screens smoothly for both roles, including:
   - back navigation behavior
   - scrollability
   - progress/step indicators
   - bottom navigation visibility when expected (shell vs push routes)
   - correct role-conditional sections (client vs worker)

2. **UI fidelity vs spec:** compare the rendered UI with the provided PNGs in `Artisans_Organized_ui`.
   - Use **Hybrid** comparison (semantic for all, pixel-tight for critical screens).

3. **Gap identification:** highlight where the current app UI is better/worse than the specified PNGs, and produce actionable next fixes.

---

## 2. In-scope user journeys (high priority)

### Client journey (role = client)
1. `lib/features/auth/presentation/screens/sign_up_screen.dart` → `RoleSelectionScreen` → `CompleteProfileStep1Screen` (role badge read-only) → `CompleteProfileStep2Screen`.
2. Verify transition from `CompleteProfileStep2Screen` into `ClientShell` (`lib/features/client/presentation/client_shell.dart`).
3. In `ClientShell` tabs:
   - Messages tab (`lib/shared/presentation/screens/messages_list_screen.dart`, embedded)
   - Tap a conversation → `ChatDetailScreen` (`lib/shared/presentation/screens/chat_detail_screen.dart`)
   - Tap counterpart avatar/name → `UserProfileScreen` (`/shared/profile`)
   - Open Settings from profile/messages (check shared role-conditional settings).
4. Open `EditProfileScreen` (`lib/shared/presentation/screens/edit_profile_screen.dart`) and verify client-only fields.

### Worker journey (role = worker)
1. `SignUpScreen` → `RoleSelectionScreen` → `WorkerTradeSelectionScreen` (mock 06) → `WorkerServiceAreasScreen` (mock 07) → `CompleteProfileStep1Screen` (photo/location) → `CompleteProfileStep2Screen` (bio only).
2. Verify transition into `WorkerShell` (`lib/features/worker/presentation/worker_shell.dart`).
3. In `WorkerShell` tabs:
   - Profile tab (`UserProfileScreen` embedded)
   - Settings tab (`SettingsScreen` embedded)
   - From dashboard job card, open `JobReceiptScreen` (`/shared/job-receipt`).
4. Open `EditProfileScreen` from profile and verify worker-only fields.

### Cross-role viewing inside chat
- From `MessagesListScreen` → `ChatDetailScreen` → tap the profile header.
- Confirm the opened `UserProfileScreen` uses the **counterpart’s role**, not always the current user role.

---

## 3. Navigation map (for manual verification)

```mermaid
flowchart TD
  Start[Start: Sign up] --> RoleSelect[RoleSelectionScreen]

  RoleSelect -->|client| ClientOnboarding[CompleteProfileStep1 -> CompleteProfileStep2]
  RoleSelect -->|worker| WorkerOnboarding[WorkerTradeSelection(06) -> WorkerServiceAreas(07) -> CompleteProfileStep1 -> CompleteProfileStep2]

  ClientOnboarding --> ClientShell[ClientShell]
  WorkerOnboarding --> WorkerShell[WorkerShell]

  ClientShell --> MessagesEmbed[MessagesListScreen(embedInShell: true)]
  WorkerShell --> MessagesEmbedW[MessagesListScreen(embedInShell: true)]

  MessagesEmbed --> ChatDetail[ChatDetailScreen(/shared/chat)]
  ChatDetail --> Profile[UserProfileScreen(/shared/profile)]
  Profile --> Settings[SettingsScreen(/shared/settings)]
  Profile --> EditProfile[EditProfileScreen(/shared/edit-profile)]
  WorkerShell --> JobReceipt[JobReceiptScreen(/shared/job-receipt)]
```

---

## 4. Reference PNG mapping (spec to compare)

### Worker onboarding
- `Artisans_Organized_ui/auth/06_worker_onboarding_1.png`
- `Artisans_Organized_ui/auth/07_worker_onboarding_2.png`
- `Artisans_Organized_ui/auth/08_worker_onboarding_3.png`

**Implementation note for verification:**
- Our current flow splits the “final step” into:
  - `CompleteProfileStep1Screen` (photo/location)
  - `CompleteProfileStep2Screen` (bio only)
- The comparison should treat those two screens as the combined counterpart of mock 08.

### Shared (role-conditional) screens
- `Artisans_Organized_ui/shared/50_messages_list.png`  ↔ `lib/shared/presentation/screens/messages_list_screen.dart`
- `Artisans_Organized_ui/shared/51_chat_detail.png`     ↔ `lib/shared/presentation/screens/chat_detail_screen.dart`
- `Artisans_Organized_ui/shared/52_user_profile.png`    ↔ `lib/shared/presentation/screens/user_profile_screen.dart`
- `Artisans_Organized_ui/shared/53_settings.png`         ↔ `lib/shared/presentation/screens/settings_screen.dart` (client body)
- `Artisans_Organized_ui/shared/64_worker_edit_profile.png` ↔ `lib/shared/presentation/screens/edit_profile_screen.dart` (worker body)
- `Artisans_Organized_ui/shared/65_worker_settings.png`  ↔ `lib/shared/presentation/screens/settings_screen.dart` (worker body)
- `Artisans_Organized_ui/shared/66_worker_job_detail_readonly.png` ↔ `lib/shared/presentation/screens/job_receipt_screen.dart`

### Worker home dashboard (for job receipt shell expectations)
- `Artisans_Organized_ui/worker/41_worker_job_detail.png` and/or `66_worker_job_detail_readonly.png` (depending on how teammates render)

---

## 5. Verification checklist (what to measure)

### A. UX Flow & State
For each transition in the journeys above, verify:
- Back button returns to the correct prior screen/tab.
- No dead-end navigation (can always exit to home/shell).
- Scroll behavior is correct on smaller screens (screens use `SingleChildScrollView` where needed).
- Loading / empty states behave reasonably (e.g., messages skeleton vs empty).

### B. Role-conditional logic
Verify client vs worker divergences match the spec expectations:
- Shared profile sections visibility changes appropriately.
- Shared settings body changes appropriately.
- Edit profile fields change appropriately.
- Job receipt is worker-only and is reachable only in worker flows.

### C. Shell vs push route composition
Pay special attention to what the PNG shows at the bottom:
- If PNG shows bottom navigation, confirm it remains visible in the running app.
- If PNG shows full-screen page without bottom nav, confirm we match.

---

## 6. Hybrid UI comparison methodology

### Semantic comparison (always)
For each spec screen vs our implementation, record:
- What widgets/sections exist (and which are missing)
- Which text labels differ
- Which role-specific sections are wrong or swapped
- Which actions differ (e.g., Save button location)

### Pixel-tight comparison (only critical screens)
For these screens only, compare spacing/colors/typography and layout structure:
- `06_worker_onboarding_1.png`
- `07_worker_onboarding_2.png`
- `08_worker_onboarding_3.png` (vs combined `CompleteProfileStep1Screen` + `CompleteProfileStep2Screen`)
- `50_messages_list.png` (particularly: search bar, conversation tiles, top actions, bottom nav)
- `51_chat_detail.png` (header + composer region)
- `53_settings.png` and `65_worker_settings.png`
- `64_worker_edit_profile.png`
- `66_worker_job_detail_readonly.png` (including bottom nav presence)

**Scoring rubric (0-2):**
- 2 = matches structure/layout and major styling
- 1 = close but missing some elements or spacing differs
- 0 = meaning differs (wrong sections, wrong role content, broken composition)

---

## 7. How to capture “current app UI” screenshots for comparison

For each journey step, capture screenshots with consistent device settings:
- Use one device size for all comparisons (recommended: Pixel 6 / 1080x2400 equivalent).
- Keep text scale factor at default (1.0).
- Capture both:
  - full-screen variants
  - embedded variants inside shells (Messages/Profile/Settings)

**Screenshot naming convention:**
- `journey_<client|worker>__step_<n>__screen_<route_or_widget>.png`

---

## 8. Outputs / deliverables

1. `UX_FLOW_AUDIT.md`
   - A table of journeys with pass/fail notes for UX-flow items.
   - A list of semantic mismatches.

2. `UI_DIFF_SUMMARY.md`
   - Hybrid score per critical screen.
   - Top 5 “worst mismatches” with severity and suggested remediation.

3. A short “handoff-friendly” mapping doc:
   - which mismatches are likely due to teammate shell composition (bottom nav presence), vs which are purely shared-screen styling.

---

## 9. Files to inspect during review (for quick reference)

Auth + onboarding:
- `[lib/features/auth/presentation/screens/role_selection_screen.dart](lib/features/auth/presentation/screens/role_selection_screen.dart)`
- `[lib/features/auth/presentation/screens/worker_trade_selection_screen.dart](lib/features/auth/presentation/screens/worker_trade_selection_screen.dart)`
- `[lib/features/auth/presentation/screens/worker_service_areas_screen.dart](lib/features/auth/presentation/screens/worker_service_areas_screen.dart)`
- `[lib/features/auth/presentation/screens/complete_profile_step1_screen.dart](lib/features/auth/presentation/screens/complete_profile_step1_screen.dart)`
- `[lib/features/auth/presentation/screens/complete_profile_step2_screen.dart](lib/features/auth/presentation/screens/complete_profile_step2_screen.dart)`

Client/worker shells:
- `[lib/features/client/presentation/client_shell.dart](lib/features/client/presentation/client_shell.dart)`
- `[lib/features/worker/presentation/worker_shell.dart](lib/features/worker/presentation/worker_shell.dart)`

Shared screens:
- `[lib/shared/presentation/screens/messages_list_screen.dart](lib/shared/presentation/screens/messages_list_screen.dart)`
- `[lib/shared/presentation/screens/chat_detail_screen.dart](lib/shared/presentation/screens/chat_detail_screen.dart)`
- `[lib/shared/presentation/screens/user_profile_screen.dart](lib/shared/presentation/screens/user_profile_screen.dart)`
- `[lib/shared/presentation/screens/settings_screen.dart](lib/shared/presentation/screens/settings_screen.dart)`
- `[lib/shared/presentation/screens/edit_profile_screen.dart](lib/shared/presentation/screens/edit_profile_screen.dart)`
- `[lib/shared/presentation/screens/job_receipt_screen.dart](lib/shared/presentation/screens/job_receipt_screen.dart)`

---

## 10. Notes / likely mismatch areas to pay attention to

During verification, expect to validate these risk areas:
- Messages/settings/profile icons/actions inside embedded mode (`embedInShell: true`) vs PNG expectations.
- Worker job receipt bottom navigation presence (shell tab vs pushed route).
- Worker onboarding “step 3” split across two screens vs PNG mock 08 combined UI.
- Role correctness when navigating from chat header to profile (`ProfileArgs.viewAsWorker`).
- Chat detail screen image attachment rendering (horizontal grid inside chat bubble) and the functional attachment menu toggle behavior.

