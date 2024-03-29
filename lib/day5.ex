defmodule Day5 do
  @moduledoc false

  import Intcode

  def real_input do
    Utils.get_input(5, 1)
  end

  def sample_input do
    """
    """
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
    input |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    Intcode.Io.start_link()
    Intcode.Io.set_input(1)
    Intcode.execute(input, :start)

    Intcode.Io.output()
  end

  def solve2(input) do
    Intcode.Io.start_link()
    Intcode.Io.set_input(5)
    Intcode.execute(input, :start)

    Intcode.Io.output()
  end
end
