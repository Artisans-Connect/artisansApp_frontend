# Shared UI Implementation Plan

This document is the execution blueprint for implementing everything described in [Artisans_Organized_ui/shared/README.md](Artisans_Organized_ui/shared/README.md): **`50_messages_list.png`**, **`51_chat_detail.png`**, **`52_user_profile.png`**, **`53_settings.png`**. It goes beyond pixel-matching by tying UI work to data models, navigation contracts, and Supabase/Express boundaries from the **Artisans Project Checklist**, architecture discipline from the **BOA Master Technical Document**, and folder ownership from **FRONTEND STRUCTURE AND RULES**.

When PNG assets are present locally, add a short appendix per screen with spacing notes and deviations from DESIGN.md.

---

## 1. Purpose and constraints

### 1.1 Product context (why these screens exist)

- **Messages list (`50`)**: Entry point to conversations tied to jobs or users; supports scanning unread state and last preview.
- **Chat detail (`51`)**: Thread UI for in-app messaging. The checklist positions chat as Phase 2, but the **`messages` table** appears in Phase 1A schema—build UI with **repository abstractions** so wiring is a swap-in later.
- **User profile (`52`)**: Unified profile surface for **client or worker** views (tabs or role-aware sections). Aligns with checklist **`profiles`** fields (name, phone, avatar, role, `fcm_token`) and worker extensions where applicable.
- **Settings (`53`)**: App preferences, privacy copy, **logout**, notification toggles (future), and links to legal text.

### 1.2 Team ownership and repo rules ([FRONTEND STRUCTURE AND RULES.pdf](FRONTEND%20STRUCTURE%20AND%20RULES.pdf))

- **`shared/` is Kwabena-owned**; teammates consume but do not edit.
- The PDF emphasizes **`shared/widgets/`** for reusable UI. The shared README labels **50–53 as screens**, so separate:
  - **`lib/shared/widgets/`** — design-system primitives and reusable molecules (list tiles, chat bubbles, section headers).
  - **`lib/shared/presentation/screens/`** — route-level screens composing those widgets.

**Decision**: Use **`lib/shared/presentation/screens/`** plus **`lib/shared/widgets/`** so all Kwabena-owned UI stays under `shared/` without inventing `features/shared` unless the team agrees.

### 1.3 Routing control

- Route constants live under **`core/navigation/`** and are edited only by the assigned teammate (per PDF). Define **stable route names + argument types** here in writing so Nhyira can register them in `app_routes.dart` / GoRouter without silent drift—or coordinate one routing PR.

### 1.4 Design system source of truth

- Tokens: [Artisans_Organized_ui/DESIGN.md](Artisans_Organized_ui/DESIGN.md) (Artisans Glossy Light — radii, spacing, Inter scale, glass surfaces).
- Extend existing Flutter theme under [lib/core/theme/](lib/core/theme/) (`app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`) instead of hardcoding hex in screens.

---

## 2. Reference synthesis from project documents

### 2.1 Artisans Project Checklist

- **Auth**: Supabase session yields JWT; Express APIs expect that JWT (integration phase). Settings **logout** must eventually clear session and navigate to auth.
- **Profile**: `profiles` extends auth user; worker data lives in a separate table in the checklist—profile UI should show worker-specific blocks when `role == worker`.
- **Messaging**: `messages` (`job_id`, `sender_id`, `content`, `is_read`)—implement list/thread UI with repositories; Realtime when Peniel enables it.
- **Phase 3 polish**: loading/empty/error states; relative timestamps in previews; avatar loading placeholders—adopt early on shared screens.

### 2.2 BOA Master Technical Document (mindset, not stack)

- **Repository pattern**: screens → providers → repository → Supabase/Dio; UI does not call SDKs directly.
- **Design tokens**: single source for spacing/colors/type.
- **Resilience**: failures surface as non-crashing UI (snackbar/banner), retries at repository layer later.

### 2.3 Frontend structure PDF

- Do not modify **`client/`** or **`worker/`**.
- Document shared widgets that are **stable public APIs** for Nhyira/Peniel to import.

---

## 3. Screen-by-screen implementation specs

### 3.1 `50_messages_list.png` — Conversation list

**UI**

- App bar: title “Messages”; optional search/filter (stub if mock omits).
- Rows: avatar, name, last preview, timestamp, unread badge (optional).
- Empty state: copy + optional illustration.
- Loading: skeleton or shimmer list.

**Conceptual model**

- `ConversationSummary`: `id`, `jobId?`, `counterpartUserId`, `counterpartName`, `counterpartAvatarUrl`, `lastMessagePreview`, `lastMessageAt`, `unreadCount`.
- If DB stores flat rows by `job_id`, repository **aggregates** latest message per thread.

**Navigation**

- Tap row → chat detail with thread/job context.

**Layout**

- `ListView.builder` or `CustomScrollView`; `SafeArea`; scrollable on small devices.

---

### 3.2 `51_chat_detail.png` — Chat thread

**UI**

- Header: back, counterpart name, optional subtitle (job title).
- Message list: bubbles by sender; optional date dividers in v2.
- Composer: text field + send; attachments stub until Phase 2.

**Future data**

- `watchMessages(jobId)` stream; Supabase Realtime on `messages` when enabled.
- Optimistic send optional later.

**Guardrails**

- RLS enforces access; repository maps errors to safe user messaging.

---

### 3.3 `52_user_profile.png` — Profile (client + worker)

**UI**

- Hero: avatar, name, role badge.
- Sections: contact (phone), bio, worker skills/verification/ratings as applicable.
- Primary action: edit profile (simple MVP: navigate or bottom sheet).

**Data**

- Map to `profiles`; extend from workers table when role is worker.

---

### 3.4 `53_settings.png` — Settings

**UI**

- Grouped sections: Notifications (stub toggles), Privacy, Terms, **Logout**.

**Logout**

- UI phase: stub. Integration: see [backend_integration.md](backend_integration.md).

---

## 4. Engineering architecture

### 4.1 Folder layout (recommended)

```
lib/shared/
  widgets/
    conversation_tile.dart
    chat_bubble.dart
    profile_section_card.dart
    settings_group_tile.dart
    ...
  presentation/
    screens/
      messages_list_screen.dart
      chat_detail_screen.dart
      user_profile_screen.dart
      settings_screen.dart
```

Optional when wiring data:

```
lib/shared/data/
  chat_repository.dart
  profile_repository.dart
```

Coordinate Supabase client ownership with Peniel/Nhyira—keep repositories thin.

### 4.2 State management

- Align with team choice (**Riverpod** in checklist). Prefer `ConsumerWidget` / `AsyncNotifier` once dependencies exist.
- Until then, `StatefulWidget` + stub futures only as a temporary bridge—avoid a second long-term state stack.

### 4.3 Navigation parameters (document for `AppRoutes`)

- Example: `ChatDetailArgs { String jobId; String counterpartUserId; }` (adjust to final schema).
- Example: `ProfileArgs { String userId; UserRole role; }`.

### 4.4 Theming

- Extend [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) for list density and dividers (`outline-variant` from DESIGN.md).
- Reuse [lib/shared/widgets/app_input.dart](lib/shared/widgets/app_input.dart), [glass_card.dart](lib/shared/widgets/glass_card.dart), [gradient_button.dart](lib/shared/widgets/gradient_button.dart) where appropriate.

---

## 5. Phased rollout

| Phase | Scope |
| ----- | ----- |
| **A — UI** | Four screens from PNGs + DESIGN.md; fake repositories; navigation args correct. |
| **B — Models** | Dart types aligned with generated Supabase types (coordinate with Peniel). |
| **C — Wire** | Repositories call Supabase; JWT for Express where needed. |
| **D — QA** | Small screens, back stack, error/empty states. |

---

## 6. Dependencies (coordinate with `pubspec.yaml` owner)

From checklist direction (confirm versions):

- `supabase_flutter`
- `go_router`
- `cached_network_image`
- `intl`
- `flutter_riverpod` (if global)

---

## 7. Risks and mitigations

| Risk | Mitigation |
| ---- | ---------- |
| Router merge conflicts | Publish route names + args early; pair on routing PRs |
| Schema vs UI | Repository hides aggregation details |
| Scope creep (voice, attachments) | Text-only composer until Phase 2 chat is agreed |
| Ownership | Keep shared screens under Kwabena `shared/` tree per team rules |

---

## 8. Definition of done

- Four screens buildable and navigable from stub routes.
- Extracted widgets: conversation tile, chat bubble, settings row/profile sections.
- Theme tokens used consistently; empty/loading/error on list and chat.
- This file lives at repo root for team reference.

---

## 9. Post-MVP (checklist “Future”)

In-app chat expansion, WhatsApp dispatch, etc., stay **out of MVP scope**—keep repository interfaces transport-agnostic so UI does not depend on future channels.

---

## Appendix A — Suggested route names (for Nhyira)

Draft only—finalize with `app_routes.dart`:

- `/shared/messages`
- `/shared/chat`
- `/shared/profile`
- `/shared/settings`

Pass structured arguments (typed class or `extra` map) for chat and profile.

---

## Appendix B — PNG inventory

Per [Artisans_Organized_ui/shared/README.md](Artisans_Organized_ui/shared/README.md):

| File | Description |
| ---- | ----------- |
| `50_messages_list.png` | Conversation list |
| `51_chat_detail.png` | Chat screen |
| `52_user_profile.png` | User profile (client or worker) |
| `53_settings.png` | Settings, privacy, logout |

Add per-mock notes below when files are committed to the repo.
