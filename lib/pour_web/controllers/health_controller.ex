defmodule PourWeb.HealthController do
  use PourWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
