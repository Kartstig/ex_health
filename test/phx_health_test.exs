defmodule PhxHealthTest do
  use ExUnit.Case, async: true

  doctest PhxHealth

  def ensure_down(_) do
    case Process.whereis(PhxHealth.Supervisor) do
      nil -> :ok
      _ -> PhxHealth.stop()
    end
  end

  @doc "This is a naive way to wait, but it works fine with small delays"
  def wait_for_poll(interval) do
    Process.sleep(interval * 2)
  end

  def good_result(), do: true
  def bad_result(), do: false

  setup :ensure_down

  test "start/0 starts the HealthServer with configs" do
    defmodule TestHealthCallbacks do
      def some_fake_test(), do: true
    end

    interval_ms = 5

    Application.put_env(:phx_health, :interval_ms, interval_ms)

    Application.put_env(:phx_health, :module, __MODULE__.TestHealthCallbacks)

    assert {:ok, _pid} = PhxHealth.start()

    wait_for_poll(interval_ms)
    status = PhxHealth.status()

    assert %PhxHealth.Status{
             checks: [
               %PhxHealth.Check{
                 name: "some_fake_test",
                 mfa: {TestHealthCallbacks, :some_fake_test, []}
               }
             ],
             interval_ms: interval_ms,
             result: %{
               msg: :healthy,
               check_results: [{"some_fake_test", true}]
             }
           } = status
  end

  test "start/2 starts the HealthServer" do
    assert {:ok, _pid} = PhxHealth.start(:normal, interval_ms: 2)
  end

  test "status/0 returns health check data" do
    {:ok, _pid} = PhxHealth.start(:normal, interval_ms: 2)

    assert %PhxHealth.Status{
             checks: _,
             interval_ms: _,
             last_check: nil,
             result: %{
               msg: :pending,
               check_results: _
             }
           } = PhxHealth.status()
  end

  test "status/0 returns healthy result when all results are good" do
    interval_ms = 5

    defmodule FakeTestGood do
      def something_good(), do: true
    end

    {:ok, _pid} =
      PhxHealth.start(:normal,
        interval_ms: interval_ms,
        module: __MODULE__.FakeTestGood
      )

    wait_for_poll(interval_ms)

    %PhxHealth.Status{
      last_check: last_check,
      result: %{
        msg: :healthy,
        check_results: check_results
      }
    } = PhxHealth.status()

    assert %DateTime{} = last_check
    assert [{"something_good", true}] == check_results
  end

  test "status/0 returns unhealthy result when at least one result is bad" do
    interval_ms = 5

    defmodule FakeTestBad do
      def something_good(), do: true
      def something_bad(), do: false
    end

    {:ok, _pid} =
      PhxHealth.start(:normal,
        interval_ms: interval_ms,
        module: __MODULE__.FakeTestBad
      )

    Process.sleep(interval_ms)

    %PhxHealth.Status{
      result: %{
        msg: :unhealthy,
        check_results: check_results
      }
    } = PhxHealth.status()

    assert {"something_good", true} in check_results
    assert {"something_bad", false} in check_results
  end
end
