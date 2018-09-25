defmodule ExHealth do
  @moduledoc """
  [![CircleCI](https://circleci.com/gh/MatchedPattern/ex_health/tree/master.svg?style=svg&circle-token=8ed28fee90111e2a034b0d71e0fcf8ae18bba641)](https://circleci.com/gh/MatchedPattern/ex_health/tree/master) [![codecov](https://codecov.io/gh/MatchedPattern/ex_health/branch/master/graph/badge.svg)](https://codecov.io/gh/MatchedPattern/ex_health)

  ExHealth is a simple extensible health check utility that monitors your applications.


  By itself, ExHealth is a supervised GenServer that periodically performs a set
  of checks, but you can easily configure your it to serve JSON responses that
  look like:

      {
         last_check:"2018-09-18T06:43:53.773719Z",
         result:{
            check_results:[
               [
                  "Database",
                  true
               ],
               [
                  "PhoenixExampleWeb_Endpoint",
                  true
               ]
            ],
            msg:"healthy"
         }
      }

  # Getting Started

  Configuration for ExHealth must be present the Application environment. This
  can be done by updating the `:ex_health` values in your `config/config.exs`:

      config :ex_health,
        module: MyApplication.HealthChecks,
        interval_ms: 1000

  Then you must define a module `MyApplication.HealthChecks` with some checks:

      defmodule MyApplication.HealthChecks do
        process_check(MyApplication.CacheServer)

        test "Redis" do
          MyRedis.ping() # This should return :ok | {:error, "Message"}
        end
      end

  # Integrating with Phoenix

  To integrate with [Phoenix](https://hexdocs.pm/phoenix/Phoenix.html)
  or any other web framework, you can take advantage of `ExHealth.Plug`
  which handles serving a JSON response for you.

  See `ExHealth.Plug` for instructions.


  """
  use Application

  @function_prefix "hc__"

  @doc """
  Defines a healthcheck function.

  Takes the following arguments:
  1. `name` - a string for the name of the health check
  2. `block` -  block that returns `:ok | true | {:error, "Reason"}`

  ## Examples:

      defmodule MyApp.HealthChecks do
        health_check("Database") do
          MyDB.ping() # This should return  :ok | true | {:error, "Reason"}
        end
      end
  """
  defmacro health_check(name, do: block) do
    function_name = String.to_atom("#{@function_prefix}" <> name)

    quote do
      def unquote(function_name)() do
        try do
          unquote(block)
        rescue
          _ -> {:error, "Error in HealthCheck"}
        end
      end
    end
  end

  @doc """
  Defines a healthcheck function for a given process.

  Returns true if the process has one of the following statuses:
    - `:running`
    - `:waiting`

  See [Process.info/1](https://hexdocs.pm/elixir/Process.html#info/1) for more
  information about process status.

  ## Examples:

      defmodule MyApp.HealthChecks do
        process_check(MyApp.SomeImportantService)
      end
  """
  defmacro process_check({_, _, module_list} = _module) do
    {module, _} = Code.eval_string(Enum.join(module_list, "."))
    function_name = String.to_atom("#{@function_prefix}" <> Enum.join(module_list, "_"))

    quote do
      def unquote(function_name)() do
        case Process.whereis(unquote(module)) do
          nil ->
            {:error, "no proc"}

          pid ->
            case Process.info(pid) do
              nil ->
                {:error, "no proc"}

              info ->
                case Keyword.fetch(info, :status) do
                  {:ok, :running} -> :ok
                  {:ok, :waiting} -> :ok
                  _ -> {:error, "process not running/waiting"}
                end
            end
        end
      end
    end
  end

  defimpl Jason.Encoder, for: [Tuple] do
    def encode(tuple, opts) do
      Jason.Encode.list(Tuple.to_list(tuple), opts)
    end
  end

  @doc """
  Starts the application with empty state
  """
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

  @doc """
  Synchronously fetches the latest status from `ExHealth.HealthServer`

  ## Examples:

      iex(1)> ExHealth.status()
      %ExHealth.Status{
        checks: [
          %ExHealth.Check{
            mfa: {ExHealth.SelfCheck, :hc__ExHealth_HealthServer, []},
            name: "ExHealth_HealthServer"
          }
        ],
        interval_ms: 15000,
        last_check: nil,
        result: %{check_results: [], msg: :pending}
      }


  """
  @spec status() :: ExHealth.Status.t()
  def status() do
    GenServer.call(ExHealth.HealthServer, :status)
  end

  @doc """
  Stops the Application
  """
  @spec stop() :: :ok
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

  @spec extract_and_transform(module()) :: list(ExHealth.Check.t())
  defp extract_and_transform(module) do
    function_list = extract_health_checks(module)

    for {func, _arr} <- function_list do
      %ExHealth.Check{name: remove_function_prefix(func), mfa: {module, func, []}}
    end
  end

  @spec load_config() :: ExHealth.Status.t()
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
