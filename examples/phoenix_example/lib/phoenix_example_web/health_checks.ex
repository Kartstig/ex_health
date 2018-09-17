defmodule PhoenixExampleWeb.HealthChecks do
  import ExHealth

  health_check("Database") do
    %{num_rows: 1, rows: [res | _]} = Ecto.Adapters.SQL.query!(PhoenixExample.Repo, "SELECT 1")
    [1] == res
  end

  process_check(PhoenixExampleWeb.Endpoint)
end
