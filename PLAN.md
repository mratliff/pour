# Georgetown Pour — Architecture & Execution Plan

## Project Summary

Community wine-tasting group app. Members register (admin-approved), browse curated wine batches tied to tasting events, RSVP, place orders (fulfilled by a local shop), and leave ratings/reviews. Admins curate wines and publish a tagged blog. The shop manages and views consolidated orders.

**Stack:** Elixir, Phoenix 1.8, Ecto, PostgreSQL, LiveView, Tailwind, DaisyUI
**Deploy:** Fly.io
**Auth:** Existing email/password + magic link system (already built)

---

## Key Decisions

- **No Ash Framework** — staying with plain Ecto contexts. Project is already well-structured.
- **Tasting location is PRIVATE** — not shown publicly. Only revealed to confirmed attendees via email and on-screen after RSVP.
- **Email notifications** — new tastings, RSVP confirmations (with location), order ready for pickup, account approved.
- **Wine images** — file uploads stored on S3-compatible storage (Tigris on Fly.io or AWS S3).
- **Blog** — Markdown-based, one-way publishing, tagged categories, no comments.
- **First admin** — created via seed script.
- **No CAPTCHA** — admin approval is the anti-bot gate.

---

## Existing Codebase Inventory

### Schemas (already built)
| Schema | File | Key Fields |
|--------|------|------------|
| User | `lib/pour/accounts/user.ex` | email, hashed_password, confirmed_at (NOTE: `role` column exists in DB but NOT in schema) |
| UserToken | `lib/pour/accounts/user_token.ex` | token, context, sent_to |
| Wine | `lib/pour/catalog/wine.ex` | name, description, price, local_price, views, available, vintage_id, region_id, sub_region_id, country_id |
| WineVarietals | `lib/pour/catalog/wine_varietals.ex` | wine_id, varietal_id |
| Country | `lib/pour/wine_regions/country.ex` | name |
| Region | `lib/pour/wine_regions/region.ex` | name, country_id |
| Subregion | `lib/pour/wine_regions/subregion.ex` | name, region_id |
| Varietal | `lib/pour/varietals/varietal.ex` | name |
| Vintage | `lib/pour/vintages/vintage.ex` | year |
| Cart | `lib/pour/shopping_cart/cart.ex` | user_id |
| CartItem | `lib/pour/shopping_cart/cart_item.ex` | cart_id, wine_id, price_when_carted, quantity |

### Context Modules (already built)
| Context | File | Purpose |
|---------|------|---------|
| Accounts | `lib/pour/accounts.ex` | User CRUD, auth, sessions, tokens |
| Catalog | `lib/pour/catalog.ex` | Wine CRUD, list current lot, view counting |
| ShoppingCart | `lib/pour/shopping_cart.ex` | Cart CRUD, add/remove items, pubsub |
| WineRegions | `lib/pour/wine_regions.ex` | Country/Region/Subregion CRUD |
| Varietals | `lib/pour/varietals.ex` | Varietal CRUD |
| Vintages | `lib/pour/vintages.ex` | Vintage CRUD |

### Key Architecture Notes
- `register_user/1` in Accounts uses `email_changeset` only — email-only registration with magic link
- `PourWeb.UserAuth` has `on_mount` hooks: `:mount_current_scope`, `:require_authenticated`, `:require_sudo_mode`, `:load_cart`
- Router uses `Scope` from `Pour.Accounts.Scope` for user context
- Shopping cart uses PubSub for real-time notifications
- `role` DB column exists (added in migration `20250409143432`) but `User` schema does NOT declare it

### Migrations (14 total)
Last: `20250412172722` — wine_varietals join table

---

## Phase Breakdown

### Phase 1: Roles, Approval & Access Control
Foundation — everything depends on knowing who can do what.

### Phase 2: Tasting Events, RSVP & Wine Images
Core concept — wines grouped into tastings, location private, email notifications.

### Phase 3: Orders & Shop Dashboard
Cart→order conversion, status tracking, shop consolidated view, fix cart totals.

### Phase 4: Ratings & Reviews
Members rate and review wines. One review per user per wine.

### Phase 5: Blog & Tags
Admin publishes Markdown blog posts with categories/tags.

### Phase 6: Fly.io Deployment
Production deploy with S3, email provider, and migration runner.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Phoenix 1.8 is RC | Already committed — pin version, watch for breaking changes |
| Cart→Order conversion could lose data | Use DB transaction, snapshot prices at order time |
| Role enforcement gaps | Add on_mount hooks at router level, not per-page |
| Blog rich text XSS | Render Markdown server-side with earmark, sanitize output |
| Private location leak | Never include location in public queries; only in attendee-scoped queries and emails |
| Image uploads on ephemeral Fly storage | Use S3-compatible external storage (Tigris or AWS S3) |
