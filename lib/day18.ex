defmodule Day18 do
  @moduledoc false

  def real_input do
    Utils.get_input(18, 1)
  end

  def sample_input do
    """
    ########################
    #...............b.C.D.f#
    #.######################
    #.....@.a.B.c.d.A.e.F.g#
    ########################
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
    |> Utils.list_of_lists_to_map_by_point
  end

  def parse_line(line) do
    line
    |> String.graphemes
    |> Enum.map(fn
      "#" -> :wall
      "." -> :open
      "@" -> :start
      char -> if String.upcase(char) == char, do: {:door, char}, else: {:key, String.upcase(char)}
    end)
  end

  def translate(1, {x, y}), do: {x, y + 1}
  def translate(2, {x, y}), do: {x, y - 1}
  def translate(3, {x, y}), do: {x - 1, y}
  def translate(4, {x, y}), do: {x + 1, y}

  def neighboring_points(pos) do
    [1, 2, 3, 4] |> Enum.map(&translate(&1, pos))
  end

  def is_key?({:key, _}), do: true
  def is_key?(_), do: false

  def can_visit?(:wall, _), do: false
  def can_visit?(:open, _), do: true
  def can_visit?({:key, _}, _), do: true
  def can_visit?({:door, door}, keys), do: door in keys

  def move_to_pos(keys, new_pos, {:key, key}) do
    {MapSet.put(keys, key), new_pos}
  end

  def move_to_pos(keys, new_pos, _) do
    {keys, new_pos}
  end

  @doc"""
  State here is a list of obtained keys and the current position. You can only move into a position w/ a door (i.e.
  it's a neighbor) if we have the key.
  """
  def neighbors_fn({keys, pos}, map) do
    pos
    |> neighboring_points
    |> Enum.map(fn new_pos -> {new_pos, Map.get(map, new_pos, :wall)} end)
    |> Enum.filter(fn {new_pos, type} -> can_visit?(type, keys) end)
    |> Enum.map(fn {new_pos, type} -> move_to_pos(keys, new_pos, type) end)
  end

  def start(input_map) do
    start_point = input_map |> Map.to_list |> Enum.find(fn {k, v} -> v == :start end) |> elem(0)
    num_keys = input_map |> Map.to_list |> Enum.filter(fn {k, v} ->  is_key?(v) end) |> length
    {start_point, num_keys, Map.put(input_map, start_point, :open)}
  end

  def find_end_node(paths_map, num_keys) do
    paths_map |> Map.keys |> Enum.find(fn {k, v} -> MapSet.size(k) == num_keys end)
  end

  def solve(input) do
    {start_point, num_keys, map} = start(input)
    {_, graph} = Utils.Graph.bfs({MapSet.new, start_point}, fn {keys, pos} ->
      cond do
        MapSet.size(keys) == num_keys -> []
        true -> neighbors_fn({keys, pos}, map)
      end
    end)

    goal = find_end_node(graph, num_keys)


#    length(path) - 1

    path = Utils.Graph.get_path(graph, goal) |> IO.inspect
  end
end
