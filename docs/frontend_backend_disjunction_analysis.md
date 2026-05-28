# Frontend-Backend Disjunction Analysis

After a thorough review of the current Flutter frontend (`artisansApp_frontend`) and the Express backend plans (`artisansApp_backend`), there are several critical disjunctions between what the Frontend UI currently collects and what the Backend Schema (`UNIFIED_SCHEMA.md`) requires. 

Currently, the frontend is a UI shell populated with stub data (`shared_stub_data.dart`) and lacks network dependencies (`http`, `dio`, or `supabase_flutter`). When the frontend eventually integrates with the backend, the following data mismatches will cause the integration to fail.

## 1. Category Mapping
- **Frontend Current State:** `job_post_category_screen.dart` passes a hardcoded string slug (e.g., `'plumbing'`, `'electrical'`).
- **Backend Expects:** `category_id` (UUID foreign key to the `categories` table).
- **Required Action:** The frontend must fetch the categories list from the backend/Supabase first, and pass the exact UUID for the selected category.

## 2. Geolocation vs. Plain Text
- **Frontend Current State:** `job_post_location_screen.dart` provides a dummy map image and collects a single `address` string (e.g., `'123 Osu St, Accra, Ghana'`).
- **Backend Expects:** `location_lat` (numeric), `location_lng` (numeric), and `address_label` (string). The backend matching engine (`haversine.ts`) **requires** precise coordinates to find nearby workers.
- **Required Action:** The frontend must integrate a real Map SDK (e.g., Google Maps) and a Geocoding/Places autocomplete to extract both the text label and the exact Latitude/Longitude coordinates.

## 3. Budget Shapes
- **Frontend Current State:** `job_post_urgency_screen.dart` allows toggling between 'Fixed' and 'Range', but only collects a single `projectBudget` (double) value for both.
- **Backend Expects:** `budget_type` (enum), and specifically `budget_fixed`, `budget_min`, `budget_max`.
- **Required Action:** The frontend UI must be updated. If 'Range' is selected, it must present two input fields (Min and Max) and send `budget_min` and `budget_max` to the backend.

## 4. Scheduling Timestamps
- **Frontend Current State:** Captures `preferredDate` (DateTime object) and `timeWindow` (String, e.g., 'Morning (8am - 12pm)').
- **Backend Expects:** `job_mode` ('asap' | 'scheduled') and `scheduled_for` (`timestamptz`).
- **Required Action:** The frontend needs a utility to parse the `preferredDate` and `timeWindow` into a single ISO-8601 timestamp string (`scheduled_for`) before sending the POST request.

## 5. Missing Fields
- **Service Type:** The backend schema requires a `service_type` enum (`home_visit` | `remote` | `either`). The frontend UI currently skips this question entirely.
- **Required Action:** Add a UI toggle in the job posting flow for the client to specify the service location type.

## 6. Missing Dependencies
- **Frontend Current State:** `pubspec.yaml` lacks `supabase_flutter` (for Auth and Realtime) and HTTP clients.
- **Required Action:** The frontend team must install these packages to implement the `api_client.dart` and authenticate via OTP.

---

### Conclusion & Recommendation

The backend plans (`BACKEND_PLAN.md`, `BACKEND_DELEGATION_PLAN.md`, `UNIFIED_SCHEMA.md`) are **structurally sound and well-architected**. The disjunction lies entirely in the fact that the **Frontend is currently an unintegrated UI mockup**. 

We do not need to change our backend plans. Instead, we should hand this report to the Frontend Developer (Nhyira) so they can update their UI inputs and data classes to match the agreed-upon `UNIFIED_SCHEMA.md` contract.
