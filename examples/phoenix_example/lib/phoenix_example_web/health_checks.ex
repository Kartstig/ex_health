defmodule PhoenixExampleWeb.HealthChecks do
  import ExHealth

  health_check("Database") do
    case Ecto.Adapters.SQL.query(PhoenixExample.Repo, "SELECT 1") do
      {:ok, %{num_rows: 1, rows: [[1]]}} -> :ok
      _ -> {:error, "Database unavailable"}
    end
  end

  process_check(PhoenixExampleWeb.Endpoint)
end
