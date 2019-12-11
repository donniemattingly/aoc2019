defmodule Day11 do
  @moduledoc false

  alias Intcode.Computer

  def real_input do
    Utils.get_input(11, 1)
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
    Intcode.Supervisor.start_computer(:painter)
    Computer.set_memory(:painter, input)
    Computer.IO.reset(:painter)
    paint(:painter, %{}, {0, 0}, :up)
    |> Map.keys
    |> length
  end

  def pretty(x) do
    case x do
      1 -> "█"
      0 -> " "
    end
  end

  def solve2(input) do
    Intcode.Supervisor.start_computer(:painter)
    Computer.set_memory(:painter, input)
    Computer.IO.reset(:painter)
    map = paint(:painter, %{{0, 0} => 1}, {0, 0}, :up)
    {{minx, miny}, {maxx, maxy}} = map |> Map.keys |> Enum.min_max
    maxy+1..miny-1
    |> Enum.map(fn y ->
      minx..maxx
      |> Enum.map(fn x ->
        Map.get(map, {x, y}, 0) |> pretty
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end

  def turn(:up, 0, {x, y}), do: {:left, {x - 1, y}}
  def turn(:up, 1, {x, y}), do: {:right, {x + 1, y}}

  def turn(:right, 0, {x, y}), do: {:up, {x, y + 1}}
  def turn(:right, 1, {x, y}), do: {:down, {x, y - 1}}

  def turn(:down, 0, {x, y}), do: {:right, {x + 1, y}}
  def turn(:down, 1, {x, y}), do: {:left, {x - 1, y}}

  def turn(:left, 0, {x, y}), do: {:down, {x, y - 1}}
  def turn(:left, 1, {x, y}), do: {:up, {x, y + 1}}

  def hull_color(hull, position) do
    Map.get(hull, position, 0)
  end

  def paint(name, hull, position, direction) do
    Computer.IO.push_input(name, hull_color(hull, position))
    case Computer.run(name) do
      {:waiting, val} ->
        color = Computer.IO.dequeue_output(name)
        dir = Computer.IO.dequeue_output(name)
        new_hull = Map.put(hull, position, color)
        {new_direction, new_position} = turn(direction, dir, position)
        paint(name, new_hull, new_position, new_direction)
      {:finished, val} -> hull
    end
  end
end
