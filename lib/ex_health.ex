defmodule ExHealth do
  @moduledoc """
  Documentation for ExHealth.
  """
  use Application

  @function_prefix "hc__"

  @doc """
  Defines a healthcheck function
  """
  defmacro health_check(name, do: block) do
    function_name = String.to_atom("#{@function_prefix}" <> name)

    quote do
      def unquote(function_name)(), do: unquote(block)
    end
  end

  @doc """
  Defines a healthcheck function for a given process.

  Returns true if the process has one of the following statuses:
    - :running
    - :waiting

  example:

    defmodule MyHealthCheck do
      process_check(PhoenixAppWeb.Endpoint)
    end
  """
  defmacro process_check({_, _, module_list} = _module) do
    {module, _} = Code.eval_string(Enum.join(module_list, "."))
    function_name = String.to_atom("#{@function_prefix}" <> Enum.join(module_list, "_"))

    quote do
      def unquote(function_name)() do
        case Process.whereis(unquote(module)) do
          nil ->
            false

          pid ->
            case Process.info(pid) do
              nil ->
                false

              info ->
                case Keyword.fetch(info, :status) do
                  {:ok, :running} -> true
                  {:ok, :waiting} -> true
                  _ -> false
                end
            end
        end
      end
    end
  end

  def start() do
    start(:normal, state: %ExHealth.Status{})
  end

  def start(_type, args) do
    import Supervisor.Spec

    configure(args)

    initial_state = load_config()

    children = [
      supervisor(ExHealth.HealthServer, [initial_state])
    ]

    opts = [strategy: :one_for_one, name: ExHealth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc "Fetch the latest status"
  @spec status() :: ExHealth.Status.t()
  def status() do
    GenServer.call(ExHealth.HealthServer, :status)
  end

  def stop() do
    Supervisor.stop(ExHealth.Supervisor, :normal)
  end

  defp configure([]), do: nil

  defp configure([{k, v} | remainder]) do
    Application.put_env(:ex_health, k, v)
    configure(remainder)
  end

  defp extract_health_checks(module) do
    hc_regex = ~r/#{@function_prefix}.*/

    module.__info__(:functions)
    |> Enum.filter(fn {func, _arr} ->
      Atom.to_string(func) =~ hc_regex
    end)
  end

  defp extract_and_transform(module) do
    function_list = extract_health_checks(module)

    for {func, _arr} <- function_list do
      %ExHealth.Check{name: remove_function_prefix(func), mfa: {module, func, []}}
    end
  end

  defp load_config() do
    :ok =
      case Application.load(:ex_health) do
        :ok ->
          :ok

        {:error, {:already_loaded, :ex_health}} ->
          :ok
      end

    module = Application.get_env(:ex_health, :module)
    interval_ms = Application.get_env(:ex_health, :interval_ms, 15000)

    mfas =
      case module do
        nil -> extract_and_transform(ExHealth.SelfCheck)
        mod -> extract_and_transform(mod)
      end

    %ExHealth.Status{
      checks: mfas,
      interval_ms: interval_ms
    }
  end

  defp remove_function_prefix(function) do
    name_with_prefix = Atom.to_string(function)
    prefix = String.length(@function_prefix)
    String.slice(name_with_prefix, prefix, String.length(name_with_prefix))
  end
end
