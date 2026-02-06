# Phase 2: Tasting Events, RSVP & Wine Images

## Context

You are working on Georgetown Pour, a Phoenix 1.8 + Ecto community wine-tasting app. Phase 1 has been completed — the app now has:

- Role-based access control (admin, member, shop)
- Admin approval workflow for new registrations
- Admin user management at `/admin/users`
- Route scoping: `/admin/*` for admins, `/shop/*` for shop, member routes require approval
- Existing wine catalog with full CRUD under `/admin/wines`

**IMPORTANT:** Before starting, read these files to understand current state:
- `lib/pour_web/router.ex` — current route structure
- `lib/pour_web/user_auth.ex` — on_mount hooks
- `lib/pour/accounts/user.ex` — user schema with role and approved fields
- `lib/pour/catalog/wine.ex` — wine schema

## Objective

Build tasting events where admins group wines into tastings, members can RSVP, and confirmed attendees receive the private location. Also add wine image uploads.

**CRITICAL: Tasting locations are PRIVATE.** They must never appear on public pages. Location is only shown to confirmed attendees (RSVP status = "attending") and sent via email on RSVP confirmation.

## Tasks

### 1. Add dependencies

In `mix.exs`, add:
```elixir
{:ex_aws, "~> 2.5"},
{:ex_aws_s3, "~> 2.5"},
{:sweet_xml, "~> 0.7"},  # required by ex_aws
```

Run `mix deps.get` after.

### 2. Migrations

Create these migrations (in order):

**a) Create tastings table:**
```
- id: binary_id (PK)
- title: string, not null
- description: text
- date: utc_datetime
- location: string (PRIVATE — never exposed publicly)
- status: string, default "upcoming", not null
  (values: "upcoming", "active", "closed")
- inserted_at, updated_at: utc_datetime
```

**b) Create tasting_wines join table:**
```
- id: binary_id (PK)
- tasting_id: references tastings, type: binary_id, not null, on_delete: delete_all
- wine_id: references wines, type: binary_id, not null, on_delete: delete_all
- sort_order: integer, default 0
- unique index on [tasting_id, wine_id]
```

**c) Create rsvps table:**
```
- id: binary_id (PK)
- user_id: references users, not null, on_delete: delete_all
- tasting_id: references tastings, not null, on_delete: delete_all
- status: string, default "attending", not null
  (values: "attending", "maybe", "declined")
- inserted_at, updated_at: utc_datetime
- unique index on [user_id, tasting_id]
```

**d) Add image_url to wines:**
```
- add :image_url, :string, to wines table
```

### 3. Create Schemas

**`lib/pour/events/tasting.ex`:**
- Fields: title, description, date, location, status
- has_many :tasting_wines
- has_many :wines, through: [:tasting_wines, :wine]
- has_many :rsvps
- Changesets: create_changeset, update_changeset, status_changeset

**`lib/pour/events/tasting_wine.ex`:**
- Fields: sort_order
- belongs_to :tasting, :wine

**`lib/pour/events/rsvp.ex`:**
- Fields: status
- belongs_to :user, :tasting
- Changeset validates status is one of ["attending", "maybe", "declined"]

### 4. Create Events Context

**`lib/pour/events.ex`:**

Functions:
- `list_upcoming_tastings/0` — tastings where status in ["upcoming", "active"], ordered by date. **Do NOT preload location.** Use `select` to exclude it, OR have a separate function for public vs private views.
- `list_all_tastings/0` — admin view, all tastings with full data
- `get_tasting!/1` — get tasting by id, preload wines and rsvps
- `get_tasting_public!/1` — get tasting WITHOUT location, preload wines
- `get_tasting_for_attendee!/2` — get tasting WITH location only if user has RSVP status "attending"
- `create_tasting/1` — create with changeset
- `update_tasting/2` — update with changeset
- `delete_tasting/1`
- `add_wine_to_tasting/2` — create tasting_wine association
- `remove_wine_from_tasting/2`
- `rsvp_to_tasting/2` — create or update RSVP (upsert). If status is "attending", send email with location.
- `cancel_rsvp/2` — update RSVP status to "declined"
- `get_user_rsvp/2` — get RSVP for a user+tasting
- `list_attendees/1` — list users with "attending" RSVP for a tasting
- `notify_new_tasting/1` — send email to all approved members about new tasting

### 5. Create Email Functions

Add to `lib/pour/accounts/user_notifier.ex` (or create `lib/pour/events/notifier.ex`):

- `deliver_new_tasting_notification/2` — takes user and tasting, sends email about upcoming tasting (NO location in this email)
- `deliver_rsvp_confirmation/3` — takes user, tasting, and location. Sends confirmation with the private location details.
- `deliver_tasting_reminder/3` — (optional, can stub) reminder email before event

### 6. Update Wine Schema

In `lib/pour/catalog/wine.ex`:
- Add `field :image_url, :string`
- Update changeset to cast image_url

### 7. S3 Upload Helper

Create `lib/pour/uploads.ex`:
- `upload_to_s3/2` — takes file binary + filename, uploads to S3 bucket, returns URL
- `delete_from_s3/1` — takes URL, deletes object
- Configure S3 bucket name from application config

Add to `config/dev.exs`:
```elixir
config :ex_aws,
  access_key_id: "minioadmin",
  secret_access_key: "minioadmin",
  region: "us-east-1"

config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 9000

config :pour, :s3_bucket, "pour-dev"
```

Add to `config/runtime.exs` (inside `if config_env() == :prod`):
```elixir
config :ex_aws,
  access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY"),
  region: System.get_env("AWS_REGION", "us-east-1")

config :pour, :s3_bucket, System.fetch_env!("S3_BUCKET")
```

### 8. Admin LiveViews for Tastings

**`lib/pour_web/live/admin_live/tasting_live/index.ex`:**
- List all tastings with status, date, wine count, RSVP count
- Links to create new, edit, view details
- Status badge (upcoming/active/closed)

**`lib/pour_web/live/admin_live/tasting_live/form.ex`:**
- Create/edit tasting: title, description, date, location, status
- Wine selection: multi-select or checkbox list of available wines
- On create, trigger email notification to all approved members

**`lib/pour_web/live/admin_live/tasting_live/show.ex`:**
- Full tasting details including location (admin can see it)
- List of wines in the tasting
- List of RSVPs with attendee names and statuses
- Admin can manually add an RSVP for a user (for email/phone registrations)

### 9. Public/Member Tasting LiveViews

**`lib/pour_web/live/tasting_live/index.ex`:**
- List upcoming and active tastings
- Show: title, description, date, wine count
- **NO location displayed**
- Link to detail page

**`lib/pour_web/live/tasting_live/show.ex`:**
- Tasting detail: title, description, date, wines with details
- **Location ONLY shown if user has "attending" RSVP**
- RSVP buttons: "I'll be there" / "Maybe" / "Can't make it"
- If already RSVP'd, show current status with option to change
- Wine cards showing name, region, varietal, vintage, price, image

### 10. Wine Image Upload in Admin

Update `lib/pour_web/live/admin_live/wine_live/form.ex` (or wherever wine form is):
- Add LiveView file upload using `allow_upload/3`
- On save, upload to S3, store URL in wine.image_url
- Show image preview if image_url exists
- Accept jpg, png, webp; max 5MB

### 11. Update Router

Add to admin live_session in `lib/pour_web/router.ex`:
```elixir
# Inside admin live_session
live "/admin/tastings", AdminLive.TastingLive.Index, :index
live "/admin/tastings/new", AdminLive.TastingLive.Form, :new
live "/admin/tastings/:id", AdminLive.TastingLive.Show, :show
live "/admin/tastings/:id/edit", AdminLive.TastingLive.Form, :edit
```

Add to approved member live_session:
```elixir
# Inside approved member live_session
live "/tastings", TastingLive.Index, :index
live "/tastings/:id", TastingLive.Show, :show
```

## Acceptance Criteria

- [ ] Admin can create tastings with title, description, date, location, and select wines
- [ ] Creating a tasting sends email notification to all approved members (visible at /dev/mailbox)
- [ ] Members see upcoming tastings at /tastings (WITHOUT location)
- [ ] Members can RSVP to a tasting
- [ ] After RSVP "attending", member can see the location on the tasting detail page
- [ ] RSVP confirmation email includes the private location
- [ ] Admin can view all RSVPs and manually add RSVPs for users
- [ ] Wine images can be uploaded via admin wine form
- [ ] Wine images display on wine cards in tasting detail
- [ ] S3 upload config is in place (dev can use local/minio, prod uses env vars)
- [ ] `mix test` passes
- [ ] `mix compile --warnings-as-errors` is clean

## Status Report

When complete, provide:
1. List of all files created or modified
2. Migration file names with timestamps
3. Any dependencies added
4. Any issues encountered or assumptions made
5. How S3 uploads were implemented (library, config)
6. Confirm compilation and tests pass
