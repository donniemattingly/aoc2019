defmodule Day17 do
  @moduledoc false

  def real_input do
    Utils.get_input(17, 1)
  end

  def sample_scaffolding do
    """
    ..#..........
    ..#..........
    #######...###
    #.#...#...#.#
    #############
    ..#...#...#..
    ..#####...#..
    """
  end

  def sample_input do
    """
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
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve(program) do
    scaffolding = program
                  |> get_scaffolding

    IO.puts(scaffolding)

    scaffolding_set = scaffolding
                      |> scaffolding_string_to_set_of_points

    intersections = scaffolding_set
                    |> get_intersections

    print_scaffolding(scaffolding_set, intersections)
    |> IO.puts

    intersections
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum
  end

  def solve2(program) do
    get_path(program)
  end

  def render_tile(tile) do
    import IO.ANSI
    case tile do
      :path -> white() <> "█"
      :intersection -> green() <> "█"
      :start -> red() <> "█"
      nil -> white() <> " "
    end
  end

  def print_scaffolding(scaffolding_set, intersections) do
    map = scaffolding_set
          |> Enum.map(fn p -> {p, :path} end)
          |> Enum.into(%{})
          |> IO.inspect

    print_map = intersections
                |> Enum.reduce(map, fn x, acc -> Map.put(acc, x, :intersection) end)
                |> IO.inspect

    {{minx, miny}, {maxx, maxy}} = print_map
                                   |> Map.keys
                                   |> Enum.min_max

    minx = miny = 0
    maxx = 60
    maxy = 33

    string_screen = miny - 1..maxy + 1
                    |> Enum.map(
                         fn y ->
                           minx..maxx
                           |> Enum.map(
                                fn x ->
                                  Map.get(print_map, {x, y})
                                  |> render_tile
                                end
                              )
                           |> Enum.join("")
                         end
                       )
                    |> Enum.join("\n")


    string_screen <> "\n\n"
  end

  def scaffolding_string_to_set_of_points(scaffolding) do
    str = scaffolding |> to_string

    IO.puts(str)

    str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_scaffolding_row/1)
    |> Utils.list_of_lists_to_map_by_point
    |> Map.to_list
    |> Enum.filter(fn {point, space} -> space == :scaffold  || space == :start end)
    |> Enum.map(&elem(&1, 0))
    |> MapSet.new
  end

  def parse_scaffolding_row(row) do
    row
    |> String.split("", trim: true)
    |> Enum.map(fn
      "#" -> :scaffold
      "^" -> :start
      _ -> :space
    end)
  end

  def set_of_neighbors({x, y}) do
    MapSet.new(
      [
        {x + 1, y},
        {x - 1, y},
        {x, y - 1},
        {x, y + 1}
      ]
    )
  end

  @doc"""
  A point is an intersection if the set of neighboring points in a subset of the
  set of points
  """
  def is_intersection?(point, points) do
    point
    |> set_of_neighbors
    |> MapSet.subset?(points)
  end

  def get_intersections(set_of_points) do
    set_of_points
    |> Enum.filter(&is_intersection?(&1, set_of_points))
  end

  def get_scaffolding(program) do
    alias Intcode.Computer
    name = Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Computer.set_memory(name, program)
    Computer.run(name)
    output = Computer.IO.dump_state(name)
             |> Keyword.get(:output)
             |> Enum.reverse
  end

  def get_path(program) do
    main = 'A,A,B,C,B,C,B,A,C,A'
    funcs = [
      ['R,8', 44, 'L,12', 44, 'R,8'],
      ['L,10', 44, 'L,10', 44, 'R,8'],
      ['L,12', 44, 'L,12', 44, 'L,10', 44, 'R,10']
    ]
    program = List.replace_at(program, 0, 2)
    alias Intcode.Computer
    name = Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Computer.set_memory(name, program)
    Computer.run(name)
    output = Computer.IO.dump_state(name)
             |> Keyword.get(:output)
             |> Enum.reverse
  end
end
