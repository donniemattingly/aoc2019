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
    inputs = String.split(unparsed_input, ",", trim: true)
             |> Enum.map(&String.trim/1)
             |> Enum.map(&parse_reagent/1)
    output = unparsed_output
             |> String.trim
             |> parse_reagent
    {inputs, output}
  end

  def parse_reagent(reagent) do
    [cost, chemical] = String.split(reagent, " ", trim: true)
    {
      chemical
      |> String.to_atom,
      String.to_integer(cost)
    }
  end

  def reduce_costs(costs) do

  end

  def can_reduce?(known_costs, inputs) do
    known_set = known_costs
                |> Map.keys
                |> MapSet.new
    input_set = inputs
                |> Keyword.keys
                |> MapSet.new

    MapSet.subset?(input_set, known_set)
  end

  def map_input(known_costs, {chemical, cost}) do
    Map.get(known_costs, chemical) * cost
  end

  def initial_known_costs(costs) do
    costs
    |> Enum.filter(
         fn {inputs, output} ->
           inputs
           |> Keyword.keys
           |> Enum.all?(&(&1 == :ORE))
         end
       )
    |> Enum.reduce(
         %{},
         fn {inputs, {chemical, amount}}, acc ->
           ore_cost = inputs
                      |> Keyword.values
                      |> Enum.sum

           ratio = {ore_cost, amount}

           Map.update(acc, chemical, [ratio], fn x -> [ratio | x] end)
         end
       )
  end

  def reduce_cost({known_costs, {inputs, {chemical, amount}}}) do
    if can_reduce?(known_costs, inputs) do
      sum = inputs
            |> Enum.map(&map_input(known_costs, &1))
            |> Enum.sum


    else
      {known_costs, {inputs, {chemical, amount}}}
    end
  end

  def costs_list_to_map(costs) do
    costs
    |> Enum.map(
         fn {inputs, {chemical, amount}} ->
           {chemical, {amount, inputs}}
         end
       )
    |> Enum.into(%{})
  end

  def is_primary?({inputs, _}) do
    inputs
    |> Keyword.keys
    |> Enum.all?(& &1 == :ORE)
  end

  def group_by_origin(costs) do
    costs
    |> Enum.group_by(
         fn x ->
           if is_primary?(x), do: :primary, else: :derived
         end
       )
  end


  @doc"""
  Want to reduce all derived costs to known values.
  """
  def reduce_derived(known, derived) do
    derived
    |> Enum.reduce(
         known,
         fn {inputs, {chemical, amount}}, acc ->
           if can_reduce?(known, inputs) do
             inputs
             |> Enum.map(
                  fn {input_chem, input_cost} ->

                  end
                )
           else
             acc
           end
         end
       )
  end

  @doc"""
  The idea here is for nodes to be map of chemicals to current cost.
  """
  def reachable_neighbors(), do: nil

  def foo(costs) do
    grouped = group_by_origin(costs)
    known = grouped.primary
            |> Enum.map(&elem(&1, 1))
            |> Enum.map(&elem(&1, 0))
            |> MapSet.new
    derived = grouped.derived
  end

  def update_known_reducer({inputs, {chemical, amount} = output} = formula, {primary_chemicals, known}) do
    if is_fully_reduced?(formula, primary_chemicals) do
      Map.put()
    end
  end


  @doc"""
  This reduce expects to reduce a list of formulas that are not fully reduced
  i.e. their inputs are not comprised exclusively of primary chemicals

  `reduced_formulas` is a map of output to {amount, formula}
  """
  def collapse_derived_reducer(
        {inputs, {chemical, amount} = output} = formula,
        {primary_chemicals, reduced_formulas, list} = acc
      ) do
    IO.inspect(acc)
    new_formula = map_input_element_to_primary_reduction(output, reduced_formulas)
                  |> IO.inspect
    if is_fully_reduced?(new_formula, primary_chemicals) do
      {primary_chemicals, Map.put(reduced_formulas, chemical, {amount, new_formula}), [new_formula | list]}
    else
      {primary_chemicals, reduced_formulas, [formula | list]}
    end
  end

  def map_input_element_to_primary_reduction({chemical, amount}, reduced_formulas) do
    {Map.get(reduced_formulas, chemical, chemical), amount}
  end

  def is_fully_reduced?(formula, primary_chemicals) do
    formula_chemicals = formula
                        |> Utils.nested_tuple_to_list
                        |> List.flatten
                        |> Enum.filter(&is_atom/1)
                        |> MapSet.new
                        |> MapSet.subset?(primary_chemicals)
  end

  def solve(input) do
    input
  end

  def get_required_fuel(cost_map, :ORE), do: 1
  def get_required_fuel(cost_map, current) do
    case Map.get(cost_map, current) do
      nil -> 0
      formula -> get_fuel_for_formula(formula, cost_map, current)
    end
  end

  def sum_primary_reagents(x, acc) do

  end

  def get_fuel_for_formula({amount_produced, reagents}, cost_map, current) do
    result = reagents
    |> Enum.map(
         fn {chem, cost} ->
            (cost * get_required_fuel(cost_map, chem)) / amount_produced
         end
       )
    |> Enum.sum

    IO.puts("for: #{current} (#{inspect(reagents)}) cost: #{result}")
    result
  end
end
