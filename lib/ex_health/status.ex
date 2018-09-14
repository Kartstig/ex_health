defmodule ExHealth.Status do
  @type t :: %__MODULE__{
          checks: list(),
          interval_ms: integer(),
          last_check: DateTime.t() | nil,
          result: %{
            msg: atom(),
            check_results: list()
          }
        }

  defstruct checks: [
              %ExHealth.Check{name: "No checks specified", mfa: {ExHealth.Check, :no_check, []}}
            ],
            interval_ms: 15000,
            last_check: nil,
            result: %{
              msg: :pending,
              check_results: []
            }
end
