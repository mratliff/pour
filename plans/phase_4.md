# Phase 4: Ratings & Reviews

## Context

You are working on Georgetown Pour, a Phoenix 1.8 + Ecto community wine-tasting app. Phases 1-3 are complete:

- Role-based access control with admin approval
- Tasting events with RSVP and private locations
- Orders with shop dashboard and consolidated view
- Wine catalog with images

**IMPORTANT:** Before starting, read these files to understand current state:
- `lib/pour/catalog/wine.ex` — wine schema
- `lib/pour_web/live/wine_live/show.ex` or wherever wine detail is displayed
- `lib/pour_web/live/tasting_live/show.ex` — tasting detail page
- `lib/pour_web/router.ex` — current route structure

## Objective

Members can rate (1-5 stars) and review wines. One review per user per wine. Reviews display on wine detail pages with average ratings.

## Tasks

### 1. Migration

Create `reviews` table:
```
- id: binary_id (PK)
- user_id: references users, type: binary_id, not null, on_delete: delete_all
- wine_id: references wines, type: binary_id, not null, on_delete: delete_all
- tasting_id: references tastings, type: binary_id, nullable
  (optional link to which tasting they tried it at)
- rating: integer, not null (1-5)
- body: text, nullable (review text is optional, rating is required)
- inserted_at, updated_at: utc_datetime
- unique index on [user_id, wine_id]
```

### 2. Create Schema

**`lib/pour/reviews/review.ex`:**
- Fields: rating, body
- belongs_to :user, :wine, :tasting (tasting is optional)
- Changeset: validate rating is integer between 1 and 5
- Changeset: validate body length (max 2000 chars if provided)

### 3. Create Reviews Context

**`lib/pour/reviews.ex`:**

Functions:
- `create_or_update_review/2` — takes scope (user) and attrs. Uses upsert behavior:
  - If user already has a review for this wine, update it
  - Otherwise, create a new one
  - This prevents duplicate reviews cleanly
- `get_user_review/2` — takes user_id and wine_id, returns review or nil
- `list_reviews_for_wine/1` — takes wine_id, returns reviews ordered by inserted_at desc, preload user (just email/name)
- `average_rating/1` — takes wine_id, returns average rating as float (or nil if no reviews)
- `review_count/1` — takes wine_id, returns count
- `wine_rating_summary/1` — takes wine_id, returns `%{average: 4.2, count: 15}` in one query
- `delete_review/2` — takes scope (user) and review, ensures user owns the review

### 4. Add Review Component

Create a reusable review component (either in core_components or a new module):

**Star rating display component:**
- Takes a rating (1-5) and renders filled/empty stars
- Used for both display and input

**Review form component:**
- Star rating input (clickable stars using JS hook or radio buttons styled as stars)
- Optional text body
- Submit button

**Review list component:**
- Renders a list of reviews with: star rating, body text, reviewer (email or "Anonymous"), date
- Shows "No reviews yet" if empty

### 5. Update Wine Detail Page

In the wine detail page (check whether this is `lib/pour_web/live/wine_live/show.ex` or shown inline on tasting pages):

- Display average rating and review count near the wine title
- Show list of reviews below wine details
- If user is logged in and approved:
  - Show review form
  - If user already reviewed this wine, pre-fill the form for editing
- If user is not logged in, show "Log in to leave a review"

### 6. Add Review from Tasting Page (Optional Enhancement)

On `lib/pour_web/live/tasting_live/show.ex`:
- For each wine in the tasting, show a small "Rate this wine" link or inline star selector
- When clicked, either:
  - Opens a modal with the full review form, OR
  - Links to the wine detail page with the review form

This makes it easy for members to review wines right after a tasting.

### 7. Update Router

If wine show pages need new routes for review actions, add them. Most likely the review form will be handled inline via LiveView events (handle_event), so no new routes may be needed.

If you do need routes:
```elixir
# Inside approved member live_session
live "/wines/:id/review", WineLive.Review, :new
```

## Acceptance Criteria

- [ ] Members can rate wines 1-5 stars
- [ ] Members can optionally write review text
- [ ] One review per user per wine (editing updates, not duplicates)
- [ ] Average rating and review count displayed on wine detail
- [ ] Reviews listed on wine detail page
- [ ] Star rating renders visually (filled/empty stars)
- [ ] Review form pre-fills if user already reviewed the wine
- [ ] Only approved members can leave reviews
- [ ] Unauthenticated users see "Log in to review"
- [ ] `mix test` passes
- [ ] `mix compile --warnings-as-errors` is clean

## Status Report

When complete, provide:
1. List of all files created or modified
2. Migration file names with timestamps
3. How the upsert/edit behavior works
4. How star rating input was implemented (JS hook vs pure HTML)
5. Any issues encountered or assumptions made
6. Confirm compilation and tests pass
