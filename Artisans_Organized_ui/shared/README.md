# SHARED Screens

Same routes for clients and workers; UI branches on role via `SharedUserContext` / `OnboardingSession`.

| Filename | Description | Flutter route |
|----------|-------------|---------------|
| 50_messages_list.png | Conversation list | `/shared/messages` |
| 51_chat_detail.png | Chat screen | `/shared/chat` |
| 52_user_profile.png | User profile (own or other user) | `/shared/profile` |
| 53_settings.png | **Client** settings & info | `/shared/settings` (client body) |
| 64_worker_edit_profile.png | **Edit profile** (worker-heavy; client slimmer) | `/shared/edit-profile` |
| 65_worker_settings.png | **Worker** account preferences | `/shared/settings` (worker body) |
| 66_worker_job_detail_readonly.png | Job receipt (worker, read-only) | `/shared/job-receipt` |

## Role-conditional behaviour

| Screen | Client | Worker |
|--------|--------|--------|
| Profile | Location, about, jobs posted | + skills, service areas, experience, rating/stats |
| Settings | Hero, legal, community, premium | Account prefs, low data, legal, logout |
| Edit profile | Name, phone (locked), location, bio | + skills chips, hourly rate, service areas |

Post-auth: **client** → Messages; **worker** → `WorkerHomeShell` (dashboard, messages, profile, settings tabs).
