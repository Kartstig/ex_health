defmodule PhxHealth do
  @moduledoc """
  Documentation for PhxHealth.
  """
  use Application

  def start() do
    conf = load_config()
    start(:normal, [conf])
  end

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

  defp load_config() do
    :ok =
      case Application.load(:phx_health) do
        :ok ->
          :ok

        {:error, {:already_loaded, :phx_health}} ->
          :ok
      end

    module = Application.get_env(:phx_health, :module)
    interval = Application.get_env(:phx_health, :interval)

    funcs = module.__info__(:functions)

    mfas =
      for {func, _arr} <- funcs do
        %PhxHealth.Check{name: Atom.to_string(func), mfa: {module, func, []}}
      end

    %PhxHealth.Status{
      checks: mfas,
      interval: interval
    }
  end
end
