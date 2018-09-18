defmodule ExHealth.Check do
  @type t :: %__MODULE__{
          name: String.t(),
          mfa: mfa()
        }

  defstruct name: "No checks specified",
            mfa: {__MODULE__, :no_check, []}

  @doc false
  def no_check(), do: false
end
