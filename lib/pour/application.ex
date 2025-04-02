defmodule Pour.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PourWeb.Telemetry,
      Pour.Repo,
      {DNSCluster, query: Application.get_env(:pour, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pour.PubSub},
      # Start a worker by calling: Pour.Worker.start_link(arg)
      # {Pour.Worker, arg},
      # Start to serve requests, typically the last entry
      PourWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pour.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PourWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
