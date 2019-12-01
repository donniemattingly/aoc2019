defmodule AdventofcodeTest do
  use ExUnit.Case
  doctest Adventofcode
  doctest Day1

  test "greets the world" do
    assert Adventofcode.hello() == :world
  end
end
