# Phase 1: Roles, Approval & Access Control

## Context

You are working on a Phoenix 1.8 + Ecto app called Georgetown Pour (a community wine-tasting group site) located at the project root. The app already has:

- Full authentication system with email/magic link login (`lib/pour_web/user_auth.ex`)
- User schema at `lib/pour/accounts/user.ex` with fields: email, hashed_password, confirmed_at
- Accounts context at `lib/pour/accounts.ex` with registration, login, session management
- **IMPORTANT:** A `role` column already exists in the `users` table (migration `20250409143432`) but the `User` schema does NOT declare it as a field. You must add it to the schema.
- Router at `lib/pour_web/router.ex` with browser pipeline, auth routes, and authenticated routes
- Wine catalog, shopping cart, and related CRUD already built

## Objective

Lock down the app with role-based access control and an admin approval workflow for new registrations. Three roles: `admin`, `member`, `shop`.

## Tasks

### 1. Migration: Add approval fields to users

Create a new migration that adds:
- `approved` — boolean, default `false`, not null
- `approved_at` — utc_datetime, nullable

File: `priv/repo/migrations/TIMESTAMP_add_approval_to_users.exs`

### 2. Update User schema

In `lib/pour/accounts/user.ex`:
- Add `field :role, :string, default: "member"` (column already exists in DB)
- Add `field :approved, :boolean, default: false`
- Add `field :approved_at, :utc_datetime`
- Add an `approval_changeset/2` that casts approved and sets approved_at when approved becomes true
- Update `email_changeset` to ensure new users get `role: "member"` and `approved: false` defaults via the schema defaults (no changeset changes needed since schema defaults handle it)

### 3. Update Accounts context

In `lib/pour/accounts.ex`, add these functions:
- `list_users/0` — returns all users ordered by inserted_at desc
- `list_pending_users/0` — returns users where `approved == false`, ordered by inserted_at
- `approve_user/1` — sets `approved: true` and `approved_at: DateTime.utc_now()`, sends approval email
- `reject_user/1` — deletes the user and their tokens
- `update_user_role/2` — updates a user's role (admin only action)
- `user_approved?/1` — returns boolean

### 4. Create email notification module

Create `lib/pour/accounts/emails.ex` (or add to existing `UserNotifier`):
- `deliver_approval_notification/1` — sends email to user telling them their account has been approved
- Use `Swoosh` via the existing `Pour.Mailer` module
- In dev, emails will be visible at `/dev/mailbox`

### 5. Update UserAuth with role & approval hooks

In `lib/pour_web/user_auth.ex`, add new `on_mount` callbacks:

```elixir
def on_mount(:require_approved, _params, session, socket)
  # mount_current_scope, then check user.approved == true
  # If not approved, redirect to /pending-approval

def on_mount(:require_admin, _params, session, socket)
  # mount_current_scope, then check user.role == "admin"
  # If not admin, redirect to / with flash "Not authorized"

def on_mount(:require_shop, _params, session, socket)
  # mount_current_scope, then check user.role == "shop"
  # If not shop, redirect to / with flash "Not authorized"
```

Also add a plug for non-LiveView routes:

```elixir
def require_approved_user(conn, _opts)
  # Check conn.assigns.current_scope.user.approved
  # If not, redirect to /pending-approval

def require_admin_user(conn, _opts)
  # Check conn.assigns.current_scope.user.role == "admin"
```

### 6. Create Pending Approval page

Create `lib/pour_web/live/pending_live/index.ex`:
- Simple page saying "Your account is pending approval. You'll receive an email when approved."
- Shown to authenticated but unapproved users
- Include a logout link

### 7. Create Admin User Management page

Create `lib/pour_web/live/admin_live/users.ex`:
- Lists all users with columns: email, role, approved status, registered date
- "Approve" button for pending users
- "Reject" button for pending users (with confirmation)
- Role dropdown to change user roles (admin, member, shop)
- Only accessible by admin role

### 8. Update Router

In `lib/pour_web/router.ex`, restructure routes:

```elixir
# Public routes (no auth required)
scope "/", PourWeb do
  pipe_through :browser
  live "/", HomeLive.Index, :index
end

# Pending approval page (authenticated but not necessarily approved)
scope "/", PourWeb do
  pipe_through [:browser, :require_authenticated_user]
  live_session :pending_approval,
    on_mount: [{PourWeb.UserAuth, :require_authenticated}] do
    live "/pending-approval", PendingLive.Index, :index
  end
end

# Admin routes (authenticated + approved + admin role)
scope "/admin", PourWeb do
  pipe_through [:browser, :require_authenticated_user]
  live_session :admin,
    on_mount: [
      {PourWeb.UserAuth, :require_authenticated},
      {PourWeb.UserAuth, :require_approved},
      {PourWeb.UserAuth, :require_admin}
    ] do
    live "/users", AdminLive.Users, :index
  end
end

# Shop routes (authenticated + approved + shop role)
scope "/shop", PourWeb do
  pipe_through [:browser, :require_authenticated_user]
  live_session :shop,
    on_mount: [
      {PourWeb.UserAuth, :require_authenticated},
      {PourWeb.UserAuth, :require_approved},
      {PourWeb.UserAuth, :require_shop}
    ] do
    # Shop routes will be added in Phase 3
  end
end

# Member routes (authenticated + approved)
scope "/", PourWeb do
  pipe_through [:browser, :require_authenticated_user]
  live_session :approved_member,
    on_mount: [
      {PourWeb.UserAuth, :mount_current_scope},
      {PourWeb.UserAuth, :require_approved},
      {PourWeb.UserAuth, :load_cart}
    ] do
    live "/lot", LotLive.Index, :index
    live "/cart", CartLive.Show, :show
  end
end

# Move wine/region/varietal CRUD routes under /admin scope
# These are admin-only management routes
```

**Important:** The existing wine, country, region, subregion, and varietal CRUD routes should be moved under the `/admin` scope since they are management features.

### 9. Create seed script for first admin user

Update `priv/repo/seeds.exs`:

```elixir
# Create admin user if none exists
alias Pour.Repo
alias Pour.Accounts.User

unless Repo.get_by(User, email: "admin@georgetownpour.com") do
  %User{}
  |> Ecto.Changeset.change(%{
    email: "admin@georgetownpour.com",
    hashed_password: Bcrypt.hash_pwd_salt("AdminPassword123!"),
    role: "admin",
    approved: true,
    approved_at: DateTime.utc_now() |> DateTime.truncate(:second),
    confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
  })
  |> Repo.insert!()
end
```

### 10. Update post-login redirect

In `lib/pour_web/user_auth.ex`, update `signed_in_path/1`:
- If user is not approved, redirect to `/pending-approval`
- If user is admin, redirect to `/admin/users`
- Otherwise redirect to `/lot`

## Acceptance Criteria

- [ ] New user registration creates an unapproved member
- [ ] Unapproved users are redirected to /pending-approval after login
- [ ] Admin can see list of all users at /admin/users
- [ ] Admin can approve pending users (user receives email)
- [ ] Admin can reject pending users (user is deleted)
- [ ] Admin can change user roles
- [ ] Approved members can access /lot and /cart
- [ ] Non-admin users cannot access /admin/* routes
- [ ] Wine/region/varietal CRUD is under /admin only
- [ ] Seed script creates first admin user
- [ ] `mix test` passes (fix any broken tests due to route/schema changes)

## Status Report

When complete, provide:
1. List of all files created or modified
2. Any migration file names with timestamps
3. Any issues encountered or assumptions made
4. Any existing tests that broke and how you fixed them
5. Confirm `mix compile --warnings-as-errors` is clean
