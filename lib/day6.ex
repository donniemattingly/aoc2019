defmodule Day6 do
  @moduledoc false

  def real_input do
    Utils.get_input(6, 1)
  end

  def sample_input do
    """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """
  end

  def sample_input2 do
    """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    K)YOU
    I)SAN
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
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [a, b] = String.split(line, ")")
    {b, a}
  end

  def solve(input) do
    map = input
          |> Enum.into(%{})
    Map.keys(map)
    |> Enum.map(
         fn k ->
           Utils.Graph.get_path(map, k)
           |> length
         end
       )
    |> Enum.sum
  end

  def solve2(input) do
    map = input
          |> Enum.into(%{})

    reversed_map = map
                   |> Map.to_list
                   |> Enum.reduce(
                        %{},
                        fn {k, v}, acc ->
                          acc
                          |> Map.update(v, MapSet.new([k]), &MapSet.put(&1, k))
                          |> Map.update(k, MapSet.new([v]), &MapSet.put(&1, v))
                        end
                      )


    {map, reversed_map}
    {_q, paths_map} = Utils.Graph.bfs("SAN", fn x ->
      if x == "YOU" do
        []
      else
        Map.get(reversed_map, x, [])
      end
    end)

    path = Utils.Graph.get_path(paths_map, "YOU")

    length(path) - 3
  end

end
