defmodule Day15 do
  @moduledoc false

  def real_input do
    Utils.get_input(15, 1)
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

  def solve(input) do
    input
    |> generate_map
    |> digraph_shortest_path
    |> Kernel.-(1)
  end

  def solve2(input) do
    grid = generate_map(input)
  end

  def get_random_path(length) do
    Stream.repeatedly(
      fn ->
        [1, 2, 3, 4]
        |> Enum.random
      end
    )
    |> Enum.take(length)
  end

  def found_ox(path) do
    Enum.any?(path, fn {_, outcome} -> outcome == 2 end)
  end

  def move_results_to_map(results) do
    results
    |> Enum.reduce({{0, 0}, %{}}, &results_reducer/2)
  end

  def translate(1, {x, y}), do: {x, y + 1}
  def translate(2, {x, y}), do: {x, y - 1}
  def translate(3, {x, y}), do: {x - 1, y}
  def translate(4, {x, y}), do: {x + 1, y}

  def turn(direction) do
    Enum.random([1, 2, 3, 4])
  end

  def results_reducer({dir, outcome}, {current_pos, all_positions}) do
    attempted_pos = translate(dir, current_pos)
    case outcome do
      0 -> {current_pos, Map.put(all_positions, attempted_pos, :wall)}
      1 -> {attempted_pos, Map.put(all_positions, attempted_pos, :open)}
      2 -> {attempted_pos, Map.put(all_positions, attempted_pos, :ox)}
    end
  end

  def generate_map(program) do
    name = Intcode.Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Intcode.Computer.set_memory(name, program)

    results = smart_move(name, {0, 0}, 1, 1, %{})
  end

  def get_shortest_path(grid) do
    Utils.Graph.bfs(
      {0, 0},
      fn v ->
        if Map.get(grid, v) == :ox do
          []
        else
          [1, 2, 3, 4]
          |> Enum.map(&translate(&1, v))
          |> Enum.filter(fn pos -> Map.get(grid, pos) != :wall end)
        end
      end
    )
  end

  def goal(grid) do
    grid
    |> Map.to_list
    |> Enum.filter(fn {pos, state} -> state == :ox end)
    |> hd
    |> elem(0)
  end

  def neighbors(current_pos, grid) do
    cond do
      Map.get(grid, current_pos) == :wall -> []
      true ->
        [1, 2, 3, 4]
        |> Enum.map(&translate(&1, current_pos))
        |> Enum.filter(fn pos -> Map.get(grid, pos) in [:ox, :open] end)
    end
  end

  def grid_to_graph(grid) do
    g = :digraph.new()

    grid
    |> Map.keys
    |> Enum.flat_map(
         fn pos ->
           neighbors(pos, grid)
           |> Enum.map(&{pos, &1})
         end
       )
    |> Enum.each(
         fn {a, b} ->
           :digraph.add_vertex(g, a)
           :digraph.add_vertex(g, b)
           :digraph.add_edge(g, a, b)
           :digraph.add_edge(g, b, a)
         end
       )
  end

  def digraph_shortest_path(grid), do: nil
#
#    goal = goal(grid)
#    :digraph.get_short_path(g, {0, 0}, goal) |> length
#  end

  @doc"""
  if our last outcome moved us to a new square, we'll travel to the next open or unvisited square
  turning clockwise util we find a open or unvisited square
  """
  def determine_next_move(current_pos, last_move, last_outcome, visited) do
    potential_next = translate(last_move, current_pos)
    case Map.get(visited, potential_next) do
      :wall -> determine_next_move(current_pos, turn(last_move), 0, visited)
      _ -> turn(last_move)
    end
  end

  def determine_next_move2(current_pos, last_move, last_outcome, visited) do
    possible_nexts = Enum.filter(
                       [1, 2, 3, 4],
                       fn move ->
                         pos = translate(move, current_pos)
                         Map.get(visited, pos) != :wall
                       end
                     )
                     |> Enum.random
  end

  def smart_move(name, current_pos, last_move, last_outcome, visited) do
#        print_screen(visited |> Map.put(current_pos, :current)) |>  IO.puts
    #    IO.inspect({name, current_pos, last_move, last_outcome, visited})
    next_move = determine_next_move2(current_pos, last_move, last_outcome, visited)
    Intcode.Computer.IO.push_input(name, next_move)
    Intcode.Computer.run(name)
    output = Intcode.Computer.IO.pop_output(name)
    next_pos = translate(next_move, current_pos)

    case output do
      2 -> Map.put(visited, next_pos, :ox)
      1 -> smart_move(name, next_pos, next_move, output, Map.put(visited, next_pos, :open))
      0 -> smart_move(name, current_pos, next_move, output, Map.put(visited, next_pos, :wall))
    end
  end

  def move(name, [current | rest], outputs) do
    Intcode.Computer.IO.push_input(name, current)
    Intcode.Computer.run(name)
    output = Intcode.Computer.IO.pop_output(name)
    moves = if output == 0 and length(rest) > 0, do: tl(rest), else: rest
    move(name, moves, [{current, output} | outputs])
  end

  def move(name, [], output) do
    output
  end

  def render_tile(tile) do
    import IO.ANSI

    case tile do
      :start -> "O"
      :wall -> "█" <> black()
      :path -> "█" <> white()
      :open -> " "
      :ox -> "█" <> white()
      _ -> "█" <> red()
    end
  end

  def print_screen(screen) do
    import IO.ANSI

    size = 50

    {{minx, miny}, {maxx, maxy}} = screen
                                   |> Map.keys
                                   |> Enum.min_max

    string_screen = -20..20
                    |> Enum.map(
                         fn y ->
                           -20..20
                           |> Enum.map(
                                fn x ->
                                  Map.get(screen, {x, y})
                                  |> render_tile
                                end
                              )
                           |> Enum.join("")
                         end
                       )
                    |> Enum.join("\n")


    lines = String.split(string_screen) |> length
    padding = (for x <- 1..size - lines, do: "+\n") |> Enum.join
    string_screen
  end
end
