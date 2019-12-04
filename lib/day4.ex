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

  def common_filter(input) do
    [a, b] = input
    a..b
    |> Enum.map(&to_charlist/1)
    |> Enum.filter(&never_decrease/1)
  end

  def solve(input) do
    common_filter(input)
    |> Enum.reject(&no_duplicates?/1)
    |> Enum.count
  end

  def solve2(input) do
    common_filter(input)
    |> Enum.filter(&has_pair_of_digits?/1)
    |> Enum.count
  end

  def password_to_number_frequencies(password) do
    Enum.reduce(password, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end

  def no_duplicates?(password) do
    password
    |> password_to_number_frequencies
    |> Map.values
    |> Enum.all?(fn x -> x == 1 end)
  end

  def has_pair_of_digits?(password) do
    password
    |> password_to_number_frequencies
    |> Map.values
    |> Enum.member?(2)
  end

  def never_decrease(password) do
    Enum.sort(password) == password
  end

end
