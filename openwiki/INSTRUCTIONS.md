# OpenWiki instructions for artisansApp_frontend

This wiki documents only the `artisansApp_frontend` repository.

Treat this repository as the Flutter/web frontend surface of CraftMatch. Focus on checked-in source, app structure, screens, routing, assets, build/deploy configuration, environment requirements, and how the frontend consumes backend contracts.

Do not document the full CraftMatch platform as if this repo owns it. When mentioning the backend, mobile app, verification portal, Supabase, or external deployment systems, describe them only as integration boundaries unless the behavior is directly proven by this repository.

Prefer source-backed claims. If a product flow depends on another repository, label that dependency clearly and point readers to the shared `CraftMatch_Docs` repository for platform-wide architecture.

Never reproduce secrets or values from ignored files such as `.env`, platform credential files, build outputs, dependency folders, or generated OpenWiki pages.

Every overview page should make the scope explicit: this is the frontend repository wiki, not the whole-system documentation.
