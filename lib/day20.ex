defmodule Day20 do
  @moduledoc false

  def real_input do
    Utils.get_input(20, 1)
  end

  def samples do
    [
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
      """,
      """
                             A
                             A
            #################.#############
            #.#...#...................#.#.#
            #.#.#.###.###.###.#########.#.#
            #.#.#.......#...#.....#.#.#...#
            #.#########.###.#####.#.#.###.#
            #.............#.#.....#.......#
            ###.###########.###.#####.#.#.#
            #.....#        A   C    #.#.#.#
            #######        S   P    #####.#
            #.#...#                 #......VT
            #.#.#.#                 #.#####
            #...#.#               YN....#.#
            #.###.#                 #####.#
          DI....#.#                 #.....#
            #####.#                 #.###.#
          ZZ......#               QG....#..AS
            ###.###                 #######
          JO..#.#.#                 #.....#
            #.#.#.#                 ###.#.#
            #...#..DI             BU....#..LF
            #####.#                 #.#####
          YN......#               VT..#....QG
            #.###.#                 #.###.#
            #.#...#                 #.....#
            ###.###    J L     J    #.#.###
            #.....#    O F     P    #.#...#
            #.###.#####.#.#####.#####.###.#
            #...#.#.#...#.....#.....#.#...#
            #.#####.###.###.#.#.#########.#
            #...#.#.....#...#.#.#.#.....#.#
            #.###.#####.###.###.#.#.#######
            #.#.........#...#.............#
            #########.###.###.#############
                     B   J   C
                     U   P   P
      """
    ]
  end

  def sample_input do
    Enum.at(samples, 0)
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
    |> Enum.map(
         fn
           "#" -> :wall
           "." -> :open
           " " -> :blank
           x -> {:portal_part, x}
         end
       )
  end

  def choose_portal_connection(p1, p2, maze) do
    p = if has_open_neighbor?(p1, maze), do: p1, else: p2
  end

  def choose_portal_connection2(p1, p2, maze) do
    p = if has_open_neighbor?(p1, maze), do: {p1, :inner}, else: {p2, :outer}
  end

  def get_inner_and_outer_mapping({portal_name, connections}, maze) do
    index_map = portal_name
                |> String.graphemes
                |> Stream.with_index
                |> Enum.into(%{})
    connections
    |> Enum.map(
         fn pos ->
           {:portal_part, letter} = Map.get(maze, pos)
           {{portal_name, pos}, (if Map.get(index_map, letter) == 0, do: :inner, else: :outer)}
         end
       )
  end

  def condense_portals(maze) do
    portal_parts = maze
                   |> Map.to_list
                   |> Enum.filter(
                        fn
                          {k, {:portal_part, _}} -> true
                          _ -> false
                        end
                      )

    portals = portal_parts
              |> Enum.map(
                   fn part ->
                     [part, find_adjacent_part(part, portal_parts)]
                     |> Enum.sort
                   end
                 )
              |> Enum.uniq
              |> Enum.map(fn [{p1, {_, l1}}, {p2, {_, l2}}] -> {p1, p2, l1 <> l2} end)
              |> Enum.map(fn {p1, p2, name} -> {choose_portal_connection(p1, p2, maze), name} end)
              |> Enum.into(%{})

    portal_neighbors = portals
                       |> Map.to_list
                       |> Enum.group_by(fn {k, v} -> v end, &elem(&1, 0))


    inner_outer_mapping = portal_neighbors
                          |> Enum.flat_map(&get_inner_and_outer_mapping(&1, maze))
                          |> Enum.into(%{})

    maze
    |> Map.merge(portal_neighbors)
    |> Map.merge(portals)
    |> Map.merge(inner_outer_mapping)
  end

  def find_adjacent_part({point, _}, parts) do
    parts_map = Enum.into(parts, %{})
    neighbors = 1..4
                |> Enum.map(&translate(&1, point))
    neighbor = Enum.find(neighbors, &Map.get(parts_map, &1))
    {neighbor, Map.get(parts_map, neighbor)}
  end

  def translate(1, {x, y}), do: {x, y + 1}
  def translate(2, {x, y}), do: {x, y - 1}
  def translate(3, {x, y}), do: {x - 1, y}
  def translate(4, {x, y}), do: {x + 1, y}

  def neighboring_points(pos) do
    [1, 2, 3, 4]
    |> Enum.map(&translate(&1, pos))
  end

  def neighboring_points2({pos, level}) do
    [1, 2, 3, 4]
    |> Enum.map(&translate(&1, pos))
    |> Enum.map(fn p -> {p, level} end)
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
      portal when is_binary(portal) ->
        Map.get(maze, portal)
        |> Enum.flat_map(&get_neighbors(&1, maze))
        |> Enum.map(
             fn point ->
               neighboring_points(point)
               |> Enum.map(&{Map.get(maze, &1, &1)})
               |> Enum.map(&Map.get(maze, &1))
               |> IO.inspect

               point
             end
           )
      _ ->
        [pos]
    end
  end

  def self_plus_portal_neighbors2({pos, level}, maze) do
    case Map.get(maze, pos) do
      portal when is_binary(portal) ->
        Map.get(maze, portal)
        |> Enum.flat_map(&get_neighbors(&1, maze))
        |> Enum.map(
             fn point ->
               Map.get(maze, point)
               |> IO.inspect
               point
             end
           )
      _ ->
        [{pos, level}]
    end
  end

  def has_open_neighbor?(pos, maze) do
    neighboring_points(pos)
    |> Enum.map(&Map.get(maze, &1, :wall))
    |> Enum.any?(fn type -> type == :open end)
  end


  @doc"""
  typical neighboring points, plus any portal moves if a neighbor is a portal

  here state is a {pos, level} tuple, where need to consider the "AA" and "ZZ" portals only if
  state is {pos, 0}
  """
  def get_neighbors2({pos, level}, maze) do
    neighboring_points2(pos)
    |> Enum.flat_map(&self_plus_portal_neighbors2(&1, maze))
    |> Enum.reject(& &1 == pos)
    |> Enum.filter(fn p -> Map.get(maze, p) == :open end)
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
    maze = input
           |> condense_portals
    start = Map.get(maze, "AA")
            |> hd
            |> get_neighbors(maze)
            |> hd
    goal = Map.get(maze, "ZZ")
           |> hd
           |> get_neighbors(maze)
           |> hd

    {_, paths} = Utils.Graph.bfs(
      start,
      fn
        ^goal -> []
        pos -> get_neighbors(pos, maze)
      end
    )

    path = Utils.Graph.get_path(paths, goal)

    path_maze = Enum.reduce(path, maze, fn x, acc -> Map.put(acc, x, :path) end)
    print_maze(maze, path)
    |> IO.puts

    length(path) - 1

    maze
  end

  def render_tile(tile) do
    case tile do
      :wall -> "#"
      :open -> "."
      :blank -> " "
      :path -> "+"
      {:portal_part, _} -> " "
      x -> String.slice(x, 0..0)
    end
  end
  def print_maze(maze, path) do
    combined = path
               |> Enum.reduce(maze, fn point, acc -> Map.put(acc, point, :path) end)

    {miny, maxy} = maze
                   |> Map.keys
                   |> Enum.filter(&is_tuple/1)
                   |> Enum.reject(fn {a, b} -> is_binary(a) end)
                   |> Enum.map(fn {x, y} -> y end)
                   |> Enum.min_max
    {minx, maxx} = maze
                   |> Map.keys
                   |> Enum.filter(&is_tuple/1)
                   |> Enum.reject(fn {a, b} -> is_binary(a) end)
                   |> Enum.map(fn {x, y} -> x end)
                   |> Enum.min_max

    string_screen = miny - 1..maxy + 1
                    |> Enum.map(
                         fn y ->
                           minx..maxx
                           |> Enum.map(
                                fn x ->
                                  Map.get(combined, {x, y})
                                  |> render_tile
                                end
                              )
                           |> Enum.join("")
                         end
                       )
                    |> Enum.join("\n")


    string_screen <> "\n\n"
  end
end
