defmodule ExHealth.Plug do
  @moduledoc """
  A plug for integerating into a web application.

  ## Examples

  In Phoenix `router.ex`:

      scope "/" do
        forward("/_health", ExHealth.Plug)
      end

  Please ensure to use `scope/2`, otherwise the alias will not let you access
  the `ExHealth` namespace.

  For a more complete example, see the [Example Phoenix App](https://github.com/Kartstig/ex_health/tree/master/examples/phoenix_example).
  """
  import Plug.Conn
  @behaviour Plug

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    resp = ExHealth.status() |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json", "UTF-8")
    |> send_resp(200, resp)
    |> halt()
  end
end
