defmodule CollectTest do
  use ExUnit.Case
  doctest Collect

  test "greets the world" do
    assert Collect.hello() == :world
  end
end
