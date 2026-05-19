# Shared screens handoff & integration plan

**Owner (shared + auth UI):** Kwabena  
**Consumers (feature homes + flows):** Client module (Nhyira), Worker module (Peniel)  
**Status:** UI-only phase — plan for decoupling now, integrate when `client/` and `worker/` screens land.

---

## 1. Goal

- **Keep** one set of shared routes/screens (`/shared/*`) that both roles use (messages, chat, profile, settings, edit profile).
- **Stop** auth and temporary shells from owning “where the user goes after login.”
- **Let** `client/` and `worker/` own post-auth navigation and bottom nav; they **embed or push** Kwabena’s shared screens.
- **Avoid** `shared/` importing `features/auth/` (today `SharedUserContext` does — that must flip).

---

## 2. What exists today (couplings to remove)

| Coupling | Location | Problem |
|----------|----------|---------|
| Post-auth navigation | `complete_profile_step2_screen.dart` | Pushes `MessagesListScreen` or `WorkerHomeShellScreen` directly — auth knows teammate homes. |
| Session in auth | `features/auth/models/onboarding_session.dart` | Shared screens read auth-owned singleton. |
| Shared → auth import | `shared/utils/shared_user_context.dart` | Wrong dependency direction (`shared` → `auth`). |
| Worker home stub | `shared/presentation/screens/worker_home_shell_screen.dart` | Belongs in `worker/` once Peniel’s shell exists. |
| All routes in `app.dart` | `lib/app.dart` | Fine short-term; long-term route table may move to `core/navigation/` (teammate-owned). |
| Stub data | `shared/data/shared_stub_data.dart` | OK for UI phase; later replaced by repositories. |

**What is already good**

- Single routes for profile/settings/edit (`/shared/profile`, `/shared/settings`, `/shared/edit-profile`).
- Role-conditional UI inside those screens (client vs worker bodies).
- `ProfileArgs` / `ChatDetailArgs` for “view someone else” vs “me”.
- `UserProfileViewData` + `UserRole` in `shared/models/` (can move to `core` later).

---

## 3. Target architecture

```
┌─────────────────────────────────────────────────────────────┐
│  lib/app.dart (or core/navigation/app_router.dart)          │
│  Registers all routes; wires auth completion → role homes     │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────────┐   ┌──────────────────┐
│ features/    │    │ features/client/ │   │ features/worker/ │
│ auth/        │    │ ClientHomeShell  │   │ WorkerHomeShell  │
│ (Kwabena)    │    │ (Nhyira)         │   │ (Peniel)         │
└──────┬───────┘    └────────┬─────────┘   └────────┬─────────┘
       │ writes              │ embeds / pushes      │ embeds / pushes
       ▼                     ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│  lib/core/                                                  │
│  • UserSession / AppUser (role, profile fields)             │
│  • SessionReader interface (read current user + role)       │
│  • Route name constants (optional)                          │
└─────────────────────────────────────────────────────────────┘
         ▲
         │ reads only (no auth imports)
┌────────┴────────────────────────────────────────────────────┐
│  lib/shared/ (Kwabena)                                      │
│  messages, chat, profile, settings, edit_profile, widgets   │
└─────────────────────────────────────────────────────────────┘
```

**Dependency rule:** `auth` → `core` ← `shared` ← `client` / `worker`.  
Never: `shared` → `auth`.

---

## 4. Contracts for teammates (use Kwabena’s shared screens)

### 4.1 Routes (stable — do not rename without team sync)

| Route constant | Path | Screen |
|----------------|------|--------|
| `MessagesListScreen.routeName` | `/shared/messages` | Conversation list (50) |
| `ChatDetailScreen.routeName` | `/shared/chat` | Chat thread (51) |
| `UserProfileScreen.routeName` | `/shared/profile` | Profile view (52) |
| `SettingsScreen.routeName` | `/shared/settings` | Settings — client (53) or worker (65) body |
| `EditProfileScreen.routeName` | `/shared/edit-profile` | Edit profile (64) |
| `JobReceiptScreen.routeName` | `/shared/job-receipt` | Worker receipt read-only (66) |

Register these in the global router (today `app.dart`; later `core/navigation/`).

### 4.2 Navigation arguments

```dart
// lib/shared/presentation/navigation/shared_route_args.dart

ProfileArgs(userId: '...', viewAsWorker: true)  // viewing another user
ProfileArgs(userId: SharedStubData.currentUserId)  // own profile

ChatDetailArgs(
  conversationId: '...',
  counterpartUserId: '...',
  counterpartName: '...',
  jobId: '...',
  jobTitle: '...',
)
```

### 4.3 Embedding in a shell (bottom nav)

Shared screens support `embedInShell: true` where needed (no back button; parent owns nav):

- `MessagesListScreen(embedInShell: true)`
- `UserProfileScreen(embedInShell: true)`
- `SettingsScreen(embedInShell: true)`

**Teammate pattern:**

```dart
// features/worker/presentation/worker_home_shell.dart (Peniel)
IndexedStack(
  index: _tabIndex,
  children: [
    const WorkerDashboardScreen(),           // worker/
    const MessagesListScreen(embedInShell: true),
    const UserProfileScreen(embedInShell: true),
    const SettingsScreen(embedInShell: true),
  ],
)
```

```dart
// features/client/presentation/client_home_shell.dart (Nhyira)
// Same idea: Explore / Bookings / Profile tab → push or embed shared profile & settings
```

Push (no embed) when opening chat or edit profile:

```dart
Navigator.pushNamed(context, ChatDetailScreen.routeName, arguments: args);
Navigator.pushNamed(context, EditProfileScreen.routeName);
```

### 4.4 Role-conditional UI (no duplicate screens)

Same route; UI branches on **current user role**:

- **Own** profile/settings/edit → use session role (client vs worker).
- **Other** user’s profile → use `UserProfileViewData.role` from args / API.

Teammates do **not** fork `settings_screen.dart` — they ensure session role is set before showing shared settings.

### 4.5 Session / current user (after Phase 1)

Shared will read from `core`, not `OnboardingSession`:

```dart
abstract class UserSessionReader {
  UserRole? get role;
  UserProfileViewData get currentUser;
  void clear(); // logout
}
```

Auth writes on sign-up / onboarding complete; client/worker only read.

---

## 5. Migration phases (Kwabena — can do incrementally)

### Phase 1 — Extract session to `core` (high priority)

| Step | Action |
|------|--------|
| 1.1 | Add `lib/core/session/app_user_session.dart` (move fields from `OnboardingSession`). |
| 1.2 | Add `lib/core/models/user_role.dart` or re-export `UserRole` from one place. |
| 1.3 | `OnboardingSession` becomes a thin wrapper **or** auth writes directly to `AppUserSession.instance`. |
| 1.4 | Change `SharedUserContext` to import `core/session` only — **remove** `features/auth` import. |

**Done when:** `dart analyze` shows zero `shared` → `auth` imports.

### Phase 2 — Decouple auth completion navigation

| Step | Action |
|------|--------|
| 2.1 | Add `lib/core/navigation/post_auth_destinations.dart` with route name constants only (no feature imports). |
| 2.2 | In `app.dart`, define `void onAuthComplete(BuildContext context, UserRole role)` that navigates to placeholder or teammate route. |
| 2.3 | Replace `complete_profile_step2_screen.dart` direct pushes with `onAuthComplete(context, session.role!)`. |

**Temporary placeholders until teammate shells exist:**

```dart
// app.dart (or injected callback)
void onAuthComplete(BuildContext context, UserRole role) {
  final String route = role == UserRole.client
      ? PostAuthRoutes.clientHome   // '/client/home' — Nhyira implements
      : PostAuthRoutes.workerHome;  // '/worker/home' — Peniel implements
  Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
}
```

Until those routes exist, keep stub routes that wrap today’s `MessagesListScreen` / `WorkerHomeShellScreen` under `client/` and `worker/` folders (one file each).

### Phase 3 — Move shells out of `shared/`

| Step | Action |
|------|--------|
| 3.1 | Move `worker_home_shell_screen.dart` → `features/worker/presentation/screens/worker_home_stub_screen.dart`. |
| 3.2 | Add `features/client/presentation/screens/client_home_stub_screen.dart` (messages + nav to profile/settings). |
| 3.3 | Delete or deprecate shell from `shared/` once teammate replaces stubs. |

### Phase 4 — Teammate integration (Nhyira / Peniel)

| Owner | Delivers |
|-------|----------|
| **Nhyira** | `ClientHomeShell`, `/client/home`, bottom nav (Explore, Bookings, Profile). Profile tab opens `UserProfileScreen` / `SettingsScreen`. Bookings flow stays in `client/`. |
| **Peniel** | `WorkerHomeShell`, `/worker/home`, bottom nav. Dashboard in `worker/`; Messages/Profile/Settings use shared embeds. Job detail may link to `JobReceiptScreen`. |
| **Both** | Register their routes in central router; never duplicate shared UI. |

### Phase 5 — Data layer (post–UI phase, aligns with `backend_integration.md`)

| Step | Action |
|------|--------|
| 5.1 | Replace `SharedStubData` with repositories fed by Supabase/API. |
| 5.2 | `SharedUserContext.buildOwnProfile()` maps from `AppUser` entity, not onboarding singleton. |
| 5.3 | Logout in `SettingsScreen` calls auth service + `session.clear()` + navigate to `SignInScreen`. |

---

## 6. What stays in Kwabena’s ownership

| Area | Keep / change |
|------|----------------|
| `lib/features/auth/**` | All auth + worker onboarding steps (06, 07). |
| `lib/shared/presentation/screens/**` | Messages, chat, profile, settings, edit profile, job receipt. |
| `lib/shared/widgets/**` | Reusable tiles, inputs used by shared screens. |
| `lib/shared/models/**` | View models for shared UI (or move DTOs to `core` if team prefers). |
| `lib/core/theme/**` | App theme (team-wide). |

**Hand off to teammates:** shells, explore, bookings, worker dashboard, job flows in `client/` and `worker/`.

---

## 7. Checklist before merging teammate branches

- [ ] No `import` from `shared/` to `features/auth/` or `features/client/` or `features/worker/`.
- [ ] Auth completes via `onAuthComplete` (or equivalent), not hard-coded shared home routes.
- [ ] `client/home` and `worker/home` registered in router.
- [ ] Shared routes still registered once (no duplicate `MaterialApp` routes).
- [ ] Role set on session before first shared screen after onboarding.
- [ ] Logout clears session and returns to `/auth/sign-in`.
- [ ] README or this doc updated if route names change.

---

## 8. Suggested stub files for teammates (minimal)

Until real screens exist, each feature adds one stub:

**`lib/features/client/presentation/screens/client_home_stub_screen.dart`**

- Bottom nav or single scaffold.
- Tab: Messages → `MessagesListScreen(embedInShell: true)`.
- Entry: `static const routeName = '/client/home';`

**`lib/features/worker/presentation/screens/worker_home_stub_screen.dart`**

- Move current `WorkerHomeShellScreen` logic here.
- Entry: `static const routeName = '/worker/home';`

Kwabena can add these stubs in a small PR so Phase 2 navigation does not break the app before teammates land.

---

## 9. File map (quick reference)

```
lib/
├── app.dart                          # Route table + onAuthComplete (target)
├── core/
│   ├── session/                      # Phase 1 — AppUserSession
│   └── navigation/                   # Phase 2+ — optional central router
├── features/
│   ├── auth/                         # Kwabena — onboarding, sign in/up
│   ├── client/                       # Nhyira — home, bookings, explore
│   └── worker/                       # Peniel — dashboard, jobs
└── shared/
    ├── presentation/screens/         # Kwabena — shared UI
    ├── utils/shared_user_context.dart  # Phase 1 — read core session only
    └── data/shared_stub_data.dart    # Replace in Phase 5
```

---

## 10. Order of work (recommended)

1. **Phase 1** — `core` session + fix `SharedUserContext` imports (small, unblocks everyone).
2. **Phase 2 + 8** — `onAuthComplete` + client/worker stub homes (app runs end-to-end).
3. **Teammates** — Replace stubs with real shells embedding shared screens.
4. **Phase 3** — Remove `worker_home_shell` from `shared/`.
5. **Phase 5** — Backend wiring when API is ready.

---

## 11. Related docs

| File | Purpose |
|------|---------|
| `Artisans_Organized_ui/shared/README.md` | Mock PNG → route mapping |
| `backend_integration.md` | Future Supabase/Express (gitignored locally) |
| `FRONTEND STRUCTURE AND RULES.pdf` | Team folder ownership |

---

*Last updated: May 2026 — UI-only integration plan for Artisans frontend.*
