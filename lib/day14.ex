defmodule Day14 do
  @moduledoc false

  def real_input do
    Utils.get_input(14, 1)
  end

  def sample_input do
    """
    10 ORE => 10 A
    1 ORE => 1 B
    7 A, 1 B => 1 C
    7 A, 1 C => 1 D
    7 A, 1 D => 1 E
    7 A, 1 E => 1 FUEL
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
  def solve2(input), do: solve(input)

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [unparsed_input, unparsed_output] = String.split(line, "=>")
    inputs = String.split(unparsed_input, ",", trim: true) |> Enum.map(&String.trim/1) |> Enum.map(&parse_reagent/1)
    output = unparsed_output |> String.trim |> parse_reagent
    {inputs, output}
  end

  def parse_reagent(reagent) do
    [cost, chemical] = String.split(reagent, " ", trim: true)
    {chemical |> String.to_atom, String.to_integer(cost)}
  end

  def reduce_costs(costs) do

  end

  def can_reduce?(known_costs, inputs) do
    known_set = known_costs |> Map.keys |> MapSet.new
    input_set = inputs |> Keyword.keys |> MapSet.new

    MapSet.subset?(input_set, known_set)
  end

  def map_input(known_costs, {chemical, cost}) do
    Map.get(known_costs, chemical) * cost
  end

  def reduce_cost({known_costs, {inputs, output}}) do
    if can_reduce?(known_costs, inputs) do
      sum = inputs
      |> Enum.map(&map_input(known_costs, &1))
      |> Enum.sum
      Map.put()
    else
      {known_costs, {inputs, output}}
    end
  end

  def solve(input) do
    input
  end
end
