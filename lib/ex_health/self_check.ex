defmodule ExHealth.SelfCheck do
  @moduledoc false
  import ExHealth

  process_check(ExHealth.HealthServer)
end
