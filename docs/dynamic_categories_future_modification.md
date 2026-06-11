# Future Modification: Data-Driven Categories & Subcategories

Currently, categories, subcategories, and worker trades are hardcoded throughout the frontend. This limits scalability: adding a new job type or changing an icon requires a new app release. The goal is to make the database the single source of truth.

## Background Context
*   **`JobPostCategoryScreen`**: Fetches categories from the DB, but hardcodes their icons and colors based on name matching.
*   **`JobPostSubcategoryScreen`**: Relies entirely on `JobPostSubcategoryCatalog`, a static Dart map holding all subcategories.
*   **`RoleSelectionScreen`**: Uses a hardcoded `_TradeEntry` list for workers to select their professions.
*   **`UNIFIED_SCHEMA.md`**: Imposes strict schema change rules requiring a proposal and team agreement.

## Design Considerations
> [!IMPORTANT]
> The team contract in `UNIFIED_SCHEMA.md` requires explicit agreement before modifying the database schema. Please review the proposed `subcategories` table and the new columns on the `categories` table.

> [!WARNING]
> Migrating `skills` mapping: Currently, workers select from a hardcoded list of trades. If we replace this with the dynamic categories list, workers will select `categories.name` as their skills. We should confirm if we want workers to select top-level *categories* (e.g. "Plumbing"), or specifically *subcategories* (e.g. "Leak repair") during onboarding.

## Proposed Changes

---

### Backend Schema & Migrations

#### [MODIFY] `UNIFIED_SCHEMA.md`
*   Add `color_hex` and `description` to the `categories` table definition.
*   Add the new `subcategories` table definition.

#### [NEW] `supabase/migrations/XXXXXXXXXXXXXX_dynamic_categories.sql`
*   **Add Columns**: `ALTER TABLE categories ADD COLUMN color_hex text, ADD COLUMN description text;`
*   **Create Table**: `subcategories`
    *   `id` uuid PK
    *   `category_id` uuid FK -> `categories.id`
    *   `name` text
    *   `slug` text
    *   `description` text
    *   `is_active` boolean default true
    *   `sort_order` integer default 0
*   **Add RLS Policies**: Read access for authenticated/anon users.
*   **Update Generated Types**: Run `supabase gen types typescript` after the migration.

#### [NEW] `supabase/seeds/categories_and_subcategories.sql`
*   Insert the existing 8 categories (Plumbing, Electrical, etc.) with their actual `icon_name` (e.g., `'drop'`, `'lightning'`), `color_hex` (e.g., `'#4648D4'`), and descriptions.
*   Insert the corresponding subcategories currently found in `JobPostSubcategoryCatalog`.

---

### Backend API

#### [MODIFY] `artisansApp_backend/src/routes/categories.ts` (or relevant controller)
*   Update the `GET /categories` endpoint to fetch categories *with* their nested subcategories (e.g. using Supabase's `*, subcategories(*)` syntax) so the client has the full hierarchy in one fast request.

---

### Frontend

#### [NEW] `lib/core/utils/icon_mapper.dart`
*   Create a helper `PhosphorIconMapper.fromString(String name)` that safely maps string names (like `'drop'`, `'wrench'`) to their corresponding `PhosphorIcons` constants.

#### [NEW] `lib/core/utils/color_mapper.dart`
*   Create a helper to convert hex strings like `'#4648D4'` to Flutter `Color` objects.

#### [MODIFY] `lib/core/services/categories_service.dart`
*   Ensure the caching mechanism handles the new nested JSON structure containing subcategories. 

#### [MODIFY] `lib/features/client/presentation/screens/job_post_category_screen.dart`
*   Remove the `_getIconForCategory` and `_getColorForCategory` hardcoded logic.
*   Use the new `icon_name`, `color_hex`, and `description` properties directly from the API response.

#### [DELETE] `lib/features/client/presentation/models/client_job_draft.dart`
*   Remove the `JobPostSubcategoryCatalog` class entirely.

#### [MODIFY] `lib/features/client/presentation/screens/job_post_subcategory_screen.dart`
*   Instead of using the hardcoded catalog, extract the `subcategories` list from the selected category object (which is passed down or accessible via the `CategoriesService`).

#### [MODIFY] `lib/features/auth/presentation/screens/role_selection_screen.dart`
*   Replace the hardcoded `_TradeEntry` array.
*   Fetch the dynamic list of categories via `CategoriesService` during the worker onboarding step and render those options.

## Verification Plan

### Manual Verification
1.  **Job Posting Flow**: Go through the client app and post a job. Verify that categories show the correct DB-driven icons/colors, and the subcategories load dynamically based on the selection.
2.  **Worker Onboarding**: Create a new worker account and verify that the "Trade" selection step displays the DB-driven categories instead of the hardcoded list.
3.  **Supabase Reflection**: Verify the `subcategories` table exists and `types.ts` is up to date.
