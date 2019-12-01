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
    sample_input
    |> parse_input1
    |> solve1
  end

  def part1 do
    real_input1
    |> parse_input1
    |> solve1
  end


  def sample2 do
    sample_input2
    |> parse_input2
    |> solve2
  end

  def part2 do
    real_input2
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
    |> Enum.map(&get_mass/1)
    |> Enum.sum
  end

  def solve2(input) do
    input
    |> Enum.map(fn x -> get_mass_2(x, 0) end)
    |> Enum.sum
  end

  def get_mass(val) do
    :math.floor(val / 3) - 2
  end

  def get_mass_2(val, sum) do
    new = get_mass(val)

    cond do
      new <= 0 -> sum
      true -> get_mass_2(new, new + sum)
    end
  end

end
