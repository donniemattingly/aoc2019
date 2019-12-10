defmodule Day9 do
  @moduledoc false

  def real_input do
    Utils.get_input(9, 1)
  end

  def sample_input do
    "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
  end

  def sample_input2 do
    """
    """
  end

  def sample do
    sample_input()
    |> parse_input1
    |> solve1
  end

  def part1 do
    real_input1()
    |> parse_input1
    |> solve1
  end

  def sample2 do
    sample_input2()
    |> parse_input2
    |> solve2
  end

  def part2 do
    real_input2()
    |> parse_input2
    |> solve2
  end

  def real_input1, do: real_input()
  def real_input2, do: real_input()

  def parse_input1(input), do: parse_input(input)
  def parse_input2(input), do: parse_input(input)

  def solve1(input), do: solve(input)

  def parse_input(input) do
    input |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    name = Intcode.Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Intcode.Computer.set_memory(name, input)
    Intcode.Computer.IO.push_input(name, 1)
    Intcode.Computer.run(name)
  end

  def solve2(input) do
    name = Intcode.Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Intcode.Computer.set_memory(name, input)
    Intcode.Computer.IO.push_input(name, 2)
    Intcode.Computer.run(name)
  end
end
