---
type: "Reference"
title: "Getting Started & Development"
description: "Setup procedures, dev scripts, and Flutter build/run instructions for the Web/Desktop Client."
---

# Getting Started & Development

This page outlines the setup procedure and development workflows for the **artisansApp_frontend** Flutter application.

## Prerequisites
- Flutter SDK `>=3.22.0` (ensure `flutter` is on your system environment `PATH`).
- Web compiler or Chrome for web testing.

---

## Installation

1. Navigate to the project directory:
   ```bash
   cd artisansApp_frontend
   ```
2. Pull down Dart dependencies:
   ```bash
   flutter pub get
   ```
3. Set up environment variables by copying `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
   Modify the values in `.env` to match your local setup:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `EXPRESS_API_BASE_URL`

---

## Development Scripts

### Running the App
To compile and launch the application in development debug mode:
```bash
# Run on the default available device
flutter run

# Specifically run on Google Chrome (web mode)
flutter run -d chrome
```

### Production Build
To build the static web assets for deployment:
```bash
flutter build web --release
```
The compiled HTML/JS/CSS assets will be written to `build/web/`.

### Wiki Management
OpenWiki scripts are configured in [package.json](file:///c:/Users/user/Downloads/FinalYearProject/artisansApp_frontend/package.json):
- **`npm run docs:wiki:init`**: Initialize the local OpenWiki documentation directory.
- **`npm run docs:wiki:update`**: Update and reconcile recent changes in documentation files.
