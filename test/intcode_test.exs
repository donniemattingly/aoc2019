defmodule IntcodeTest do
  use ExUnit.Case


  test "Simple Add" do
     assert Intcode.execute([1,0,0,0,99], :start) == [2,0,0,0,99]
  end

  test "Simple Multiply" do
    assert Intcode.execute([2,3,0,3,99], :start) == [2,3,0,6,99]
  end

  test "Day 2 Part 1 Works" do
    input = Day2.real_input |> Day2.parse_input |> List.replace_at(1, 12) |> List.replace_at(2, 2)
    assert hd(Intcode.execute(input, :start)) == 3267740
  end

end
