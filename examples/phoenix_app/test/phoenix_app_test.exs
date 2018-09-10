defmodule PhoenixAppTest do
  use ExUnit.Case
  doctest PhoenixApp

  test "greets the world" do
    assert PhoenixApp.hello() == :world
  end
end
