defmodule PhxHealthTest do
  use ExUnit.Case, async: true

  doctest PhxHealth

  def wait_for_poll(interval) do
    Process.sleep(interval * 2)
  end

  def good_result(), do: true
  def bad_result(), do: false

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
    arg = %PhxHealth.Status{interval_ms: 2}
    assert {:ok, _pid} = PhxHealth.start(:normal, [arg])
  end

  test "status/0 returns health check data" do
    arg = %PhxHealth.Status{interval_ms: 2}
    {:ok, _pid} = PhxHealth.start(:normal, [arg])

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
    good_text = "Something good"

    arg = %PhxHealth.Status{
      checks: [
        %PhxHealth.Check{name: good_text, mfa: {__MODULE__, :good_result, []}}
      ],
      interval_ms: interval_ms
    }

    {:ok, _pid} = PhxHealth.start(:normal, [arg])

    wait_for_poll(interval_ms)

    %PhxHealth.Status{
      last_check: last_check,
      result: %{
        msg: :healthy,
        check_results: check_results
      }
    } = PhxHealth.status()

    assert %DateTime{} = last_check
    assert [{good_text, true}] == check_results
  end

  test "status/0 returns unhealthy result when at least one result is bad" do
    interval_ms = 5
    good_text = "Something good"
    bad_text = "Something bad"

    arg = %PhxHealth.Status{
      checks: [
        %PhxHealth.Check{name: good_text, mfa: {__MODULE__, :good_result, []}},
        %PhxHealth.Check{name: bad_text, mfa: {__MODULE__, :bad_result, []}}
      ],
      interval_ms: interval_ms
    }

    {:ok, _pid} = PhxHealth.start(:normal, [arg])

    Process.sleep(interval_ms)

    %PhxHealth.Status{
      result: %{
        msg: :unhealthy,
        check_results: check_results
      }
    } = PhxHealth.status()

    assert [{good_text, true}, {bad_text, false}] == check_results
  end
end
