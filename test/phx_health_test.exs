defmodule PhxHealthTest do
  use ExUnit.Case
  doctest PhxHealth

  test "greets the world" do
    assert PhxHealth.hello() == :world
  end
end
