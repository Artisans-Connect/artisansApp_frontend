# artisansApp_frontend — Structure & Naming Audit

_Generated 2026-08-20. Scope: `lib/` (257 Dart files, ~50.7k lines)._

## Revert anchor (Phase 1 cleanup)

Before Phase 1 deletions, `artisansApp_frontend` was at:

- **branch:** `main`
- **commit:** `472785a2a4e294823f1b536e0ea18dc6b7918efd` (`472785a`)
- **subject:** _chore(frontend): delete redundant documentation files and update layout spec_ (2026-08-16)

The working tree also had unrelated uncommitted changes at the time, so **prefer a surgical restore over a hard reset** (a hard reset would discard that other work). To bring back only the files deleted in Phase 1:

```bash
git restore --source=472785a -- \
  lib/features/auth/widgets/auth_header.dart \
  lib/features/auth/widgets/profile_step_indicator.dart \
  lib/features/auth/widgets/worker_onboarding_header.dart \
  lib/features/worker/presentation/widgets/worker_scroll_scaffold.dart \
  lib/features/worker/presentation/widgets/request_job_card.dart \
  lib/shared/presentation/screens/worker_home_shell_screen.dart \
  lib/shared/widgets/google_logo_mark.dart \
  lib/shared/widgets/rating_widget.dart \
  lib/features/shared/widgets/search_bar.dart
```

## Phase 1 — executed 2026-08-21

**Removed (9 items · −639 lines · 257 → 248 files):** `auth_header.dart`, `profile_step_indicator.dart`, `worker_onboarding_header.dart`, `worker_scroll_scaffold.dart`, `request_job_card.dart`, `worker_home_shell_screen.dart`, `google_logo_mark.dart`, `rating_widget.dart`, and the empty `lib/features/shared/` tree.

**Verification (no Dart SDK in env, so checked by static reference sweep):** zero import/path references to any deleted file across `lib/` + `test/`; zero references to the unique classes `AuthHeader`, `WorkerOnboardingHeader`, `ProfileStepIndicator`, `WorkerScrollScaffold`, `WorkerHomeShellScreen`, `GoogleLogoMark`, `RatingWidget`. `git status` shows a clean set of 9 deletions. Reachable code graph unchanged → no behavior change.

**Deliberately kept (need a decision, NOT deleted):**
- `lib/core/cache/cache_debug.dart`, `lib/core/cache/request_deduplicator.dart` — infra built ahead of use; kept pending confirmation they aren't wanted.

**Phase 1 addendum — resolved 2026-08-21:** `lib/features/worker/presentation/widgets/availability_card.dart` (the 52-line 2-arg orphan) is now **deleted**. `test/widget_test.dart` was the only referrer; it was migrated to the live 5-arg `worker_dashboard/availability_card.dart` (added `lastCheckedAt`/`isSilentRefreshing`/`isAvailabilityLoading`, and updated assertions to `find.byType(Switch)` + `find.text('Offline')`). Verified: `AvailabilityCard` now declared in exactly one file; zero references to the old path across `lib/`+`test/`. This deletion is **not** in the revert-anchor `git restore` block above — to bring it back, also add `lib/features/worker/presentation/widgets/availability_card.dart` and revert `test/widget_test.dart`.

### Why these were unused (replaced-by map)

Root cause: two refactors left predecessors on disk — the **2026-06-07 "Refactor auth features"** and **2026-08-07 "modularize … worker dashboard"** commits. What took over each job:

| Removed file | Superseded by |
|---|---|
| `request_job_card.dart` | `worker_request_card.dart` (same `RequestJobCard`, 188→532 L) |
| `auth_header.dart`, `worker_onboarding_header.dart` | headers folded into `onboarding_page_content.dart` / inlined in screens |
| `profile_step_indicator.dart` | `DotIndicator` (`dot_indicator.dart`) + `StepDots` (`onboarding_atoms.dart`) |
| `rating_widget.dart` | `StarRow`, `RatingBarRow`, `StarRating` (modularized rating pieces) |
| `google_logo_mark.dart` | `SvgPicture.asset('assets/google_logo.svg')` in the sign-in button |
| `worker_home_shell_screen.dart` | `worker_shell.dart` (moved into the worker feature, mirrors `client_shell.dart`) |
| `worker_scroll_scaffold.dart` | abstraction dropped — screens use plain `Scaffold` + scroll views |
| `features/shared/widgets/search_bar.dart` | empty stub; real one is `shared/widgets/search_bar.dart` (`CustomSearchBar`) |

## Phase 2 — executed 2026-08-21 (7 renames)

Renamed the 7 clear filename↔content mismatches from §3. Each was done with `git mv` (history preserved) and every importer's import path updated; verified by a repo-wide sweep showing **0 residual references** to any old name and a full import-graph check (**1103 project imports across `lib/`+`test/`, 0 dangling**).

| Old name | New name | Why | Importers updated |
|---|---|---|---|
| `worker_request_card.dart` | `worker_request_cards.dart` | holds 3 cards (`RequestJobCard`, `NearbyJobRequestFoundCard`, `JobTag`) — plural | 2 |
| `artisan_detail_sheet.dart` | `selected_worker_preview.dart` | primary widget is `SelectedWorkerPreview` | 2* |
| `map_search_bar.dart` | `map_overlay_controls.dart` | it's `MapOverlayControls`, not a search bar | 2* |
| `report_model.dart` | `safety_report.dart` | declares `SafetyReport` | 3 |
| `worker_application_navigation.dart` | `worker_application_destination.dart` | declares the `WorkerApplicationDestination` enum | 2 (incl. 1 test) |
| `worker_earnings_summary.dart` | `performance_overview_card.dart` | declares `PerformanceOverviewCard` | 1 |
| `mapbox_client_map.dart` | `mapbox_maps.dart` | 3 mapbox maps, not client-specific | 2 |

\* Initial importer discovery missed **same-directory** imports (`import 'file.dart';`, no `/`); the residual-reference sweep caught them (`map_overlay_controls.dart`→`selected_worker_preview.dart` "For TradeTypeX", and `job_location_map.dart`→`mapbox_maps.dart`). Both fixed.

**Deferred (not done here, need a decision):** `selected_worker_preview.dart` still also declares `TrustBadge` and the `TradeType` enum/`TradeTypeX` extension (used cross-file by `map_overlay_controls.dart`). Splitting those out (TrustBadge→shared, TradeType→a model) is left to the structural phase.

**To revert Phase 2:** the renames are ordinary git renames — `git restore --staged` + `git checkout` the 7 old paths, or reverse each `git mv`, and revert the ~10 importer edits.

**Incidental finding (NOT a bug, NOT touched):** `role_selection_screen.dart` (13 imports) and `live_tracking/extra_charge_card.dart` (2 imports) each use one **extra** `../` in their `core/`+`shared/` import paths. These compile fine because Dart resolves relative imports as `package:` URIs and clamps excess `../` at the package root — but they're non-canonical. Fold into the Phase 4 import-style standardization.

## Phase 3 — executed 2026-08-21 (GradientButton split-brain resolved)

**Decision: differentiate** (rename the worker variant) rather than unify — chosen because the two implementations are genuinely diverged *and* cleanly segregated by feature (no file imported both), so there was no active collision, and unifying would visually change ~12 auth/wallet/payment screens. Unification into a single design-system button is left as a deliberate future task.

What the two actually were:

| | Shared (`shared/widgets/gradient_button.dart`, kept) | Worker (renamed) |
|---|---|---|
| Callers | 12 (auth ×6, payment, wallet, 2 shared screens, 2 shared widgets) | 8 (worker screens ×7, `worker_job_alert_sheet`) |
| Shape / disabled | pill r26, dims to 0.6 opacity | rounded r12, solid gray fill |
| Text / interaction | hardcoded white w700, plain button | theme `bodyLarge` w600, InkWell ripple + haptics |
| Extras | `trailingIcon` (used ×2) | `enabled` flag + companion `OutlineButton` (used ×3) |

**Action:** `git mv features/worker/presentation/widgets/gradient_button.dart → worker_gradient_button.dart`; renamed class `GradientButton → WorkerGradientButton` (its companion `OutlineButton` kept in the same file, name unchanged — no collision); updated all 8 worker importers (import path + usages). The shared `GradientButton` and its 12 callers were left untouched.

**Verification:** `WorkerGradientButton` now defined once + used in 8 files (9 total); every remaining `GradientButton` reference is shared-family only (13 files, no `worker/` paths); `OutlineButton` still resolves; full import-graph check = **1103 imports, 0 dangling**. No test references either button. Zero visual change. (Unrelated: `worker_active_booking_test.dart` shows a pre-existing CRLF-only diff.)

**To revert Phase 3:** reverse the `git mv` and the `GradientButton`↔`WorkerGradientButton` rename across the 9 worker files.

## Phase 4 (part 1) — executed 2026-08-21 (import-style standardization)

Converted **every** relative in-project import/export under `lib/` to absolute `package:artisans_app/...` form — the §6.5 recommendation and the highest-leverage structural fix (makes future file moves/renames a one-line change and adds the basis for an `always_use_package_imports` lint).

**Scope:** 194 of 247 `lib/` files touched; **1061 directives** rewritten (1060 relative imports + the 1 conditional-export continuation line in `core/maps/google_maps_loader.dart`). `lib/` now has **0** relative in-project imports (was 1060) and **1104** `package:artisans_app/` imports (was 23). `test/` needed no change (it already used `package:` for `lib/` code and has no internal relative imports).

**How it was done safely (no Dart SDK in env):** a script (`migrate_imports.py`) rewrote **only the text between the quotes** of each directive, preserving indentation, `as`/`show`/`hide` clauses, trailing comments, and each file's existing line endings (so no CRLF flips). Target paths were computed with URI resolution (`urljoin` against a lib-root, matching Dart's `../`-clamping semantics), not `os.path.normpath`.

**Verification:**
- **Semantic invariant:** for every file, the *set of resolved import targets* is identical before and after — only the URI spelling changed (0 mismatches). The reachable module graph is unchanged ⇒ no behavior change.
- Full import-graph check: **1104 in-project imports, 0 dangling**; **0** relative in-project directives remain anywhere.
- Diff is import-only: no file added/deleted/renamed; no full-file rewrites; every Phase-4 changed line is an `import`/`export` directive. Edge cases confirmed intact: the `as distance_utils` clause, the `// For TradeTypeX` trailing comment, and the two-branch conditional export.
- **Incidental fix:** the redundant extra `../` in `role_selection_screen.dart` and `live_tracking/extra_charge_card.dart` (noted in Phase 2) is gone — both are now canonical `package:` paths.

**To revert Phase 4 (part 1):** the change is a pure per-file import-URI rewrite, so `git checkout -- <files>` on the affected `lib/` files (or reset to anchor `472785a`) restores the relative form. `migrate_imports.py` is idempotent and re-runnable.

## Phase 4 (part 2) — executed 2026-08-21 (folder conventions — deliberately minimal)

Decisions were made explicitly with the owner, whose guiding constraint was **"the current app works; don't introduce anything that forces us to retest and fix."** So of the three §6 convention items, only the one that fixes a genuine *layering* defect was acted on; the two cosmetic-consistency items were intentionally left alone.

- **Widgets convention — LEFT AS-IS (owner's call).** `auth` keeps its 5 live widgets in `features/auth/widgets/` even though every other feature (and auth's own `presentation/widgets/`) uses `presentation/widgets/`. Cosmetic only; not worth the churn/retest.
- **Services convention — LEFT AS-IS (owner's call).** 20 in `core/services/`, 2 feature-owned (`client/services/explore_service.dart` single-feature; `trust_safety/services/reports_service.dart` used by client+trust_safety+shared). No change made. (The cross-feature `reports_service` in a feature is a mild smell but the app works; deferred.)
- **Models — fixed the two cross-feature *leaks* only.** Two models lived inside a feature but were imported by `shared/` (a lower layer depending on a higher one). Both were verified to have no feature dependencies of their own, then moved to `shared/models/`:
  - `features/auth/models/onboarding_session.dart` → `shared/models/onboarding_session.dart` (9 importers updated)
  - `features/worker/presentation/models/worker_job.dart` → `shared/models/worker_job.dart` (20 importers updated, incl. 2 test files)

  The remaining single-feature models were left in their current (inconsistent) locations — `auth/models/`, `client/presentation/models/`, `worker/presentation/models/`, `trust_safety/domain/models/` — since relocating them is pure cosmetics.

**How / verification:** `git mv` (history preserved), then the exact old `package:` path swapped for the new one across all 29 importers (line-endings preserved). Confirmed: 0 residual references to either old path; import-graph = **1104 imports, 0 dangling**; git records both as renames; the moved files' bodies are unchanged (the only in-file diff is Phase-4's import-style conversion, not the move). Compile-identical ⇒ no behavior change, no retest needed.

**To revert Phase 4 part 2:** reverse the two `git mv`s and swap `shared/models/{onboarding_session,worker_job}.dart` back to their old `features/...` paths across the 29 importers.

## What I checked and how

I parsed every `.dart` file under `lib/` and, for each, extracted the classes/enums/mixins/extensions it declares, then cross-checked three things: (1) does the filename match what's actually inside, (2) does the folder/role match the code, and (3) is the file actually reachable (imported by anything). I also built an import graph so every recommendation below carries its blast radius (how many files import the target). Conditional `export`/`import` directives were included, so web/mobile loader stubs are correctly treated as *used*, not orphaned.

Your instinct was right: the dominant issue is **files that were componentized or renamed-in-spirit but never renamed on disk**, plus a handful of **stale duplicates** left behind by those moves. The good news is the codebase is otherwise coherent — this is cleanup, not a rewrite.

---

## Headline findings

| # | Category | Count | Risk to fix |
|---|----------|-------|-------------|
| 1 | Dead files (0 references anywhere) | 10 | **Low** — delete |
| 2 | Empty stub + phantom `features/shared/` root | 1 tree | **Low** — delete |
| 3 | Filename doesn't match any class inside (clear) | 7 | **Low–Med** — rename |
| 4 | Duplicate class in two files (one stale) | 2 pairs | **Low** — delete the stale one |
| 5 | Genuine split-brain (2 live implementations, same name) | 1 (`GradientButton`) | **Med** — needs a decision |
| 6 | Structural / layering inconsistencies | 5 themes | **Med** — conventions |
| 7 | Filename ≈ class but not exact (cosmetic) | ~11 | **Low** — optional |

---

## 1. Dead files — safe to delete (10)

None of these are referenced anywhere in `lib/` (checked by import path **and** by bare filename, to catch conditional/string references):

- `core/cache/cache_debug.dart` — `CacheDebug`
- `core/cache/request_deduplicator.dart` — `RequestDeduplicator`
- `features/auth/widgets/auth_header.dart` — `AuthHeader`
- `features/auth/widgets/profile_step_indicator.dart` — `ProfileStepIndicator`
- `features/auth/widgets/worker_onboarding_header.dart` — `WorkerOnboardingHeader`
- `features/worker/presentation/widgets/request_job_card.dart` — `RequestJobCard` **(older duplicate — see §4)**
- `features/worker/presentation/widgets/worker_scroll_scaffold.dart` — `WorkerScrollScaffold`
- `shared/presentation/screens/worker_home_shell_screen.dart` — `WorkerHomeShellScreen`
- `shared/widgets/google_logo_mark.dart` — `GoogleLogoMark`
- `shared/widgets/rating_widget.dart` — `RatingWidget`

> Note: `cache_debug` and `request_deduplicator` may be intentional infrastructure you haven't wired up yet. Confirm before deleting those two; the other eight are clearly leftovers.
>
> ⚠️ **Not** orphans (do not delete): `core/maps/google_maps_loader_stub.dart` and `google_maps_loader_web.dart` — these are conditional-export targets pulled in by `google_maps_loader.dart`, which `main.dart` imports.

---

## 2. The phantom second "shared" root — delete `features/shared/`

You have **two** shared roots:

- `lib/shared/` — the real one (~40 files: widgets, models, screens, utils).
- `lib/features/shared/` — contains exactly **one** file, `widgets/search_bar.dart`, which is a 31-byte stub: `// TODO Implement this library.`

The real search bar (`shared/widgets/search_bar.dart`, `CustomSearchBar`) is what both importers actually use. The entire `lib/features/shared/` tree is a dead stub and should be removed so there's a single, unambiguous `shared` location.

---

## 3. Filename doesn't match what's inside — rename (7 clear cases)

These are the core "componentized but never renamed" offenders — **no** class in the file matches the filename:

| File (current) | Actually contains | Suggested action | Imported by |
|---|---|---|---|
| `features/worker/.../widgets/worker_request_card.dart` | `RequestJobCard`, `NearbyJobRequestFoundCard`, `JobTag` | Rename → `worker_request_cards.dart` (plural) **or** split into 3 files | 2 |
| `features/client/.../widgets/artisan_detail_sheet.dart` | `TrustBadge`, `SelectedWorkerPreview` (+ `TradeType` enum) | Rename → `selected_worker_preview.dart`; move `TrustBadge` to shared, move `TradeType` enum to a model | 2 |
| `features/client/.../widgets/map_search_bar.dart` | `MapContextPill`, `MapOverlayControls`, `MapControlChip` | Rename → `map_overlay_controls.dart` (it is not a search bar) | 1 |
| `features/trust_safety/domain/models/report_model.dart` | `SafetyReport` | Rename → `safety_report.dart` | 3 |
| `features/worker/.../utils/worker_application_navigation.dart` | `WorkerApplicationDestination` (enum) | Rename → `worker_application_destination.dart` | 1 |
| `features/worker/.../widgets/worker_earnings_summary.dart` | `PerformanceOverviewCard` | Rename → `performance_overview_card.dart` | 1 |
| `shared/widgets/mapbox_client_map.dart` | `MapboxWorkerMarker`, `MapboxWorkerDiscoveryMap`, `MapboxJobLocationMap` | Rename → `mapbox_maps.dart` (it's not client-specific) **or** split | 2 |

Because your imports are **relative**, an in-place rename only changes the filename portion of the import string in each importer — mechanically simple and low-risk at these blast radii (1–3 importers each).

---

## 4. Stale duplicates — one live, one leftover (delete the leftover)

- **`RequestJobCard` exists twice.** `worker_request_card.dart` (532 L, live, imported by 2) vs `request_job_card.dart` (188 L, **0 importers**). The correctly-named file is the dead one — a textbook rename-without-cleanup. Delete `request_job_card.dart`, then rename the live file (see §3).
- **`AvailabilityCard` exists twice.** `worker_dashboard/availability_card.dart` (150 L, live, used by `worker_requests_screen`) vs `widgets/availability_card.dart` (52 L, **0 importers**). Delete the 52-line orphan.

---

## 5. Genuine split-brain — needs a decision: `GradientButton`

Two **different, both-live** implementations of `GradientButton`:

- `shared/widgets/gradient_button.dart` (71 L) — used by ~9 auth/wallet/payment/profile screens.
- `features/worker/presentation/widgets/gradient_button.dart` (131 L) — used by ~11 worker screens + `worker_job_alert_sheet`.

This is the one item that isn't a mechanical fix — the two have diverged. Options: (a) unify into one configurable `shared` button and delete the worker copy, or (b) if the worker variant is deliberately different, rename it `worker_gradient_button.dart` / `WorkerGradientButton` so the divergence is explicit. Same-name-different-behavior across ~20 call sites is the kind of thing that causes subtle UI bugs, so I'd resolve this deliberately rather than in a batch rename.

_(Also flagged: two `search_bar.dart` files, but that resolves itself once the empty stub in §2 is deleted.)_

---

## 6. Structural / layering inconsistencies

These aren't naming bugs, but they're why naming drifts. Worth aligning as you "move forward":

1. **Widgets folder convention differs by feature.** `client`, `worker`, `trust_safety` put widgets under `presentation/widgets/`, but `auth` keeps them in `features/auth/widgets/` (8 files, 5 live). Pick one — `presentation/widgets/` is your majority convention — and move auth's live widgets there.
2. **Models live in three different places.** `presentation/models/` (client, worker), `domain/models/` (trust_safety), and top-level `shared/models/`. Three conventions for the same concept. Decide: domain models under `<feature>/domain/models/` (or `/models/`), cross-feature models under `shared/models/`.
3. **Services split two ways.** 20 services in `core/services/`, but `client` and `trust_safety` each have their own `services/`. Either feature-owned services live in the feature, or everything shared lives in `core/` — currently it's ad hoc.
4. **Feature layering is uneven.** `client`/`trust_safety` have `data`+`domain`; `worker` has `state`+`utils`+`models` but no `data`/`domain`; `wallet` is presentation-only. That's fine if intentional, but documenting the expected layers per feature would stop the drift.
5. **Import style is mixed: 936 relative vs 26 `package:artisans_app/`.** This is the highest-leverage fix for future refactors — with relative imports, every file move rewrites `../../../` chains across importers. Standardizing on `package:artisans_app/...` absolute imports makes files movable/renamable with a simple find-replace of one line, and makes the deep-nested widget folders far less painful. Consider adding the `always_use_package_imports` lint.

---

## 7. Cosmetic near-misses (optional)

Filename is close to the class but not exact. Low value, fix opportunistically:
`shared/widgets/filter_chip.dart`→`AppFilterChip` (also shadows Flutter's `FilterChip`), `shared/widgets/search_bar.dart`→`CustomSearchBar` (shadows Flutter's `SearchBar`), `shared/widgets/settings_group_tile.dart`→`SettingsGroup`+`SettingsTile`, `core/utils/icon_mapper.dart`→`PhosphorIconMapper`, `features/client/.../live_tracking/job_info_card.dart`→`TrackingJobInfoCard`.

**Deliberate "collection" files (leave, but standardize the term):** `*_atoms.dart`, `*_components.dart`, `*_states.dart` (e.g. `onboarding_atoms`, `profile_atoms`, `tracking_atoms`, `home_atoms`, `gallery_components`, `review_components`, `artisan_list_states`). These intentionally bundle small widgets — that's fine, but you're using three different words (`atoms`/`components`/`states`) for the same idea. Pick one.

**False alarms (correctly named, ignore):** `primary_button.dart`, `secondary_button.dart`, `custom_app_bar.dart`, `custom_back_button.dart`, `error_state_view.dart`, `worker_session_state.dart`, `core/navigation/app_router.dart` — a button/bar/view/router *is* a widget/class of that kind; these are named correctly.

---

## Recommended path forward (phased)

**Phase 0 — Baseline (do first).** Commit current state, then run `flutter analyze` and save the output so you can prove the refactor introduced no new errors.

**Phase 1 — Delete dead weight (zero behavior change).** Remove the 8 confirmed orphans (§1), the `features/shared/` stub tree (§2), and the two stale duplicates (§4: `request_job_card.dart`, `widgets/availability_card.dart`). Confirm intent on `cache_debug`/`request_deduplicator` first. Re-run `flutter analyze` → should be identical.

**Phase 2 — Rename the 7 clear mismatches (§3).** One file at a time: rename on disk, update the 1–3 relative imports, analyze. Small, reviewable commits.

**Phase 3 — Resolve `GradientButton` (§5)** as an explicit decision (unify or rename-to-differentiate).

**Phase 4 — Structural alignment (§6).** Standardize import style (biggest long-term win), then converge the widgets/models/services folder conventions. Do this last since it touches the most files.

I can execute any phase for you — Phases 1–2 are safe and mechanical, and I'd verify each step with `flutter analyze`. Or I can generate the exact shell commands / a checklist if you'd rather drive.
