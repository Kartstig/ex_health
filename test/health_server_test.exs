defmodule HealthServerTest do
  use ExUnit.Case, async: true

  test "handle_info/2 schedules a check on the specified interval" do
    state = %PhxHealth.Status{interval: 1}

    PhxHealth.HealthServer.handle_info(:perform_check, state)

    assert_receive(:perform_check, 1100)
  end
end
