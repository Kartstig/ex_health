defmodule ExHealth.Status do
  @moduledoc """
  A struct for storing state of the HealthServer
  """
  @type t :: %__MODULE__{
          checks: list(),
          interval_ms: integer(),
          last_check: DateTime.t() | nil,
          result: %{
            msg: atom(),
            check_results: list(tuple())
          }
        }

  @derive {Jason.Encoder, only: [:last_check, :result]}
  defstruct checks: [
              %ExHealth.Check{name: "No checks specified", mfa: {ExHealth.Check, :no_check, []}}
            ],
            interval_ms: 15_000,
            last_check: nil,
            result: %{
              msg: :pending,
              check_results: []
            }

  @spec to_json(__MODULE__.t()) :: String.t()
  def to_json(%__MODULE__{} = status) do
    status
    |> Jason.encode!()
  end
end
