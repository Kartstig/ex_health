defmodule PhxHealthTest do
  use ExUnit.Case, async: true

  doctest PhxHealth

  def good_result(), do: true
  def bad_result(), do: false

  test "start/0 starts the HealthServer with configs" do
    defmodule TestHealthCallbacks do
      def some_fake_test(), do: true
    end

    interval = 1

    Application.put_env(:phx_health, :interval, interval)

    Application.put_env(:phx_health, :module, __MODULE__.TestHealthCallbacks)

    assert {:ok, _pid} = PhxHealth.start()

    Process.sleep(interval * 1000)
    status = PhxHealth.status()

    assert %PhxHealth.Status{
             checks: [
               %PhxHealth.Check{
                 name: "some_fake_test",
                 mfa: {TestHealthCallbacks, :some_fake_test, []}
               }
             ],
             interval: interval,
             result: %{
               msg: :healthy,
               check_results: [{"some_fake_test", true}]
             }
           } = status
  end

  test "start/2 starts the HealthServer" do
    arg = %PhxHealth.Status{interval: 2}
    assert {:ok, _pid} = PhxHealth.start(:normal, [arg])
  end

  test "status/0 returns health check data" do
    arg = %PhxHealth.Status{interval: 2}
    {:ok, _pid} = PhxHealth.start(:normal, [arg])

    assert %PhxHealth.Status{
             checks: _,
             interval: _,
             last_check: nil,
             result: %{
               msg: :pending,
               check_results: _
             }
           } = PhxHealth.status()
  end

  test "status/0 returns healthy result when all results are good" do
    interval = 1
    good_text = "Something good"

    arg = %PhxHealth.Status{
      checks: [
        %PhxHealth.Check{name: good_text, mfa: {__MODULE__, :good_result, []}}
      ],
      interval: interval
    }

    {:ok, _pid} = PhxHealth.start(:normal, [arg])

    Process.sleep(interval * 1000)

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
    interval = 1
    good_text = "Something good"
    bad_text = "Something bad"

    arg = %PhxHealth.Status{
      checks: [
        %PhxHealth.Check{name: good_text, mfa: {__MODULE__, :good_result, []}},
        %PhxHealth.Check{name: bad_text, mfa: {__MODULE__, :bad_result, []}}
      ],
      interval: interval
    }

    {:ok, _pid} = PhxHealth.start(:normal, [arg])

    Process.sleep(interval * 1000)

    %PhxHealth.Status{
      result: %{
        msg: :unhealthy,
        check_results: check_results
      }
    } = PhxHealth.status()

    assert [{good_text, true}, {bad_text, false}] == check_results
  end
end
