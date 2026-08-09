# Algorithmic Real-Time Matching, Escrow Settlement, and Verification System for On-Demand Artisan Platforms

## Abstract
**Background:** The informal artisan sector in emerging economies like Ghana suffers from significant inefficiencies, primarily driven by information asymmetry, lack of trust, platform circumvention, and slow discovery processes. **Methods:** We engineered a distributed architecture consisting of a Flutter-based cross-platform client (mobile and PWA), a React-based web verification portal, and a Node.js/Express backend integrated with Supabase. Its core is an interpretable, low-compute **three-factor weighted dispatch heuristic** that fuses spatial proximity (Haversine distance, min–max normalised over the live candidate pool), a historical **response-rate** reliability signal, and aggregate rating into a single transparent score, with portal-issued verification applied as a tie-breaker, a location-freshness filter, a fairness slot that guarantees new artisans exposure, and a managed **escrow wallet ledger** featuring real-time in-app price bargaining, additive extra charge calculations, and 48-hour auto-release payout mechanics. **Results:** On a seeded discrete-event simulation over a Greater-Kumasi geography, the ranking function computes scores for 5,000 candidates in tens of milliseconds on commodity hardware. Against a graded baseline ladder (random → nearest-only → full model) on identical demand streams, the full model does **not** improve raw match rate when supply is adequate — all policies match nearly every job — but it reduces push notifications per successful match by ~17% relative to a proximity-only baseline by steering dispatches toward responsive workers. This efficiency comes at a measurable **equity cost**: optimising for responsiveness concentrates load on the most reliable workers (Gini 0.78 vs 0.52 for proximity-only), which we address with an explicit fairness safeguard. A greedy-vs-Hungarian analysis shows the deployed per-job assignment is within ~2% of the globally optimal batch assignment, justifying the low-compute heuristic. **Discussion:** The contribution is not the ranking mathematics — every component is established prior art — but the **socio-technical adaptation**: folding verification, protected in-app bargaining, escrow wallet ledgers, and location-freshness into a continuously-ranked, interpretable, deployable signal that partially **bootstraps trust, deters platform circumvention, and reduces information asymmetry** in a low-resource, mobile-first market. We frame this as platform intermediation, not formalisation of the informal economy. Future work targets field validation and learned, demand-adaptive weights.

## 1. Introduction and Problem Statement

The informal sector constitutes a substantial portion of the labor market in developing economies, yet it remains hindered by severe fragmentation. Consumers seeking skilled artisans (e.g., plumbers, electricians, carpenters) typically rely on word-of-mouth referrals or static directories. This traditional approach yields suboptimal experiences characterized by opaque pricing, unverifiable skill levels, high latency in service fulfillment, and significant risk of platform circumvention (off-platform transaction leakage).

### Scientific Problem Statement
Current digital solutions for the informal artisan economy fail to adequately balance real-time spatial proximity with verifiable quality metrics and financial trust mechanisms. This knowledge gap results in either high-latency discovery processes, suboptimal worker allocations, or transaction leakage off-platform, necessitating an algorithmic and financial escrow approach that continuously synthesizes location freshness, historical performance, verified credentials, and managed escrow ledgers to optimize matching efficiency and retain platform trust.

### SMART Objectives
1. **Specific:** Develop an interpretable multi-factor matching system that ranks available artisans on three weighted signals — spatial proximity (~0.32), historical response rate (~0.35), and rating (~0.33) — with portal-issued verification as a tie-breaker, location freshness as an eligibility filter, a fairness slot that guarantees new artisans exposure, and an integrated escrow wallet system supporting protected live bargaining and additive extra charges.
2. **Measurable:** Keep single-round ranking latency in the tens-of-milliseconds range for candidate pools up to 5,000 workers on commodity hardware, degrading gracefully to ~10,000.
3. **Achievable:** Leverage Supabase (PostgreSQL) for relational storage, atomic escrow ledgers, and Row-Level Security, Supabase PostGIS spatial queries with application-level Haversine fallback for geospatial scoring, and Express.js for dispatch scheduling and escrow payout orchestration.
4. **Relevant:** Reduce wasted dispatch effort (push notifications per successful match) relative to a proximity-only baseline by steering toward responsive workers, mitigate platform circumvention through protected phone number releases and managed escrow deposits, and quantify the resulting equity trade-off so it can be mitigated.
5. **Time-bound:** Deploy, test, and validate the end-to-end prototype across Android, iOS, and Web environments within a simulated 12-day rapid development cycle.

## 2. Detailed Methodology

### System Architecture and Data Flow
The platform is engineered using a decoupled, client-server microservices architecture designed to leverage real-time state synchronization and managed financial ledgers.
*   **Cross-Platform Client (Flutter):** Provides role-based interfaces (`ClientShell` vs. `WorkerShell`) with ambient role switching, distributed as native mobile applications (Android/iOS) and a Progressive Web App (PWA). It captures periodic geolocation via the Google Maps SDK and communicates state changes over RESTful endpoints; live updates, tracking, and live price bargaining are delivered via Supabase Realtime (PostgreSQL change events) supplemented by role-aware Firebase Cloud Messaging pushes.
*   **Web Verification Portal (React/Vite):** A dedicated administrative verification portal for onboarding artisans, reviewing Ghana Card credentials, auditing verification confidence scores, managing disputes, and resolving split-payout scenarios.
*   **Backend Server (Node.js/Express):** Handles core business operations, including spatial dispatch (`matchingService.ts`), multi-factor ranking (`recommendationEngine.ts`), real-time bargaining (`negotiationEngine.ts`), settlement calculations (`settlementService.ts`), 48-hour auto-release payout workers (`autoReleaseService.ts`), dispute management (`disputeService.ts`), wallet ledgers (`walletService.ts`), and FCM push notification routing (`notifyService.ts`).
*   **Data & Financial Layer (Supabase/PostgreSQL):** Stores relational data, manages Row Level Security (RLS) policies, and maintains atomic escrow & wallet transaction ledgers (`job_escrow_balances`, `escrow_ledger`, `user_wallets`, `wallet_transactions`). Geospatial distance scoring is performed via Supabase PostGIS spatial RPC functions (`calculate_distance_km`) with application-level Haversine formula fallback.

**Data & Financial Flow:**
1. **Job Request & Quote Discovery:** A client submits a job request with landmark-based location text (`address_label`) and coordinates. The Express backend queries active workers within a concentric radius ladder (`[5, 10, 20, 35] km`), runs the ranking algorithm, and dispatches push notifications to the top candidate cohort.
2. **Protected Price Bargaining:** Workers submit quotes or counter-offers via the in-app bargaining engine (`negotiationEngine.ts`, `NegotiationChatSheet`). Phone numbers remain hidden during bargaining to prevent off-platform circumvention.
3. **Escrow Booking Deposit:** Upon quote acceptance, a 20% escrow deposit is collected and recorded in `job_escrow_balances`. Once matched (`status >= matched`), worker contact details are revealed.
4. **Additive Extra Charges:** During job execution, artisans can propose additive extra charges (`type: 'extra_charge'`). Extra charges (+GH₵ 30) are additively calculated on top of the initial quote (GH₵ 70 $\rightarrow$ GH₵ 100 gross) via `calculateSettlement(jobId)` and presented to the client via 1-tap alert modals (`_showExtraChargeAlertModal`) and direct payment checkout buttons (`[ Pay Outstanding Balance ]`).
5. **Completion & Escrow Settlement:** Upon worker completion submission, `worker_completion_form_screen.dart` automatically prefills the gross total (`initialEscrow + totalExtra`). On client approval, the escrow ledger releases funds (90% worker payout, 10% platform fee) to the worker's wallet, or auto-releases after 48 hours if unacted upon without a dispute.

### Hardware and Software Specifications
*   **Backend Environment:** Node.js (v22.0.0+), Express.js (v5.2.1), TypeScript, Supabase Auth & Storage SDK.
*   **Frontend Environment:** Flutter SDK (>=3.22.0), Dart 3.4+, Hive local storage, Mapbox / Google Maps SDK.
*   **Web Portal:** React (18.3), Vite, Tailwind CSS, TypeScript.
*   **Infrastructure:** Supabase (PostgreSQL 15), Firebase Admin SDK for push notifications, Vercel for CI/CD Edge network deployment.

### Development Environment Setup Tutorial
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-org/artisans.git
    cd artisans
    ```
2.  **Configure the Backend:**
    ```bash
    cd artisansApp_backend
    cp .env.example .env # Insert SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PAYSTACK_SECRET_KEY
    npm install
    npm run dev
    ```
3.  **Configure the Frontend (Mobile/Web):**
    ```bash
    cd ../artisansApp_frontend
    flutter pub get
    flutter run
    ```
4.  **Configure the Web Verification Portal:**
    ```bash
    cd ../CraftMatch_Verification_Portal
    npm install
    npm run dev
    ```

### Implementation Details and Critical Algorithms
The core logic resides in the worker ranking function (`recommendationEngine.ts`). The system avoids static queues by dynamically scoring candidates on **three** weighted signals. Distance is normalised using **min–max over the live candidate pool** (not a fixed radius), so proximity is scored *relative to who is actually available*. Verification, freshness, and experience are deliberately **not** blended into the linear score: verification breaks near-ties, stale locations are filtered out before ranking, and a fairness slot guarantees a new artisan a place in the dispatch cohort. Weights (0.2730 / 0.2947 / 0.2823 / 0.1500) sum to one and reflect a multi-factor weighting formula.

```text
// Pseudocode: Multi-Factor Worker Scoring & Escrow Dispatch (as implemented)

const W_DISTANCE   = 0.2730, W_RESPONSE = 0.2947, W_RATING = 0.2823, W_RELIABILITY = 0.1500
const TIE_DELTA    = 0.02      // verification tie-breaker band
const NEW_ARTISAN_JOBS = 5   // fairness-slot threshold

function rankWorkers(workers, jobRequest, cohortSize):
    // 0. Pre-filter: exclude workers whose last location ping is stale (> 15 min) or busy
    fresh = [w in workers where isLocationFresh(w.locationTimestamp) and not isBusy(w.id)]

    // 1. Min-max distance normalisation over the candidate pool
    maxDist = max(haversine(jobRequest.location, w.location) for w in fresh)

    for each worker in fresh:
        distance       = haversine(jobRequest.location, worker.location)
        distanceScore  = (maxDist == 0) ? 1 : Max(0, 1 - distance / maxDist)
        responseScore  = clamp01(worker.responseRate)
        ratingScore    = clamp01(worker.rating / 5.0)
        reliability    = 1 - Min(1, worker.recentCancels / 5)
        worker.score   = W_DISTANCE * distanceScore
                       + W_RESPONSE * responseScore
                       + W_RATING   * ratingScore
                       + W_RELIABILITY * reliability

    // 2. Sort by score; verification level breaks near-ties (|Δscore| <= TIE_DELTA)
    ranked = sort(fresh, by = score desc, tieBreak = prefer isVerified)

    // 3. Fairness slot: ensure at least one new artisan (< NEW_ARTISAN_JOBS) is included
    return applyFairnessSlot(ranked, cohortSize)
```

The dispatch loop (`matchingService.ts`) calls this per round, notifies the top `WORKERS_PER_ROUND = 3` cohort via FCM, waits for the round timeout, and on non-acceptance **iteratively expands the search radius** through the ladder `[5, 10, 20, 35] km` for up to `MAX_ROUNDS = 3` rounds.

### Testing Methodology
A hybrid testing approach was adopted to ensure system reliability:
*   **Unit & System Testing:** Backend test suite (`npm test`) executes 28 automated integration tests covering job dispatch, scheduled activation, worker assignment locks (`one_active_worker_job_per_worker`), bargaining metadata, and atomic wallet transaction ledgers (`walletService.test.ts`).
*   **Frontend Static Analysis:** Flutter static analyzer (`flutter analyze`) enforces 0 errors across routing, live tracking gestures, modal overlays, and network API retry mechanisms.
*   **Concurrency & Database Locks:** Supabase PostgreSQL enforces transactional integrity. A worker assigned an active job is blocked from accepting simultaneous dispatches, returning an HTTP 409 Conflict (`WORKER_HAS_ACTIVE_JOB`).

## 3. Results and Performance Analysis

All results below are produced by a committed experiment harness (`artisansApp_backend/scripts/experiments/`, run via `npm run bench`); every figure is reproducible and traces to `results/RESULTS.md`. Data is seeded synthetic over a Greater-Kumasi bounding box.

### Performance Metrics
*   **Ranking latency:** `rankRecommendationCandidates` scores a 5,000-candidate pool in **tens of milliseconds** on the test machine (median ≈ 47 ms, 95% CI ±5 ms, p99 ≈ 91 ms), scaling to ≈ 112 ms median at 10,000 candidates.
*   **Assignment optimality:** Across 40 batches (30 jobs × 60 available workers), the deployed greedy per-job assignment stayed within **1.9% (95% CI ±0.2%)** of the globally optimal Hungarian (Kuhn–Munkres) batch assignment.

### Comparative Analysis
We compare three policies on **identical seeded demand streams** (300 workers, 700 jobs, 30 repetitions) via a graded baseline ladder — random → nearest-only (pure proximity) → full multi-factor model.

| Policy | Match rate | Dispatches / match | Mean match dist. | Load Gini* |
|---|---|---|---|---|
| random | 100% | 1.43 | 3.29 km | 0.48 |
| nearest-only | 100% | 1.42 | 0.81 km | 0.52 |
| **full model** | 100% | **1.18** | 1.28 km | 0.78 |

\* *Higher Gini = more concentrated (less equitable) load.*

*   **Match rate parity:** When supply is adequate every reasonable policy matches nearly all jobs.
*   **Dispatch efficiency gain:** The full model needs **~17% fewer push notifications per successful match** than the proximity-only baseline, because the response-rate signal steers dispatches toward workers who actually accept.
*   **Equity trade-off:** Optimising for responsiveness concentrates work on the most reliable artisans (Gini 0.78 vs 0.52 for proximity-only), mitigated by our explicit new-artisan fairness slot.

## 4. Strategic Discussion

### Results Interpretation & Anti-Circumvention
The evidence supports a **narrower and more honest** hypothesis than simple algorithmic matching. Under adequate supply, multi-factor ranking does not raise raw match rates; what response-rate ranking and managed escrow buy are **dispatch efficiency and platform retention**. By routing requests to responsive workers, protecting phone numbers until job matching, managing 20% booking deposits in escrow, and supporting additive extra charges (+GH₵ 30) with 1-tap checkout, the system eliminates major vectors of off-platform circumvention.

### Practical Applications and Equity Safeguards
Per ILO Recommendation No. 204, platform matching does not formalise the informal economy. What the system provides is **platform intermediation** that partially **bootstraps trust and reduces information asymmetry**: by folding portal-issued verification credentials, landmark address resolution, real-time bargaining, and location recency into a transparent ranking signal, it substitutes a legible platform signal for informal word-of-mouth referrals.

### Technical Challenges and Limitations
1.  **Hardware/Battery Constraints:** Continuous location pings drain battery on entry-level Android devices. Mitigated by using a 15-minute location freshness window (`LOCATION_STALE_MS = 15 min`) and declared service areas (`workers.service_areas`).
2.  **Network Volatility:** Intermittent connectivity required robust Flutter offline caching (`CacheStore`) and automatic session token refresh on 401 Unauthorized API responses (`api_client.dart`).
3.  **Simulated Data:** Quantitative benchmark figures derive from a seeded simulation over Greater-Kumasi coordinates. Relative policy ordering remains the robust finding.

### Future Work
Future iterations will: (a) conduct live field validation with partner artisans in Kumasi; (b) integrate Bank of Ghana licensed PSP/EMI payment gateways for open commercial launch; and (c) expand community vouching mechanisms.

## 5. Data Availability Statement
The source code — Flutter frontend (`artisansApp_frontend`), Express.js backend (`artisansApp_backend`), and React verification portal (`CraftMatch_Verification_Portal`) — is housed in the project repository. The ranking logic (`recommendationEngine.ts`), spatial dispatch (`matchingService.ts`), escrow ledger (`walletService.ts`), and unit test suite (`npm test`) are fully documented and reproducible.