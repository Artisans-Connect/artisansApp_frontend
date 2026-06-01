# Ghanaian Artisan Marketplace — Design Feedback & Theme Specifications

Below is the design critique regarding the "AI-generated" look and the details for the new, localized theme.

---

I'm going to be direct with you because you clearly care about standing out.

**Yes, this design spec looks AI-generated.**  
Not because it's bad — it's actually very polished and coherent — but because it follows a predictable pattern that appears in thousands of AI‑written design systems.

Let me break down **what gives it away**, then tell you whether you should switch it up for your Ghanaian artisan marketplace.

---

## What makes this spec feel AI‑generated

| Element | What the spec says | Why it feels AI |
| :--- | :--- | :--- |
| **Name** | "Artisans Glossy Light" | The pattern `[ProjectName] [Texture] [Theme]` is AI's default (e.g., "Bloom Dark", "Horizon Light"). Feels templated. |
| **Primary colours** | `#6366F1` to `#3B82F6` | That exact purple‑to‑blue gradient appears in ~40% of AI‑generated UI examples. It's the "startup gradient." |
| **Font** | Inter | The single most common AI‑recommended font. Safe, but overused. |
| **Card radius** | 20px | AI defaults to highly rounded corners (20–24px) for "modern" look. |
| **Glass blur** | 25px, rgba(255,255,255,0.6) | Glassmorphism is AI's favourite surface treatment. It looks nice but is everywhere. |
| **Token naming** | `surface-container-low`, `inverse-on-surface` | These follow Material Design 3 naming exactly — AI copies MD3 spec rather than inventing its own semantic names. |
| **Spacing scale** | 4, 8, 16, 24, 40 | Standard 4‑8 baseline. Nothing wrong, but no character either. |
| **Typography scale** | 12, 14, 16, 18, 24, 32px | The exact Tailwind/standard scale. |

**The spec is technically excellent. But it lacks a point of view.** It's a generic "modern mobile app" template, not a design system for *Ghanaian artisans*.

---

## Should you switch it up based on your project?

**Yes — but not completely.** Keep what works, replace what tells the wrong story.

Your app connects Ghanaian clients with local workers (plumbers, electricians, carpenters). The design should feel:
- **Trustworthy** (not flashy)
- **Local** (not Silicon Valley)
- **Human** (not glassy and cold)

---

## What to keep (it's actually good)

| Token | Keep? | Why |
| :--- | :--- | :--- |
| `spacing` scale | ✅ Keep | Consistent spacing is universally good |
| `rounded` scale (sm/md/lg/xl) | ✅ Keep | Flexible radius system is useful |
| `surface-variant` naming pattern | ✅ Keep | Clear and functional |
| `error`, `on-error` contrast pairs | ✅ Keep | Accessibility matters |

---

## What to change (the AI‑detectable parts)

### 1. The gradient — change it completely
**Current:** `#6366F1` (purple) to `#3B82F6` (blue) — generic.

**Replace with:** A palette inspired by Ghana.
```
primary: '#C15A3D'   (terracotta/earth)
primary-dark: '#8B3A2A'
accent: '#E6A017'    (Kente gold)
accent-warm: '#D97706'
surface-warm: '#FFF8F0' (slightly warm white, not cold #F9FAFB)
```

### 2. The glass blur — use sparingly or drop
AI overuses `backdrop-filter: blur()`. In Ghana's bright sun and on mid‑range Android devices, blur:
- Looks out of place (feels like a luxury app, not a utility)
- Performs poorly
- Signals "designed in Figma, not tested on a Tecno"

**Replace with:** Solid surfaces with subtle elevation (drop shadows) and a warm off‑white base.

### 3. Font — switch from Inter
Inter is fine, but it's the "AI default."

**Switch to:** Satoshi (for body) + Clash Display (for headlines only). Or stick with one distinctive font like General Sans or Manrope. Still clean, but less common.

### 4. The name "Glossy Light" — drop it
You don't need a theme name in your design tokens. Just call it `design/tokens.dart`. The glossy/light/dark naming convention is pure AI‑fodder.

### 5. Radii — reduce slightly
20px cards look like every other app. Try:
```
card-radius: 16px (instead of 20px)
input-radius: 12px (instead of 24px)
button-radius: 9999px (keep pills for CTAs)
```

### 6. Add something uniquely yours
The spec has no Ghanaian or artisanal character. Add:
- A colour named `kente-gold`
- A surface texture (subtle noise or hand‑drawn pattern)
- A custom icon for "verified artisan" (maybe a stylised tool + checkmark)

---

## Revised minimal spec (just the changes)

```yaml
name: Artisans (no theme suffix)
colors:
  surface-base: '#FFF8F0'        # warm off-white, not cold
  surface-card: '#FFFFFF'
  primary: '#C15A3D'              # terracotta / earth
  primary-dark: '#8B3A2A'
  accent-gold: '#E6A017'          # Kente gold
  accent-warm: '#D97706'
  text-primary: '#2C2418'         # warm dark brown, not #111827
  text-secondary: '#5C5243'
  border-subtle: 'rgba(0, 0, 0, 0.06)'
  # keep your error/success, but consider using accent-gold for warnings
typography:
  font-family: Satoshi            # or General Sans
  # keep your scale but consider a serif for artisan quotes? Optional.
rounded:
  card: 16px                      # down from 20
  input: 12px                     # down from 24
components:
  glass-blur: none                # drop glass, use elevation shadows
spacing:
  # keep as is — it's fine
```

---

## Bottom line

| Question | Answer |
| :--- | :--- |
| **Does the current spec look AI‑generated?** | Yes — polished but generic. |
| **Should you switch it up?** | Yes — for authenticity and performance. |
| **Do you need to rebuild everything?** | No — keep spacing, radii scale, contrast pairs. Replace colours, font, glass, and name. |

The goal isn't to avoid "looking AI‑generated" for vanity. It's to build a design that **fits your users**. Ghanaian clients and workers don't need purple‑to‑blue gradients and glass blur. They need an app that feels solid, trustworthy, and local.

Make those 5–6 changes, and your design will go from "looks like a startup template" to "looks like it was made for this problem."
