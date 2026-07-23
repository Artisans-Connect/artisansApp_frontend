# Algorithmic Real-Time Matching and Verification System for On-Demand Artisan Platforms

## Abstract
**Background:** The informal artisan sector in emerging economies like Ghana suffers from significant inefficiencies, primarily driven by information asymmetry, lack of trust, and slow discovery processes. **Methods:** We engineered a distributed architecture consisting of a Flutter-based mobile client, a React-based web verification portal, and a Node.js/Express backend integrated with Supabase. Its core is an interpretable, low-compute **three-factor weighted dispatch heuristic** that fuses spatial proximity (Haversine distance, min–max normalised over the live candidate pool), a historical **response-rate** reliability signal, and aggregate rating into a single transparent score, with portal-issued verification applied as a tie-breaker, a location-freshness filter, and a fairness slot that guarantees new artisans exposure. **Results:** On a seeded discrete-event simulation over a Greater-Kumasi geography, the ranking function computes scores for 5,000 candidates in tens of milliseconds on commodity hardware. Against a graded baseline ladder (random → nearest-only → full model) on identical demand streams, the full model does **not** improve raw match rate when supply is adequate — all policies match nearly every job — but it reduces push notifications per successful match by ~17% relative to a proximity-only baseline by steering dispatches toward responsive workers. This efficiency comes at a measurable **equity cost**: optimising for responsiveness concentrates load on the most reliable workers (Gini 0.78 vs 0.52 for proximity-only), which we address with an explicit fairness safeguard. A greedy-vs-Hungarian analysis shows the deployed per-job assignment is within ~2% of the globally optimal batch assignment, justifying the low-compute heuristic. **Discussion:** The contribution is not the ranking mathematics — every component is established prior art — but the **socio-technical adaptation**: folding verification and location-freshness into a continuously-ranked, interpretable, deployable signal that partially **bootstraps trust and reduces information asymmetry** in a low-resource, mobile-first market. We frame this as platform intermediation, not formalisation of the informal economy. Future work targets field validation and learned, demand-adaptive weights.

## 1. Introduction and Problem Statement

The informal sector constitutes a substantial portion of the labor market in developing economies, yet it remains hindered by severe fragmentation. Consumers seeking skilled artisans (e.g., plumbers, electricians, carpenters) typically rely on word-of-mouth referrals or static directories. This traditional approach yields suboptimal experiences characterized by opaque pricing, unverifiable skill levels, and high latency in service fulfillment.

### Scientific Problem Statement
Current digital solutions for the informal artisan economy fail to adequately balance real-time spatial proximity with verifiable quality metrics. This knowledge gap results in either high-latency discovery processes or suboptimal worker allocations, necessitating an algorithmic approach that continuously synthesizes location freshness, historical performance, and verified credentials to optimize matching efficiency.

### SMART Objectives
1. **Specific:** Develop an interpretable multi-factor matching system that ranks available artisans on three weighted signals — spatial proximity (~0.32), historical response rate (~0.35), and rating (~0.33) — with portal-issued verification as a tie-breaker, location freshness as an eligibility filter, and a fairness slot that guarantees new artisans exposure.
2. **Measurable:** Keep single-round ranking latency in the tens-of-milliseconds range for candidate pools up to 5,000 workers on commodity hardware, degrading gracefully to ~10,000.
3. **Achievable:** Leverage Supabase (PostgreSQL) for relational storage and Row-Level Security, application-level Haversine distance for geospatial scoring, and Express.js for dispatch scheduling.
4. **Relevant:** Reduce wasted dispatch effort (push notifications per successful match) relative to a proximity-only baseline by steering toward responsive workers, and quantify the resulting equity trade-off so it can be mitigated — rather than claiming an inflated match-rate improvement.
5. **Time-bound:** Deploy, test, and validate the end-to-end prototype across Android, iOS, and Web environments within a simulated 12-day rapid development cycle.

## 2. Detailed Methodology

### System Architecture and Data Flow
The platform is engineered using a decoupled, client-server microservices architecture designed to leverage real-time state synchronization.
*   **Mobile Client (Flutter):** Provides role-based interfaces (Client vs. Worker). It captures periodic geolocation via the Google Maps SDK and communicates state changes over RESTful endpoints; live updates are delivered by polling and Firebase Cloud Messaging pushes rather than persistent WebSocket streams.
*   **Web Portal (React/Vite):** A dedicated administrative verification portal for onboarding artisans and reviewing credentials, interacting directly with the backend.
*   **Backend Server (Node.js/Express):** Handles the core business logic, including the `matchingService` (dispatch orchestration + `recommendationEngine` ranking) and notification dispatch via Firebase Cloud Messaging.
*   **Data Layer (Supabase/PostgreSQL):** Stores relational data and manages Row Level Security (RLS) policies. Geospatial scoring is performed in application code via the Haversine formula; the system does not use PostGIS geospatial indexing.

**Data Flow:** A client submits a job request with geographic coordinates. The Express backend receives the payload, queries PostgreSQL for active workers within an initial radius, and runs the ranking algorithm. The system dispatches Firebase push notifications to the top-ranked cohort and initiates a dispatch timeout. If unaccepted, the system iteratively expands the search radius in subsequent rounds.

### Hardware and Software Specifications
*   **Backend Environment:** Node.js (v22.0.0+), Express.js (v5.2.1), TypeScript.
*   **Frontend Environment:** Flutter SDK (>=3.1.1 <4.0.0), Dart.
*   **Web Portal:** React (18.3), Vite, Tailwind CSS.
*   **Infrastructure:** Supabase (PostgreSQL 15), Firebase Admin SDK for push notifications.

### Development Environment Setup Tutorial
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-org/artisans.git
    cd artisans
    ```
2.  **Configure the Backend:**
    ```bash
    cd artisansApp_backend
    cp .env.example .env # Insert SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
    npm install
    npm run dev
    ```
3.  **Configure the Frontend (Mobile):**
    ```bash
    cd ../artisansApp_frontend
    flutter pub get
    # Add google-services.json and Google Maps API keys to native directories
    flutter run
    ```
4.  **Configure the Web Portal:**
    ```bash
    cd ../artisans_verification_portal
    npm install
    npm run dev
    ```

### Implementation Details and Critical Algorithms
The core logic resides in the worker ranking function (`recommendationEngine.ts`). The system avoids static queues by dynamically scoring candidates on **three** weighted signals. Distance is normalised using **min–max over the live candidate pool** (not a fixed radius), so proximity is scored *relative to who is actually available*. Verification, freshness, and experience are deliberately **not** blended into the linear score: verification breaks near-ties, stale locations are filtered out before ranking, and a fairness slot guarantees a new artisan a place in the dispatch cohort. Weights (0.3212 / 0.3467 / 0.3321) sum to one and are near-uniform by design, reflecting a deliberate low-resource choice to keep the model interpretable rather than tuned.

```text
// Pseudocode: Three-Factor Worker Scoring (as implemented)

const W_DISTANCE = 0.3212, W_RESPONSE = 0.3467, W_RATING = 0.3321
const TIE_DELTA  = 0.02      // verification tie-breaker band
const NEW_ARTISAN_JOBS = 5   // fairness-slot threshold

function rankWorkers(workers, jobRequest, cohortSize):
    // 0. Pre-filter: exclude workers whose last location ping is stale
    fresh = [w in workers where isLocationFresh(w.locationTimestamp)]

    // 1. Min-max distance normalisation over the *candidate pool*
    maxDist = max(haversine(jobRequest.location, w.location) for w in fresh)

    for each worker in fresh:
        distance      = haversine(jobRequest.location, worker.location)
        distanceScore = (maxDist == 0) ? 1 : Max(0, 1 - distance / maxDist)
        responseScore = clamp01(worker.responseRate)          // reliability
        ratingScore   = clamp01(worker.rating / 5.0)
        worker.score  = W_DISTANCE * distanceScore
                      + W_RESPONSE * responseScore
                      + W_RATING   * ratingScore

    // 2. Sort by score; verification breaks near-ties (|Δscore| <= TIE_DELTA)
    ranked = sort(fresh, by = score desc, tieBreak = prefer isVerified)

    // 3. Fairness slot: ensure a new artisan (< NEW_ARTISAN_JOBS) is included
    return applyFairnessSlot(ranked, cohortSize)
```

The dispatch loop (`matchingService.ts`) calls this per round, notifies the top `WORKERS_PER_ROUND = 3` cohort via FCM, waits for the round timeout, and on non-acceptance **iteratively expands the search radius** through the ladder `[5, 10, 15, 25] km` for up to `MAX_ROUNDS = 3` rounds.

### Testing Methodology
A hybrid testing approach was adopted to ensure system reliability:
*   **Unit Testing:** Flutter widget tests `artisansApp_frontend/test/` validated UI state transitions and local caching mechanisms using **hive**.
*   **Integration Testing:** Automated workflows tested the end-to-end job dispatch lifecycle: `Job Post -> Matching -> Worker Accept -> Client Tracking -> Job Complete`.
*   **Sample Test Case (Concurrency):** 
    *   *Scenario:* Two highly ranked workers attempt to accept the same job payload simultaneously.
    *   *Expected Result:* The Supabase PostgreSQL database enforces transactional integrity; the first worker is assigned the job, and the second worker receives an "Already Accepted" HTTP 409 Conflict response.

## 3. Results and Performance Analysis

All results below are produced by a committed, seeded experiment harness
(`artisansApp_backend/scripts/experiments/`, run via `npm run bench`); every
figure is reproducible and traces to `results/RESULTS.md`. Data is seeded
synthetic over a Greater-Kumasi bounding box — **not** field measurements (see
Limitations). Metrics are behavioural and deliberately avoid any circular
"satisfaction" score derived from the same proximity/rating signals the model
optimises.

### Performance Metrics
*   **Ranking latency:** `rankRecommendationCandidates` scores a 5,000-candidate pool in **tens of milliseconds** on the test machine (median ≈ 47 ms, 95% CI ±5 ms, p99 ≈ 91 ms; hardware- and JIT-dependent), scaling to ≈ 112 ms median at 10,000 candidates. This replaces the previously reported, unbenchmarked "142 ms" figure.
*   **Assignment optimality:** Across 40 batches (30 jobs × 60 available workers), the deployed greedy per-job assignment stayed within **1.9% (95% CI ±0.2%)** of the globally optimal Hungarian (Kuhn–Munkres) batch assignment — the low-compute heuristic sacrifices very little optimality.

### Comparative Analysis
We compare three policies on **identical seeded demand streams** (300 workers, 700 jobs, 30 repetitions) via a graded baseline ladder — random → nearest-only (pure proximity) → full three-factor model — rather than against a single strawman broadcast baseline.

| Policy | Match rate | Dispatches / match | Mean match dist. | Load Gini* |
|---|---|---|---|---|
| random | 100% | 1.43 | 3.29 km | 0.48 |
| nearest-only | 100% | 1.42 | 0.81 km | 0.52 |
| **full model** | 100% | **1.18** | 1.28 km | 0.78 |

\* *Higher Gini = more concentrated (less equitable) load.*

*   **Match rate is parity, not a gain.** When supply is adequate every reasonable policy matches nearly all jobs; the inflated "68% higher match rate / 45% lower wait" claims are **not supported** and have been removed.
*   **Dispatch efficiency is the genuine, defensible effect:** the full model needs **~17% fewer push notifications per successful match** than the proximity-only baseline, because the response-rate signal steers dispatches toward workers who actually accept.
*   **Equity trade-off (reported, not hidden):** optimising for responsiveness concentrates work on the most reliable artisans (Gini 0.78 vs 0.52 for proximity-only). The new-artisan fairness slot secures exposure but does not equalise load — motivating the safeguard discussed in §4.

### Weight Sensitivity and Ablations
A ±20% one-at-a-time perturbation of each weight moves only **9–16%** of the top-3 cohort, indicating the exact (near-uniform) weights are **not fragile**. Full ablations confirm every signal is load-bearing: removing distance, response-rate, or rating churns the top-3 cohort by **79%, 72%, and 54%** respectively.

## 4. Strategic Discussion

### Results Interpretation
The evidence supports a **narrower and more honest** hypothesis than "algorithmic matching is vastly superior." Under adequate supply, multi-factor ranking does not raise the match rate — a simple proximity broadcast already matches nearly every job. What the response-rate signal genuinely buys is **dispatch efficiency**: by routing requests to workers who historically accept, and by excluding stale locations through a pre-ranking freshness filter (an eligibility gate, not a weighted term), the system reduces wasted push notifications per match by ~17% relative to proximity-only dispatch. This is the defensible core result. It carries a cost the evaluation makes explicit: responsiveness-optimisation concentrates work on the most reliable artisans, so equity must be engineered in rather than assumed.

### Practical Applications and Equity Safeguards
We are careful **not** to overclaim that this architecture *formalises* the informal economy. Per ILO Recommendation No. 204, formalisation entails legal status, social protection, and tax inclusion — none of which a matching platform confers. What the system provides is **platform intermediation** that partially **bootstraps trust and reduces information asymmetry**: by folding a portal-issued verification credential and location recency into a transparent, real-time ranking signal, it substitutes a legible platform signal for the word-of-mouth reputation that low-resource markets otherwise depend on. Because the same optimisation concentrates load (§3, Gini 0.78 vs 0.52), a deployable version must include an **equity safeguard** — e.g. tiered verification that never hard-excludes unverified artisans, and rotation/exploration that periodically surfaces lower-ranked and newer workers beyond the single fairness slot. The paradigm generalises to other localized gig verticals (courier, on-demand tutoring), subject to the same equity caveat.

### Related Work and Positioning
The individual ingredients are **established prior art**, and we position the contribution accordingly. Weighted multi-factor dispatch with timeout-driven radius expansion is the textbook ride-hailing architecture (e.g. Uber dispatch patent US20170011324A1; CoRide frames dispatch as a learned "ranking weight vector", arXiv:1905.11353). GPS-recency pre-selection and verified-worker gating are likewise standard on platforms such as SafeBoda and Lynk/Fundi, and batch assignment is well studied as bipartite matching (Kuhn–Munkres; PVLDB work on real-world bipartite matching). Our claim is therefore **not** algorithmic novelty but **contextual adaptation**: an interpretable, low-compute heuristic that treats verification and freshness as first-class, continuously-applied dispatch signals for stationary, credential-bearing artisans in a mobile-first emerging market — a design defensible on deployability and transparency rather than optimality.

### Technical Challenges and Limitations
1.  **Hardware/Battery Constraints:** Continuous geolocation tracking on low-end Android devices (common in emerging markets) leads to severe battery degradation. We mitigated this by utilizing Flutter's *geolocator* with variable accuracy depending on the app's lifecycle state.
2.  **Network Volatility:** Intermittent connectivity necessitated robust offline-first UI handling and optimistic state updates.
3.  **Simulated data (primary threat to validity):** All quantitative results derive from a **seeded synthetic simulation**, not field deployment. Absolute figures depend on the generative assumptions — the accept-probability distribution, supply/demand ratio, and freshness rate — so the **relative ordering of policies** (not the absolute numbers) is the robust finding. Real-world artisan clustering, correlated demand, and behavioural responses to being ranked are unmodelled. Field validation with live dispatch logs is required before any causal efficiency claim is made.
4.  **Metric design:** We report behavioural, non-circular metrics (match rate, dispatches-per-match, realised travel distance, load Gini) precisely because a proximity+rating "satisfaction" score would be circular — optimised by the very signals it purports to measure (a Goodhart's-law risk).

### Future Work
Future iterations should (a) validate against real dispatch logs; (b) learn demand-adaptive weights (e.g. raising proximity weight during peak urban backlogs) while preserving interpretability; and (c) strengthen the equity safeguard with exploration/rotation policies. Event-streaming infrastructure (e.g. Kafka) would matter only at a scale this prototype does not target.

## 5. Data Availability Statement
The source code — Flutter frontend, Express.js backend, and React verification portal — is housed in a private repository. The ranking logic (`recommendationEngine.ts`), the dispatch orchestration (`matchingService.ts`), and the **reproducible experiment harness** (`scripts/experiments/`, run via `npm run bench`, which regenerates every figure in §3 into `results/RESULTS.md`) are documented within the project. Access to the codebase or the seeded simulation datasets can be provided upon reasonable academic request.