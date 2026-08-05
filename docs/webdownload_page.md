# CraftMatch App Download Page

## Summary
Add a public `#/download` page to the CraftMatch Verification Portal, inspired by WhatsApp’s download page structure: platform-specific download buttons, a browser fallback, short feature reassurance, and help/FAQ content. Keep CraftMatch’s warm cream, terracotta, gold, trust-focused verification theme.

Reference used: [WhatsApp Desktop download page](https://www.whatsapp.com/download/desktop?lang=en).

## Key Changes
- Add a new `DownloadPage` in the verification portal with:
  - Hero heading like “Download CraftMatch”
  - Primary platform cards for Android, iOS, Windows, macOS, and Web
  - Clear install requirements/status per platform
  - A web fallback CTA for users who cannot install
  - Short trust/value sections: verified artisans, secure accounts, job tracking, chat/bookings
  - FAQ/help section for install issues
- Add `download` to the portal hash routing in `App.tsx`:
  - `#/download`
  - `onNavigate('download')`
- Add “Download App” to the public header and footer platform links.
- Use existing Tailwind theme classes, `PublicLayout`, `btn-primary`, `btn-secondary`, `card-hover`, and Lucide icons.

## Backend Release Metadata
- Add a public backend endpoint:
  - `GET /api/releases/app`
- Response shape:
```ts
type AppReleaseLink = {
  platform: 'android' | 'ios' | 'windows' | 'macos' | 'web';
  label: string;
  href: string;
  version?: string;
  minRequirement?: string;
  available: boolean;
  external?: boolean;
};

type AppReleaseResponse = {
  appName: 'CraftMatch';
  latestVersion: string;
  updatedAt: string;
  links: AppReleaseLink[];
};
```
- Implement the endpoint as a small new route module, for example `/routes/releases.ts`, mounted at `/api/releases`.
- Source the release links from backend environment variables so deployment can swap real APK/App Store/Microsoft Store/web URLs without rebuilding the portal.
- If a platform URL is missing, return `available: false`; the page should show “Coming soon” rather than a broken button.

## Frontend Data Flow
- Add a typed `apiGet<AppReleaseResponse>('/releases/app')` call from the download page.
- Loading state: show skeleton/spinner cards.
- Error state: show a friendly message and still render a Web fallback if configured.
- Download button behavior:
  - Available native platforms open `href`.
  - Web platform opens the CraftMatch web app URL.
  - Unavailable platforms show disabled “Coming soon”.
- No admin auth required.

## Test Plan
- Backend:
  - Unit/integration test `GET /api/releases/app` returns all five platform entries.
  - Missing env URL marks that platform unavailable.
  - Endpoint is public and does not require auth/admin headers.
- Frontend:
  - Typecheck and build the portal.
  - Verify `#/download` loads directly and via navigation.
  - Verify loading, error, available, and unavailable platform states.
  - Check responsive layout on mobile and desktop.
- Manual acceptance:
  - Page visually matches CraftMatch theme.
  - Header/footer navigation includes Download App.
  - No broken links are shown as active download buttons.
  - Users can identify the correct platform and install path in one screen.

## Assumptions
- The first deploy will expose all platforms in the UI, even if some are marked “Coming soon”.
- Actual binary/store URLs will be configured on the backend through environment variables.
- The page belongs in the existing verification portal, not the Flutter/Expo app.
- The portal remains hash-routed rather than adding React Router.
