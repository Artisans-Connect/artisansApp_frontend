---
type: "Reference"
title: "Architecture Overview"
description: "Architectural summary and code structure details of the CraftMatch Flutter Web App."
---

# Architecture Overview

This document describes the codebase structure, state management, and page layout configuration of the **artisansApp_frontend** Flutter application.

## Modular Feature Directory Design

The app is built with a feature-first architectural pattern under [lib/](file:///c:/Users/user/Downloads/FinalYearProject/artisansApp_frontend/lib):

- **`lib/features/auth/`**: Sign-up flow, email OTP/magic-link verification, worker sign-up, credentials, and password resets.
- **`lib/features/client/`**: Client dashboards, map views for tracking, checkout portals, review forms, and reservation requests.
- **`lib/features/worker/`**: Artisan scheduling panels, live location updating services, active job logs, and earnings history.
- **`lib/features/shared/`**: Real-time chat widgets, push notification feed, and user settings pages.

- **`lib/core/`**: Central application configurations, themes, network clients, Supabase adapters, and global constants.
- **`lib/shared/`**: Reusable generic widgets (buttons, loaders, search bars, inputs).

## Routing & State Management

- **Routing**: Configured centrally in [lib/app.dart](file:///c:/Users/user/Downloads/FinalYearProject/artisansApp_frontend/lib/app.dart) (using `go_router` or standard Navigator routes) resolving screen destinations dynamically by parsing the authenticated user's metadata role.
- **State Management**: Manages state queries (location tracking, active job statuses, and chat lists) by integrating reactive providers bound to backend API triggers.
