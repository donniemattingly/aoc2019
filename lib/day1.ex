defmodule Day1 do
  def real_input do
    Utils.get_input(1, 1)
  end

  def sample_input do
    """
    test
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
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    input
    |> Enum.map(&calculate_fuel/1)
    |> Enum.sum
  end

  def solve2(input) do
    input
    |> Enum.map(&calculate_additional_fuel/1)
    |> Enum.sum
  end

  @doc ~S"""
  Calculate the fuel required given a mass

  ## Examples
      iex> Day1.calculate_fuel(12)
      2

      iex> Day1.calculate_fuel(14)
      2

      iex> Day1.calculate_fuel(1969)
      654

      iex> Day1.calculate_fuel(100756)
      33583
  """
  def calculate_fuel(val) do
    trunc(:math.floor(val / 3) - 2)
  end


  @doc ~S"""
  Calculate the fuel required given a mass plus the additional fuel for carrying
  that fuel

  ## Examples
      iex> Day1.calculate_additional_fuel(12)
      2

      iex> Day1.calculate_additional_fuel(1969)
      966

      iex> Day1.calculate_additional_fuel(100756)
      50346
  """
  def calculate_additional_fuel(val, sum \\ 0) do
    case calculate_fuel(val) do
      x when x <= 0 -> sum
      x -> calculate_additional_fuel(x, x + sum)
    end
  end

end
