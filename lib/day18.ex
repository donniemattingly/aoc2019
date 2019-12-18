defmodule Day18 do
  @moduledoc false

  use Memoize

  def real_input do
    Utils.get_input(18, 1)
  end

  def real_input2 do
    Utils.get_input(18, 2)
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
    #############
    #DcBa.#.GhKl#
    #.###1#2#I###
    #e#d#####j#k#
    ###C#4#3###J#
    #fEbA.#.FgHi#
    #############
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

  def parse_input1(input), do: parse_input(input)
  def parse_input2(input), do: parse_input(input)

  def solve1(input), do: solve(input)

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
      "1" -> {:bot, 1}
      "2" -> {:bot, 2}
      "3" -> {:bot, 3}
      "4" -> {:bot, 4}
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

  def is_bot?({:bot, _}), do: true
  def is_bot?(_), do: false

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


  @doc"""
  Alright - state here is just the same as above, but we have 4 positions and only one can change at a time
  """
  def neighbors_fn2({keys, positions}, map) do
    positions
    |> Map.to_list
    |> Enum.map(fn {name, pos} -> {name, neighbors_fn({keys, pos}, map)} end)
    |> Enum.flat_map(fn {name, new_states} -> new_states |> Enum.map(fn {keys, pos} -> {keys, Map.put(positions, name, pos)} end) end)
  end

  def start(input_map) do
    start_point = input_map |> Map.to_list |> Enum.find(fn {k, v} -> v == :start end) |> elem(0)
    num_keys = input_map |> Map.to_list |> Enum.filter(fn {k, v} ->  is_key?(v) end) |> length
    {start_point, num_keys, Map.put(input_map, start_point, :open)}
  end

  def start2(input_map) do
    num_keys = input_map |> Map.to_list |> Enum.filter(fn {k, v} ->  is_key?(v) end) |> length
    bots = input_map |> Map.to_list |> Enum.filter(fn {k, v} ->  is_bot?(v) end) |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.put(acc, elem(v, 1), k)
    end)
    map = bots |> Map.values |> Enum.reduce(input_map, fn x, acc -> Map.put(acc, x, :open) end)
    {bots, num_keys, map}
  end

  def find_end_node(paths_map, num_keys) do
    paths_map |> Map.keys |> Enum.find(fn {k, v} -> MapSet.size(k) == num_keys end)
  end

  def shortest_path(paths, num_keys) do
    paths
    |> Map.keys
    |> Enum.filter(fn {k, v} -> MapSet.size(k) == num_keys end)
    |> Enum.map(&Utils.Graph.get_path(paths, &1))
    |> Enum.map(&length/1)
    |> Enum.min
  end

  def solve(input) do
    {start_point, num_keys, map} = start2(input)
    {_, graph} = Utils.Graph.bfs({MapSet.new, start_point}, fn {keys, pos} ->
      cond do
        MapSet.size(keys) == num_keys -> []
        true -> neighbors_fn({keys, pos}, map)
      end
    end)

    goal = find_end_node(graph, num_keys)

    shortest_path(graph, num_keys)
  end

  def solve2(input) do
    {bots, num_keys, map} = start2(input)
    {_, graph} = Utils.Graph.bfs({MapSet.new, bots}, fn {keys, pos} ->
      cond do
        MapSet.size(keys) == num_keys -> []
        true -> neighbors_fn2({keys, pos}, map)
      end
    end)

    goal = find_end_node(graph, num_keys)

    shortest_path(graph, num_keys)
  end
end
