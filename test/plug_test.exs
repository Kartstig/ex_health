defmodule PlugTest do
  use ExUnit.Case, async: true

  @endpoint "/_health"

  test "call/2 returns the correct JSON payload" do
    result =
      Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, @endpoint, %{})
      |> ExHealth.Plug.call([])

    assert %Plug.Conn{
             resp_body: body,
             halted: true
           } = result

    assert %{
             "last_check" => nil,
             "result" => %{"check_results" => [], "msg" => "pending"}
           } = Jason.decode!(body)
  end

  test "call/2 returns a 503 when :http_err_code is set to true" do
    Application.put_env(:ex_health, :http_err_code, true)

    result =
      Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, @endpoint, %{})
      |> ExHealth.Plug.call([])

    assert result.status == 503
    Application.put_env(:ex_health, :http_err_code, false)
  end
end
