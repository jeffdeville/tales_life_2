defmodule TalesLife2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TalesLife2Web.Telemetry,
      TalesLife2.Repo,
      {DNSCluster, query: Application.get_env(:tales_life_2, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TalesLife2.PubSub},
      # Start a worker by calling: TalesLife2.Worker.start_link(arg)
      # {TalesLife2.Worker, arg},
      # Start to serve requests, typically the last entry
      TalesLife2Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TalesLife2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TalesLife2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
