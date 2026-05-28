# Client flow audit

Audit date: 2026-05-28  
Scope: UI-only client module after semantic flow remediation.

## Summary

| Area | Status | Notes |
|------|--------|-------|
| Post-auth shell | Pass | Auth → `ClientShell` with 4-tab bottom nav |
| Single bookings entry | Pass | Bookings tab only; Home shows in-progress banner |
| Job post → match → track | Pass | Summary → Finding → Live tracking (stack cleared to shell) |
| Rate → bookings tab | Pass | `popToShellAndSelectTab(bookings)` |
| `/client-home` deep link | Pass | Resolves to `ClientShell` |
| `/booking-history` deep link | Pass | Resolves to shell Bookings tab |
| Artisan profile actions | Pass | Call (stub), Chat (`ChatDetailScreen`), Book → finding |
| Live tracking actions | Pass | Call (stub), Message (chat), link → bookings tab |
| Dead `onPressed: () {}` | Pass | Removed on profile reviews / title footer links |
| Job summary copy | Pass | Uses `ClientJobDraft` from wizard data |

## Job post wizard (2026-05-28 polish)

| Area | Status | Notes |
|------|--------|-------|
| Shared scaffold | Pass | `JobPostWizardScaffold` — pinned CTAs, `STEP n OF 7` progress |
| Artisans branding | Pass | No ConnectFlow strings; app bar **Post a Job** / **Review & Post** |
| Category → subcategory data | Pass | `categoryId` + `categoryName`; subcategories filtered by parent |
| GHS budget | Pass | Slider min GH₵50 on urgency step |
| Validation | Pass | Title ≥3, description ≥20, address required, budget ≥50 |
| Summary overflow | Pass | Budget uses `Wrap`; chips use ellipsis |
| Edit / draft | Pass | Edit sheet pops to step; Save draft → `popToShell` |
| Overflow on small screens | Pass (code) | Promo bloat removed from title/urgency; scroll + pinned footer |

### Wizard manual checklist

| # | Step | Expected |
|---|------|----------|
| W1 | Category → Continue | Subcategory list matches category (e.g. Plumbing only) |
| W2 | Complete all steps | Summary shows **Plumbing**, not `plumbing` |
| W3 | Small device | Back/Next always visible without scrolling |
| W4 | Summary → Edit | Bottom sheet → jump to category/title/location |
| W5 | Save draft | Returns to shell with snackbar |
| W6 | Post job | Finding → live tracking (existing flow) |

## Manual test checklist

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Sign up as client → complete profile | Lands on `ClientShell`, nav visible | Manual verify |
| 2 | Home → Post a Job → complete wizard → Post | Finding screen, then live tracking | Manual verify |
| 3 | Back from tracking | Returns to shell (not bare home) | Manual verify |
| 4 | Complete job → Rate → Submit | Bookings tab inside shell | Manual verify |
| 5 | Home → no “Booking History” push | Only banner / tab switch | Pass (code) |
| 6 | Bookings tab | No second history stack | Pass (code) |
| 7 | Explore → profile → Book Now | Finding → tracking | Manual verify |
| 8 | Messages tab → open chat → back | Stays in shell | Manual verify |
| 9 | `flutter analyze lib/features/client` | No errors | Pass (warnings only) |

## Known limitations (UI phase)

- Stub data in `ClientBooking.sampleBookings` and `SharedStubData` for chat.
- Call / Terms / Privacy / Support use dialogs or snackbars until backend/legal screens exist.
- Client design PNGs (`Artisans_Organized_ui/client/`) not in repo; layout not pixel-matched.

## Key files

- [`lib/features/client/presentation/client_shell.dart`](../lib/features/client/presentation/client_shell.dart)
- [`lib/features/client/presentation/navigation/client_navigation.dart`](../lib/features/client/presentation/navigation/client_navigation.dart)
- [`lib/features/client/presentation/models/client_booking_stub.dart`](../lib/features/client/presentation/models/client_booking_stub.dart)
