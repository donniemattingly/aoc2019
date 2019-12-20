defmodule Day20 do
  @moduledoc false

  def real_input do
    Utils.get_input(20, 1)
  end

  def sample_input do
    """
             A
             A
      #######.#########
      #######.........#
      #######.#######.#
      #######.#######.#
      #######.#######.#
      #####  B    ###.#
    BC...##  C    ###.#
      ##.##       ###.#
      ##...DE  F  ###.#
      #####    G  ###.#
      #########.#####.#
    DE..#######...###.#
      #.#########.###.#
    FG..#########.....#
      ###########.#####
                 Z
                 Z
    """
  end

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
      " " -> :blank
      x -> {:portal_part, x}
    end)
  end

  def choose_portal_connection(p1, p2, maze) do
    if has_open_neighbor?(p1, maze), do: p1, else: p2
  end

  def condense_portals(maze) do
    portal_parts = maze |> Map.to_list |> Enum.filter(fn
      {k, {:portal_part, _}} -> true
      _ -> false
    end)

    portals = portal_parts
    |> Enum.map(fn part -> [part, find_adjacent_part(part, portal_parts)] |> Enum.sort end)
    |> Enum.uniq
    |> Enum.map(fn [{p1, {_, l1}}, {p2, {_, l2}}] -> {p1, p2, l1<>l2} end)
    |> Enum.map(fn {p1, p2, name} -> {choose_portal_connection(p1, p2, maze), name} end)
    |> Enum.into(%{})

    portal_neighbors = portals
    |> Map.to_list
    |> Enum.group_by(fn {k, v} -> v end, &elem(&1, 0))

    maze
    |> Map.merge(portal_neighbors)
    |> Map.merge(portals)
  end

  def find_adjacent_part({point, _}, parts) do
    parts_map = Enum.into(parts, %{})
    neighbors = 1..4 |> Enum.map(&translate(&1, point))
    neighbor = Enum.find(neighbors, &Map.get(parts_map, &1))
    {neighbor, Map.get(parts_map, neighbor)}
  end

  def translate(1, {x, y}), do: {x, y + 1}
  def translate(2, {x, y}), do: {x, y - 1}
  def translate(3, {x, y}), do: {x - 1, y}
  def translate(4, {x, y}), do: {x + 1, y}

  def neighboring_points(pos) do
    [1, 2, 3, 4] |> Enum.map(&translate(&1, pos))
  end

  @doc"""
  typical neighboring points, plus any portal moves if a neighbor is a portal
  """
  def get_neighbors(pos, maze) do
    neighboring_points(pos)
    |> Enum.flat_map(&self_plus_portal_neighbors(&1, maze))
    |> Enum.reject(& &1 == pos)
    |> Enum.filter(fn p -> Map.get(maze, p) == :open end)
  end

  def self_plus_portal_neighbors(pos, maze) do
    case Map.get(maze, pos) do
      portal when is_binary(portal) -> Map.get(maze, portal)
      _ -> [pos]
    end
  end

  def has_open_neighbor?(pos, maze) do
    neighboring_points(pos)
    |> Enum.map(&Map.get(maze, &1, :wall))
    |> Enum.any?(fn type -> type == :open end)
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
  end


  @doc"""
  note: i'm getting the path as though it's not following any portals, this likely
  has to do with how we're generating the neighbors in the case of portals
  """
  def solve(input) do
    maze = input |> condense_portals
    start = Map.get(maze, "AA") |> hd |> get_neighbors(maze) |> hd
    goal = Map.get(maze, "ZZ") |> hd |> get_neighbors(maze) |> hd
    {_, paths} = Utils.Graph.bfs(start, fn
      ^goal -> []
      pos -> get_neighbors(pos, maze)
    end)

    path = Utils.Graph.get_path(paths, goal)

    length(path) - 1
  end
end
