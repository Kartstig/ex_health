defmodule PlugTest do
  use ExUnit.Case, async: true

  test "call/2 returns the correct JSON payload" do
    endpoint = "/_health"

    defmodule TestPlug do
      use ExHealth.Plug
    end

    result =
      Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, endpoint, %{})
      |> TestPlug.call(endpoint: endpoint)

    assert %Plug.Conn{
             resp_body: body,
             halted: true
           } = result

    assert %{
             "last_check" => nil,
             "result" => %{"check_results" => [], "msg" => "pending"}
           } = Jason.decode!(body)
  end
end
