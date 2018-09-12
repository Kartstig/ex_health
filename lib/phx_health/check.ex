defmodule PhxHealth.Check do
  @type t :: %__MODULE__{
          name: String.t(),
          mfa: mfa()
        }

  defstruct name: "No checks specified",
            mfa: {__MODULE__, :no_check, []}

  def no_check(), do: false
end
