defmodule Day4 do
  @moduledoc false

  def real_input do
    [171309, 643603]
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
    input
  end

  def solve(input) do
    [a, b] = input
    a..b
    |> Enum.map(&to_charlist/1)
    |> Enum.filter(&is_valid?/1)
    |> Enum.count
  end

  def solve2(input) do
    [a, b] = input
    a..b
    |> Enum.map(&to_charlist/1)
    |> Enum.filter(&is_valid2?/1)
    |> Enum.count
  end

  def is_valid?(password) do
    adjacent_digits_same?(password) and never_decrease(password)
  end

  def is_valid2?(password) do
    has_pair_of_digits?(password) and never_decrease(password)
  end

  def adjacent_digits_same?([h | t]) do
    {_, res} = Enum.reduce(t, {h, false}, fn x, {last, matches} -> {x, matches || x == last} end)
    res
  end

  def has_pair_of_digits?([h | t]) do
    {_, map} = Enum.reduce(
      t,
      {h, Map.put(%{}, h, 1)},
      fn x, {last, matches} ->
        if x == last do
          {x, Map.update(matches, x, 1, & &1 + 1)}
        else
          {x, Map.put(matches, x, 1)}
        end
      end
    )

    2 in Map.values(map)
  end

  def never_decrease(password) do
    Enum.sort(password) == password
  end

end
