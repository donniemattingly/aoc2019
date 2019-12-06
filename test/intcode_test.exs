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

  test "Day 5 part 1 works" do
    input = Day5.real_input |> Day5.parse_input
    Intcode.Io.start_link([input: 1])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 13787043
  end

  test "equal to 8 when in position mode and input is not 8" do
    input = [3,9,8,9,10,9,4,9,99,-1,8]
    Intcode.Io.start_link([input: 0])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 0
  end

  test "equal to 8 when in position mode and input is 8" do
    input = [3,9,8,9,10,9,4,9,99,-1,8]
    Intcode.Io.start_link([input: 8])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 1
  end

  test "less than 8 when in position mode and input is 8" do
    input = [3,9,7,9,10,9,4,9,99,-1,8]
    Intcode.Io.start_link([input: 8])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 0
  end

  test "less than 8 when in position mode and input is less than 8" do
    input = [3,9,7,9,10,9,4,9,99,-1,8]
    Intcode.Io.start_link([input: 5])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 1
  end

  test "equal to 8 when in immediate mode and input is not 8" do
    input = [3,3,1108,-1,8,3,4,3,99]
    Intcode.Io.start_link([input: 0])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 0
  end

  test "equal to 8 when in immediate mode and input is 8" do
    input = [3,3,1108,-1,8,3,4,3,99]
    Intcode.Io.start_link([input: 8])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 1
  end

  test "less than 8 when in immediate mode and input is 8" do
    input = [3,3,1107,-1,8,3,4,3,99]
    Intcode.Io.start_link([input: 8])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 0
  end

  test "less than 8 when in immediate mode and input is less than 8" do
    input = [3,3,1107,-1,8,3,4,3,99]
    Intcode.Io.start_link([input: 5])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 1
  end

  test "jump if when in position mode and input is 0" do
    input = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
    Intcode.Io.start_link([input: 0])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 0
  end

  test "jump if when in position mode and input is not 0" do
    input = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
    Intcode.Io.start_link([input: 12])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 1
  end

  test "jump if when in immediate mode and input is 0" do
    input = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
    Intcode.Io.start_link([input: 0])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 0
  end

  test "jump if when in immediate mode and input is not 0" do
    input = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
    Intcode.Io.start_link([input: 12])
    Intcode.execute(input, :start)

    assert Intcode.Io.output() == 1
  end

end
