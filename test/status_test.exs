defmodule StatusTest do
  use ExUnit.Case, async: true

  doctest ExHealth.Status

  test "%ExHealth.Status{} has defaults" do
    assert %ExHealth.Status{
             interval_ms: 15000,
             last_check: nil,
             result: %{msg: :pending, check_results: []}
           } = %ExHealth.Status{}
  end

  test "to_json/1 returns a valid JSON" do
    last_check = DateTime.utc_now()
    last_check_str = last_check |> Jason.encode!() |> Jason.decode!()
    msg = :foo
    msg_str = Atom.to_string(msg)
    check_results = [{"DB", true}, {"Redis", false}]
    check_results_list = for res <- check_results, do: Tuple.to_list(res)

    status = %ExHealth.Status{
      last_check: last_check,
      result: %{msg: msg, check_results: check_results}
    }

    decoded_res = status |> ExHealth.Status.to_json() |> Jason.decode!()

    assert %{
             "last_check" => last_check_str,
             "result" => %{
               "msg" => msg_str,
               "check_results" => check_results_list
             }
           } == decoded_res
  end
end
