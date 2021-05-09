defmodule ExHealth.Check do
  @moduledoc """
  A struct for storing healthcheck information.
  """
  @type t :: %__MODULE__{
          name: String.t(),
          mfa: mfa()
        }

  defstruct name: "No checks specified",
            mfa: {__MODULE__, :no_check, []}

  @doc false
  def no_check(), do: false
end
