defmodule CheckTest do
  use ExUnit.Case, async: true

  doctest PhxHealth.Check

  test "%PhxHealth.Check{} has a falsey check by default" do
    %PhxHealth.Check{mfa: {m, f, a}} = %PhxHealth.Check{}
    assert apply(m, f, a) == false
  end
end
