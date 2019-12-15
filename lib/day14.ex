defmodule Day14 do
  @moduledoc false

  def real_input do
    Utils.get_input(14, 1)
  end

  def samples do
    [
      """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
      """,
      """
      9 ORE => 2 A
      8 ORE => 3 B
      7 ORE => 5 C
      3 A, 4 B => 1 AB
      5 B, 7 C => 1 BC
      4 C, 1 A => 1 CA
      2 AB, 3 BC, 4 CA => 1 FUEL
      """,
      """
      157 ORE => 5 NZVS
      165 ORE => 6 DCFZ
      44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
      12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
      179 ORE => 7 PSHF
      177 ORE => 5 HKGWZ
      7 DCFZ, 7 PSHF => 2 XJWVT
      165 ORE => 2 GPVTF
      3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
      """,
      """
      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF
      """,
      """
      171 ORE => 8 CNZTR
      7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
      114 ORE => 4 BHXH
      14 VRPVC => 6 BMBT
      6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
      6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
      15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
      13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
      5 BMBT => 4 WPTQ
      189 ORE => 9 KTJDG
      1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
      12 VRPVC, 27 CNZTR => 2 XDBXC
      15 KTJDG, 12 BHXH => 5 XCVML
      3 BHXH, 2 VRPVC => 7 MZWV
      121 ORE => 7 VRPVC
      7 XCVML => 6 RJRHP
      5 BHXH, 4 VRPVC => 5 LTCX
      """
    ]
  end

  def sample_input(sample_no \\ 0) do
    Enum.at(samples, sample_no)
  end

  def sample_input2 do
    """
    """
  end

  def sample(sample_no \\ 0) do
    sample_input(sample_no)
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
    new_formula = map_input_element_to_primary_reduction(output, reduced_formulas)
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
    primaries = get_primaries(input)
    fuel_costs = input
                 |> group_by_origin
                 |> Map.get(:derived)
                 |> costs_list_to_map
                 |> get_required_fuel(:FUEL)

    get_ore_cost(primaries, fuel_costs)
  end

  def get_required_fuel(cost_map, :ORE), do: 1
  def get_required_fuel(cost_map, current) do
    case Map.get(cost_map, current) do
      nil -> 1
      formula -> get_fuel_for_formula(formula, cost_map, current)
    end
  end

  def sum_primary_reagents({name, amount}, acc) do
    Map.update(acc, name, amount, & &1 + amount)
  end

  def map_cost(cost, fun) when is_map(cost) do
    Map.to_list(cost)
    |> Enum.map(fn {k, v} -> {k, fun.(v)} end)
    |> Enum.into(%{})
  end

  def map_cost(cost, fun) when is_number(cost) do
    fun.(cost)
  end

  def flatten(map) when is_map(map) do
    map
    |> to_list_of_tuples
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)
    |> Map.new
  end

  defp to_list_of_tuples(m) do
    m
    |> Enum.map(&process/1)
    |> List.flatten
  end

  defp process({key, sub_map}) when is_map(sub_map) do
    Map.to_list(sub_map)
  end

  defp process({key, value}) do
    {key, value}
  end

  def get_primaries(input) do
    input
    |> group_by_origin
    |> Map.get(:primary)
    |> Enum.map(&transform_primary/1)
    |> Map.new
  end

  def transform_primary({[ORE: ore], {reagent, increment}}) do
    {reagent, %{increment: increment, ore: ore}}
  end

  def get_ore_cost(primaries, fuel) do
    fuel
    |> Enum.map(
         fn {reagent, amount} ->
           (amount / get_in(primaries, [reagent, :increment]))
           |> ceil
           |> Kernel.*(get_in(primaries, [reagent, :ore]))
         end
       )
    |> Enum.sum
  end

  def get_fuel_for_formula({amount_produced, reagents}, cost_map, current) do
    result = reagents
             |> Enum.map(
                  fn {chem, cost} ->
                    {
                      chem,
                      get_required_fuel(cost_map, chem)
                      |> map_cost(fn x -> (cost * x) / amount_produced end)
                    }
                  end
                )
             |> Enum.reduce(%{}, &sum_primary_reagents/2)
             |> flatten

    result
  end
end
