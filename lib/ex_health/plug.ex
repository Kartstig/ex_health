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

  defp http_status(%ExHealth.Status{result: %{msg: :healthy}}), do: 200
  defp http_status(%ExHealth.Status{}), do: 503

  def call(%Plug.Conn{} = conn, _opts) do
    resp = ExHealth.status() |> Jason.encode!()

    http_err_code = Application.get_env(:ex_health, :http_err_code, false)

    code = case http_err_code do
      true -> ExHealth.status() |> http_status()
      _ -> 200
    end

    conn
    |> put_resp_content_type("application/json", "UTF-8")
    |> send_resp(code, resp)
    |> halt()
  end
end
