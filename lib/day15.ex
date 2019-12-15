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
  def solve2(input), do: solve(input)

  def parse_input(input) do
    input |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    input
  end

  def get_random_path(length) do
    Stream.repeatedly(fn -> [1, 2, 3, 4] |> Enum.random end) |> Enum.take(length)
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

  def results_reducer({dir, outcome}, {current_pos, all_positions}) do
    attempted_pos = translate(dir, current_pos)
    case outcome do
      0 -> {current_pos, Map.put(all_positions, attempted_pos, :wall)}
      1 -> {attempted_pos, Map.put(all_positions, attempted_pos, :open)}
      2 -> {attempted_pos, Map.put(all_positions, attempted_pos, :ox)}
    end
  end

  def generate_map(program, path) do
    name = Intcode.Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Intcode.Computer.set_memory(name, program)

    results = move(name, path, [])
  end

  def move_smart(name, current_pos, last_move, visited) do

  end

  def move(name, [current | rest ], outputs) do
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
    case tile do
      :wall -> "█"
      :open -> " "
      :ox -> "X"
      _ -> "?"
    end
  end

  def print_screen(screen) do
    {{minx, miny}, {maxx, maxy}} = screen
                                   |> Map.keys
                                   |> Enum.min_max
    string_screen = miny - 1..maxy + 1
                    |> Enum.map(
                         fn y ->
                           minx..maxx
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


    string_screen <> "\n\n"
  end
end
