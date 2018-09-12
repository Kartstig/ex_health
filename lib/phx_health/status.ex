defmodule PhxHealth.Status do
  @type t :: %__MODULE__{
          checks: list(),
          interval: integer(),
          last_check: DateTime.t() | nil,
          result: %{
            msg: atom(),
            check_results: list()
          }
        }

  defstruct checks: [
              %PhxHealth.Check{name: "No checks specified", mfa: {PhxHealth.Check, :no_check, []}}
            ],
            interval: 2,
            last_check: nil,
            result: %{
              msg: :pending,
              check_results: []
            }
end
