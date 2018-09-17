defmodule HealthServerTest do
  use ExUnit.Case, async: true

  test "handle_info/2 schedules a check on the specified interval" do
    state = %ExHealth.Status{interval_ms: 5}

    ExHealth.HealthServer.handle_info(:perform_check, state)

    assert_receive(:perform_check, 1100)
  end
end
