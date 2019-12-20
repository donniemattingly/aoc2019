defmodule Day19 do
  @moduledoc false

  @computer_name "test"

  def real_input do
    Utils.get_input(19, 1)
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

  def solve1(input), do: solve(input, 1)
  def solve2(input), do: solve(input, 1)

  def parse_input(input) do
    input
    |> String.trim
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def square(program, last_)

  def find_square_of_size(program, current_points, iter, size) do
    potential_points = for n <- 0..iter, do: [{iter, n}, {n, iter}]

    new_points = potential_points
                 |> List.flatten
                 |> Enum.map(
                      fn point ->
                        {
                          point,
                          in_tractor_beam(program, point)
                          |> hd
                        }
                      end
                    )
                 |> Enum.filter(fn {p, x} -> x == 1 end)
                 |> Enum.map(&elem(&1, 0))
                 |> MapSet.new
                 |> MapSet.union(current_points)

    case get_top_right_corner_of_square(new_points, size) do
      nil -> find_square_of_size(program, new_points, iter + 1, size)
      {x, y} -> {{x - size, y}, iter, new_points}
    end
  end

  def get_top_right_corner_of_square(points_set, size) do
    real = size - 1
    points_set
    |> Enum.find(
         fn {x, y} ->
           [{x, y}, {x, y + real}, {x + real, y + real}, {x + real, y}]
           |> MapSet.new
           |> MapSet.subset?(points_set)
         end
       )
  end

  def run(size) do
    real_input
    |> parse_input
    |> solve(size)
  end

  def solve(input, size) do
    Intcode.Supervisor.start_computer(@computer_name)
    {point, size, points} = find_square_of_size(input, MapSet.new(), 0, size)
    print_screen(points, size)
    |> IO.puts
    IO.inspect(point)
  end

  def in_tractor_beam(program, {x, y}) do
    alias Intcode.Computer

    Computer.set_memory(@computer_name, program)
    Computer.IO.reset(@computer_name)
    Computer.IO.push_input(@computer_name, x)
    Computer.IO.push_input(@computer_name, y)
    Computer.run(@computer_name)
    output = Computer.IO.dump_state(@computer_name)
             |> Keyword.get(:output)
             |> Enum.reverse
  end

  def render_tile(0), do: " "
  def render_tile(1), do: "#"

  def print_screen(screen, size) do
    0..size - 1
    |> Enum.map(
         fn y ->
           0..size - 1
           |> Enum.map(
                fn x ->
                  if MapSet.member?(screen, {x, y}), do: "#", else: " "
                end
              )
           |> Enum.join("")
         end
       )
    |> Enum.join("\n")
  end
end
