defmodule PhxHealth.HealthServer do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    state
    |> Map.get(:interval)
    |> schedule_update()

    {:ok, state}
  end

  @impl true
  def handle_call(:status, _from, %PhxHealth.Status{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:perform_check, %PhxHealth.Status{} = state) do
    new_state =
      state
      |> get_status()

    # Schedule next call
    new_state
    |> Map.get(:interval)
    |> schedule_update()

    {:noreply, new_state}
  end

  @spec build_result(list()) :: %{msg: atom(), check_results: list()}
  defp build_result(check_results) do
    status = determine_status(check_results)

    %{
      msg: status,
      check_results: check_results
    }
  end

  defp determine_status([]), do: :healthy

  @spec determine_status(list()) :: atom()
  defp determine_status([res | remainder]) do
    case res do
      {_name, false} -> :unhealthy
      {_name, true} -> determine_status(remainder)
    end
  end

  @spec get_status(PhxHealth.Status.t()) :: PhxHealth.Status.t()
  defp get_status(%PhxHealth.Status{checks: checks} = status) do
    check_results = perform_checks(checks)
    new_result = build_result(check_results)

    status
    |> Map.merge(%{
      last_check: DateTime.utc_now(),
      result: new_result
    })
  end

  @spec schedule_update(non_neg_integer) :: reference()
  defp schedule_update(interval) do
    Process.send_after(self(), :perform_check, interval * 1000)
  end

  defp perform_checks(checks, results \\ [])

  defp perform_checks([], results) do
    results
  end

  @spec perform_checks(list(), list()) :: list()
  defp perform_checks(
         [%PhxHealth.Check{name: name, mfa: {m, f, a}} = check | remainder],
         results
       ) do
    res = {name, apply(m, f, a)}
    perform_checks(remainder, results ++ [res])
  end
end
