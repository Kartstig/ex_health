defmodule CheckTest do
  use ExUnit.Case, async: true

  doctest ExHealth.Check

  test "%ExHealth.Check{} has a falsey check by default" do
    %ExHealth.Check{mfa: {m, f, a}} = %ExHealth.Check{}
    assert apply(m, f, a) == false
  end
end
