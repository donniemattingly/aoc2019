defmodule Day16 do
  @moduledoc false

  def real_input do
    Utils.get_input(16, 1)
  end

  def sample_input do
    """
    12345678
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
  def parse_input2(input),
      do: input
          |> String.duplicate(10000)
          |> parse_input

  def solve1(input), do: solve(input)
  def solve2(input), do: solve(input)

  def parse_input(input) do
    input
    |> String.trim
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    input
    |> phase_times(100)
  end

  def solve(input) do

  end

  def phase_times(input, 0), do: input
  def phase_times(input, times) do
    IO.inspect(times)
    result = phase(input)
    phase_times(result, times - 1)
  end

  def phase(input) do
    0..length(input) - 1
    |> Flow.from_enumerable
    |> Flow.map(&calculate_element(input, &1))
    |> Enum.to_list
  end

  def calculate_element(input, position) do
    pattern = snth_output(position + 1)
    Stream.zip(input, pattern)
    |> Stream.map(fn {x, y} -> x * y end)
    |> Enum.sum
    |> rem(10)
    |> abs
  end

  def snth_output(val) do
    n = val - 1
    l = %{0 => 0, 1 => 1, 2 => 0, 3 => -1}
    Stream.unfold(
      {n, 0},
      fn
        {0, index} -> {l[index], {n, rem(index + 1, 4)}}
        {n, index} -> {l[index], {n - 1, index}}
      end
    )
    |> Stream.drop(1)
  end

  def nth_output(n) do
    [0, 1, 0, -1]
    |> Enum.reduce(
         [],
         fn x, acc ->
           repeated = for i <- 1..n, do: x
           repeated ++ acc
         end
       )
    |> Enum.reverse
    |> Stream.cycle
    |> Stream.drop(1)
  end
end
