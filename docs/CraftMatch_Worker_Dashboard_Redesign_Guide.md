# CraftMatch Worker Dashboard Redesign Specification

## Objective
Transform the Job Requests screen from a passive empty state into an engaging dashboard.

## Layout
- App Bar (Job Requests + optional notifications)
- Greeting ("Good Morning 👋")
- Availability Card
- Nearby Activity Card
- Search Status
- Primary Action Button
- Today's Statistics
- Recent Activity
- Tip of the Day
- Bottom Navigation

## Greeting
Headline: Good Morning 👋
Subtitle: Ready to find your next job?

## Availability Card
Online:
- Green indicator
- You're Online
- Ready to receive nearby jobs.

Offline:
- Grey indicator
- You're Offline
- Turn availability on to receive nearby requests.

## Nearby Activity
Display:
- Search radius (8 km)
- Skill match
- Distance match
- Availability match

## Search Status
Replace the empty illustration with an animated search/radar icon.

Heading:
Looking for nearby clients...

Body:
We'll instantly notify you when a matching client posts a request.

Optional:
Average wait ≈ 4 minutes.

## Primary Button
Text:
- Search Again
or
- Refresh Search

Behaviour:
- Disable while loading.
- Show spinner.
- Trigger nearby search.

## Today's Stats
- Jobs completed
- Requests received
- Acceptance rate
- Average response time
- Rating

## Recent Activity
Examples:
- Plumbing request accepted
- Carpentry request expired
- Electrical booking completed

## Tip of the Day
Example:
Workers who respond quickly usually receive more bookings.

## Visual Improvements
- Rounded cards
- Soft shadows
- Consistent spacing
- Subtle map/grid background
- Smooth fade animations

## Expected Flow
1. Worker opens screen.
2. Greeting shown.
3. Toggle Online.
4. Nearby activity updates.
5. Search starts.
6. Job card appears.
7. Worker accepts or declines.
