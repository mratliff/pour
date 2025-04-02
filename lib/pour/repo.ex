defmodule Pour.Repo do
  use Ecto.Repo,
    otp_app: :pour,
    adapter: Ecto.Adapters.Postgres
end
