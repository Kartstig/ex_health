defmodule PhxHealth.HealthCheck do
  def health_check_server() do
    pid = Process.whereis(PhxHealth.HealthServer)

    case Process.info(pid) do
      nil ->
        false

      infos ->
        case Keyword.fetch(infos, :status) do
          {:ok, :running} ->
            true

          _ ->
            false
        end
    end
  end
end
