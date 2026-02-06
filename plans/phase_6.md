# Phase 6: Fly.io Deployment

## Context

You are working on Georgetown Pour, a Phoenix 1.8 + Ecto community wine-tasting app. Phases 1-5 are complete — the full application is built:

- Auth with role-based access control and admin approval
- Tasting events with RSVP and private locations
- Orders with shop dashboard and consolidated view
- Wine ratings and reviews
- Blog with Markdown and tags
- Wine image uploads via S3

**IMPORTANT:** Before starting, read these files:
- `mix.exs` — dependencies and project config
- `config/runtime.exs` — production configuration
- `config/prod.exs` — production compile-time config

## Objective

Deploy the application to Fly.io with PostgreSQL, S3 storage, and email sending.

## Tasks

### 1. Generate Release Files

Run:
```bash
mix phx.gen.release --docker
```

This generates:
- `Dockerfile`
- `.dockerignore`
- `lib/pour/release.ex` (migration runner)

Review the generated files and adjust if needed:
- Ensure the Dockerfile uses the correct Elixir/Erlang/OTP versions
- Ensure assets are built correctly (tailwind + esbuild)

### 2. Create Release Module (if not generated)

**`lib/pour/release.ex`:**
```elixir
defmodule Pour.Release do
  @app :pour

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
  end
end
```

### 3. Create fly.toml

```toml
app = "georgetown-pour"
primary_region = "iad"  # US East (Virginia) — close to Georgetown

[build]

[deploy]
  release_command = "/app/bin/migrate"

[http_service]
  internal_port = 4000
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 0

  [http_service.concurrency]
    type = "connections"
    hard_limit = 1000
    soft_limit = 1000

[[vm]]
  size = "shared-cpu-1x"
  memory = "512mb"
```

### 4. Create Migration Script

Create `rel/overlays/bin/migrate`:
```bash
#!/bin/sh
set -eu

cd -P -- "$(dirname -- "$0")"
exec ./pour eval Pour.Release.migrate
```

Make it executable. Ensure the Dockerfile copies it correctly.

### 5. Update Dockerfile

Verify the generated Dockerfile:
- Uses multi-stage build (builder + runner)
- Installs Node.js if needed for asset building (check if esbuild/tailwind need it)
- Copies `rel/overlays` for the migrate script
- Sets correct ENV vars: `MIX_ENV=prod`, `PHX_SERVER=true`
- Final image is minimal (Debian slim or Alpine)

### 6. Verify runtime.exs Production Config

Check `config/runtime.exs` has these configured from environment variables:
- `DATABASE_URL` — Fly Postgres connection string
- `SECRET_KEY_BASE` — generated secret
- `PHX_HOST` — domain name (e.g., "georgetownpour.com" or "georgetown-pour.fly.dev")
- `PORT` — defaults to 4000

Add S3/storage config if not already present:
```elixir
if config_env() == :prod do
  config :ex_aws,
    access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
    secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY"),
    region: System.get_env("AWS_REGION", "us-east-1")

  config :pour, :s3_bucket, System.fetch_env!("S3_BUCKET")
end
```

Add email/SMTP config:
```elixir
if config_env() == :prod do
  # Option A: Mailgun
  config :pour, Pour.Mailer,
    adapter: Swoosh.Adapters.Mailgun,
    api_key: System.fetch_env!("MAILGUN_API_KEY"),
    domain: System.fetch_env!("MAILGUN_DOMAIN")

  # Option B: Postmark
  # config :pour, Pour.Mailer,
  #   adapter: Swoosh.Adapters.Postmark,
  #   api_key: System.fetch_env!("POSTMARK_API_KEY")

  # Option C: AWS SES
  # config :pour, Pour.Mailer,
  #   adapter: Swoosh.Adapters.AmazonSES,
  #   region: System.get_env("AWS_REGION", "us-east-1"),
  #   access_key: System.fetch_env!("AWS_ACCESS_KEY_ID"),
  #   secret: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
end
```

Note: Choose ONE email adapter. The user should decide which email service to use. Default to Mailgun if no preference stated.

### 7. Deployment Commands

Provide the user with the deployment steps (do NOT run these — they require interactive Fly CLI auth):

```bash
# 1. Install Fly CLI (if not installed)
curl -L https://fly.io/install.sh | sh

# 2. Login to Fly
fly auth login

# 3. Launch the app (first time only)
fly launch --name georgetown-pour --region iad --no-deploy

# 4. Create Postgres database
fly postgres create --name georgetown-pour-db --region iad
fly postgres attach georgetown-pour-db

# 5. Set secrets
fly secrets set \
  SECRET_KEY_BASE=$(mix phx.gen.secret) \
  PHX_HOST=georgetown-pour.fly.dev \
  AWS_ACCESS_KEY_ID=your-key \
  AWS_SECRET_ACCESS_KEY=your-secret \
  AWS_REGION=us-east-1 \
  S3_BUCKET=georgetown-pour \
  MAILGUN_API_KEY=your-mailgun-key \
  MAILGUN_DOMAIN=mg.georgetownpour.com

# 6. Deploy
fly deploy

# 7. Run seed (first time, after deploy)
fly ssh console -C "/app/bin/pour eval 'Pour.Release.migrate()'"
fly ssh console -C "/app/bin/pour eval 'Code.eval_file(\"priv/repo/seeds.exs\")'"

# 8. Verify
fly open
```

### 8. Health Check

Add a simple health check endpoint if not already present:

In `lib/pour_web/router.ex`:
```elixir
scope "/api", PourWeb do
  pipe_through :api
  get "/health", HealthController, :index
end
```

Create `lib/pour_web/controllers/health_controller.ex`:
```elixir
defmodule PourWeb.HealthController do
  use PourWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
```

### 9. Create .dockerignore (if not generated)

```
.git
_build
deps
.elixir_ls
.env
*.secret
fly.toml
plans/
PLAN.md
```

## Acceptance Criteria

- [ ] Dockerfile builds successfully: `docker build -t pour .`
- [ ] fly.toml is configured with correct region and deploy settings
- [ ] Release migration command works
- [ ] runtime.exs configures all production env vars (DB, secret, S3, email)
- [ ] Health check endpoint responds at /api/health
- [ ] .dockerignore excludes dev/sensitive files
- [ ] Deployment commands are documented for the user
- [ ] `mix compile --warnings-as-errors` is clean in prod env

## Status Report

When complete, provide:
1. List of all files created or modified
2. Which email adapter was configured (and alternatives commented)
3. Any Dockerfile customizations made
4. Any issues with the generated release files
5. Full deployment command sequence for the user
6. Confirm the Docker build succeeds locally (if possible)
