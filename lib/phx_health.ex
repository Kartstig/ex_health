defmodule PhxHealth do
  @moduledoc """
  Documentation for PhxHealth.
  """
  use Application

  def start(_type, args) do
    import Supervisor.Spec

    children = [
      supervisor(PhxHealth.HealthServer, args)
    ]

    opts = [strategy: :one_for_one, name: HealthCheck.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc "Fetch the latest status"
  @spec status() :: PhxHealth.Status.t()
  def status() do
    GenServer.call(PhxHealth.HealthServer, :status)
  end
end
