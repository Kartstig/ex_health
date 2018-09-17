defmodule ExHealth.Plug do
  defmacro __using__(_opts) do
    quote do
      import ExHealth
      import Plug.Conn
      @before_compile ExHealth.Plug
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @behaviour Plug
      @defaults [endpoint: "/_health"]

      def init(opts), do: Keyword.merge(@defaults, opts)

      def call(%Plug.Conn{request_path: request_path} = conn, opts) do
        {:ok, endpoint} = Keyword.fetch(opts, :endpoint)

        case request_path do
          ^endpoint ->
            resp = ExHealth.status() |> Jason.encode!()

            conn
            |> put_resp_content_type("application/json", "UTF-8")
            |> send_resp(200, resp)
            |> halt()

          _ ->
            conn
        end
      end
    end
  end
end
