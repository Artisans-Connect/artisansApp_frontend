# CraftMatch UI Design System & Component Architecture

This document defines the visual design tokens and component architecture across all client and worker UI surfaces.

---

## 1. Visual Design Tokens

```yaml
name: Artisans
colors:
  surface-base: '#FFF8F0'        # warm off-white
  surface-card: '#FFFFFF'
  primary: '#C15A3D'             # terracotta / earth
  primary-dark: '#8B3A2A'
  accent-gold: '#E6A017'         # Kente gold
  accent-warm: '#D97706'
  text-primary: '#2C2418'        # warm dark brown
  text-secondary: '#5C5243'
  border-subtle: 'rgba(0, 0, 0, 0.06)'
  success-green: '#00E676'
  error: '#BA1A1A'
  on-error: '#FFFFFF'
typography:
  font-family: Satoshi           # Modern grotesque with high legibility
  display-lg: '32px / 800 / #2C2418'
  body-lg: '16px / 500 / #5C5243'
  price-tag: '18px / 700 / #C15A3D'
  display-md:
    fontFamily: Satoshi
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.2'
  body-md:
    fontFamily: Satoshi
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Satoshi
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
components:
  card-radius: 16px
  input-radius: 12px
  glass-blur: none
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 20px
  container-max: 1200px
```

---

## 2. Component Directory Topology

### `auth/` — Authentication & Role Selection
- Handles Supabase phone & email authentication, OTP verification, and onboarding.
- Manages multi-step role selection (`photo_location_page.dart`, `service_areas_page.dart`) with default positioning centered on Kumasi / KNUST.

### `client/` — Domestic Client Booking & Discovery Experience
- **Map & Catalog Discovery:** Interactive map (`map_discovery_screen.dart`), category grids (`client_home_screen.dart`), and artisan profile inspection.
- **5-Step Job Wizard:** Job category, subcategory, budget & scope, landmark address geocoding, and idempotent submission.
- **Quote Negotiation & Live Tracking:** `NegotiationChatSheet` with contact masking, real-time Mapbox/Google Maps GPS streaming, and completion approval modals.

### `worker/` — Artisan Dispatch & Workspace Execution
- **Dispatch Queue:** Inbound job notifications (`worker_requests_screen.dart`) and quote submission.
- **Active Execution Shell:** Pre-start navigation (`worker_active_pre_start_screen.dart`), in-progress tracking (`worker_active_in_progress_screen.dart`), and on-site extra charges.
- **Completion & Wallet:** Photo proof upload (`worker_completion_form_screen.dart`), earnings dashboard, and review history.

### `shared/` — Common Atomic Widgets & Overlays
- Standard app buttons, input fields (`AppInput`), status badges (`_TrustBadge`), avatar pickers, and modal bottom sheets.
