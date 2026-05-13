# Artisans – On‑Demand Artisan Platform (Ghana)

**MVP Scope:** Match clients with local artisans. No payments. Just discovery, job posting, real‑time matching, and ratings.

**Target Demo Date:** 12 working days from start.

---

## Team & Roles

| Name | Primary Responsibility | Secondary / Shared |
|------|----------------------|---------------------|
| **Kwabena** | Express.js backend, FCM, matching logic | Flutter: auth + shared screens |
| **Nhyira** | Flutter: all client screens, map integration | Supabase type integration |
| **Peniel** | Supabase schema, RLS, storage, Realtime | Flutter: all worker screens |

All three write Flutter code, but **feature owners** merge PRs for their area.

---

## Tech Stack

- **Frontend:** Flutter (stable channel), Riverpod (with code generation), GoRouter
- **Backend:** Express.js + TypeScript, Supabase (service_role)
- **Database:** Supabase (PostgreSQL) with Row Level Security
- **Realtime:** Supabase Realtime (for job status & location updates)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Maps:** Google Maps SDK (Flutter) + Directions API
- **Storage:** Supabase Storage (avatars, job photos)

---

## Repository Structure

```
artisans/
├── api/                    # Express.js backend (Kwabena)
│   ├── src/
│   │   ├── routes/
│   │   ├── services/
│   │   └── middleware/
│   ├── package.json
│   └── tsconfig.json
│
├── app/                    # Flutter frontend (all)
│   ├── lib/
│   │   ├── core/           # theme, router, api client (Nhyira)
│   │   ├── shared/         # reusable widgets (Peniel)
│   │   ├── features/
│   │   │   ├── auth/       # (Kwabena)
│   │   │   ├── client/     # (Nhyira)
│   │   │   ├── worker/     # (Peniel)
│   │   │   └── shared_features/ (chat, profile settings)
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── assets/
│
├── supabase/               # Migrations & types (Peniel)
│   ├── migrations/
│   └── types.ts
│
├── docs/                   # Design assets, checklists
│   └── ui/                 # Organized screens by role
│
├── .github/                # PR templates, CI workflows
├── README.md               # This file
└── CONTRIBUTING.md         # Detailed branch & commit rules
```

---

## Setup Instructions

### 1. Clone the repository
```bash
git clone https://github.com/your-org/artisans.git
cd artisans
```

### 2. Backend (Express)
```bash
cd api
cp .env.example .env          # Fill in Supabase URL, service key, FCM credentials
npm install
npm run dev                   # Starts on http://localhost:3000
```

### 3. Flutter (Frontend)
```bash
cd app
flutter pub get
# Add google-services.json (Android) and GoogleService-Info.plist (iOS) to respective folders
# Add Google Maps API key to AndroidManifest.xml and AppDelegate.swift/Info.plist
flutter run
```

### 4. Supabase
- Create a project at [supabase.com](https://supabase.com)
- Run migrations from `supabase/migrations/`
- Enable Realtime on `jobs`, `workers`, `messages` tables
- Set up storage buckets: `avatars`, `job-photos`

---

## Branch Strategy & Commit Rules

We use **GitFlow‑light**:

- `main` – production‑ready code (only via PR from `dev`)
- `dev` – integration branch (all feature branches merge here)
- `feature/*` – individual work (e.g., `feature/client-home`, `feature/matching-engine`)

**Process:**
1. Create branch from `dev`: `git checkout -b feature/your-name`
2. Commit often with clear messages (see below)
3. Push and open a Pull Request to `dev`
4. Request review from **feature owner** (see team roles)
5. After approval, merge (squash commits recommended)

**Commit message format:**
```
[area] Short description

Example:
[auth] Add phone OTP verification screen
[backend] Implement Haversine distance in matching service
[worker] Build job request detail with accept/decline buttons
```

**Never commit directly to `dev` or `main`.** Always use PRs.

---

## Daily Rituals (Mandatory)

- **10:00 AM – Daily Standup** (15 min, voice call)
  - What did you complete yesterday?
  - What will you work on today?
  - Any blockers?

- **6:00 PM – PR Merge Window**
  - All feature branches must have an open PR or be merged.
  - One approval required (from someone other than the author).

- **Friday 4:00 PM – Weekly Review** (30 min)
  - Demo progress, adjust next week's plan.

---

## Environment Variables

### Backend (`.env`)
```
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-admin-sdk.json
```

### Flutter (secrets not committed)
- `google_maps_api_key` – added to native platform files manually.
- Supabase URL & anon key – stored in `lib/core/constants.dart` (never commit real keys if repo is public; use a secure config).

---

## UI Assets

Organized screens are in `docs/ui/` with subfolders:
- `auth/` – splash, role selection, login, signup, profile completion
- `client/` – all client‑facing screens
- `worker/` – all worker‑facing screens
- `shared/` – chat, profile, settings

**Design tokens** are documented in `DESIGN.md` (colors, typography, spacing).

**Missing assets (to be delivered by PM before coding starts):**
- Icon SVGs (bottom nav, category chips, action icons)
- Empty state illustrations (4 vectors)
- Splash screen logo
- Avatar placeholder image

Until then, use Material/Ionicons placeholders.

---

## Testing Requirements (Minimum)

- Full auth flow on Android emulator + real device (Tecno/Infinix class)
- Job post → matching → worker accept → client tracking → worker complete → client rating
- Double‑accept test (only one worker succeeds)
- Offline banner appears within 2 seconds of network loss
- No crashes on low‑memory devices

---

## Useful Commands

```bash
# Flutter
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test

# Express
npm run lint
npm test

# Supabase (CLI)
supabase db push
supabase gen types typescript --linked > ../supabase/types.ts
```

---

## Contact / Escalation

- **Blocked on design assets?** → Ping PM (you)
- **Blocked on backend API?** → Tag @Kwabena in GitHub issue
- **Blocked on database/R?** L → Tag @Peniel
- **Blocked on client UI?** → Tag @Nhyira
- **General project questions** → Open a discussion in GitHub

---

## Final Notes

- No payments in MVP – we match only.
- Budget UI is **removed** – urgency only (ASAP/Scheduled).
- Focus on **reliability** over fancy animations.
- When in doubt, simplify.

**Let's build.**
