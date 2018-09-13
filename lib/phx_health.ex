defmodule PhxHealth do
  @moduledoc """
  Documentation for PhxHealth.
  """
  use Application

  def start() do
    start(:normal, state: %PhxHealth.Status{})
  end

  def start(_type, args) do
    import Supervisor.Spec

    configure(args)

    initial_state = load_config()

    children = [
      supervisor(PhxHealth.HealthServer, [initial_state])
    ]

    opts = [strategy: :one_for_one, name: PhxHealth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc "Fetch the latest status"
  @spec status() :: PhxHealth.Status.t()
  def status() do
    GenServer.call(PhxHealth.HealthServer, :status)
  end

  def stop() do
    Supervisor.stop(PhxHealth.Supervisor, :normal)
  end

  defp configure([]), do: nil

  defp configure([{k, v} | remainder]) do
    Application.put_env(:phx_health, k, v)
    configure(remainder)
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
    interval_ms = Application.get_env(:phx_health, :interval_ms, 15000)

    mfas =
      case module do
        nil -> transform_module_to_mfa(PhxHealth.HealthCheck)
        mod -> transform_module_to_mfa(mod)
      end

    %PhxHealth.Status{
      checks: mfas,
      interval_ms: interval_ms
    }
  end

  defp transform_module_to_mfa(module) do
    funcs = module.__info__(:functions)

    for {func, _arr} <- funcs do
      %PhxHealth.Check{name: Atom.to_string(func), mfa: {module, func, []}}
    end
  end
end
