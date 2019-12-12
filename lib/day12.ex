defmodule Day12 do
  @moduledoc false


  def samples do
    [
      """
      <x=-1, y=0, z=2>
      <x=2, y=-10, z=-7>
      <x=4, y=-8, z=8>
      <x=3, y=5, z=-1>
      """,
      """
      <x=-8, y=-10, z=0>
      <x=5, y=5, z=10>
      <x=2, y=-7, z=3>
      <x=9, y=-8, z=-3>
      """
    ]
  end

  def real_input do
    """
    <x=4, y=1, z=1>
    <x=11, y=-18, z=-1>
    <x=-2, y=-10, z=-4>
    <x=-7, y=-2, z=14>
    """
  end

  def sample_input do
    Enum.at(samples, 1)
  end

  def sample_input2 do
    Enum.at(samples, 0)
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
    [_, {x, _}, {y, _}, {z, _}] = String.split(line, "=")
                                  |> Enum.map(&Integer.parse/1)
    %{x: x, y: y, z: z, dx: 0, dy: 0, dz: 0}
  end

  def time_step(moons) do
    moons
    |> apply_gravity
    |> update_velocity
  end

  def apply_gravity(moons) do
    moons
    |> Enum.map(&apply_gravity_for_moon(&1, moons))
  end

  def apply_gravity_for_moon(moon, moons) do
    {x, y, z} = moons
                |> Enum.map(&do_apply_gravity(moon, &1))
                |> Enum.reduce(
                     {0, 0, 0},
                     fn {ddx, ddy, ddz}, {accx, accy, accz} ->
                       {accx + ddx, accy + ddy, accz + ddz}
                     end
                   )
    moon
    |> Map.update(:dx, x, &(&1 + x))
    |> Map.update(:dy, y, &(&1 + y))
    |> Map.update(:dz, z, &(&1 + z))
  end

  defp do_apply_gravity(m1, m2) do
    ddx = cond do
      m1.x > m2.x -> -1
      m1.x == m2.x -> 0
      m2.x > m1.x -> 1
    end

    ddy = cond do
      m1.y > m2.y -> -1
      m1.y == m2.y -> 0
      m2.y > m1.y -> 1
    end

    ddz = cond do
      m1.z > m2.z -> -1
      m1.z == m2.z -> 0
      m2.z > m1.z -> 1
    end

    {ddx, ddy, ddz}
  end

  def update_velocity(moons) do
    moons
    |> Enum.map(
         fn %{x: x, y: y, z: z, dx: dx, dy: dy, dz: dz} = moon ->
           moon
           |> Map.update(:x, dx, &(&1 + dx))
           |> Map.update(:y, dy, &(&1 + dy))
           |> Map.update(:z, dz, &(&1 + dz))
         end
       )
  end

  def potential_energy(moon) do
    abs(moon.x) + abs(moon.y) + abs(moon.z)
  end

  def kinetic_energy(moon) do
    abs(moon.dx) + abs(moon.dy) + abs(moon.dz)
  end

  def total_energy(moon) do
    potential_energy(moon) * kinetic_energy(moon)
  end

  def display_step(moons, count) do
    IO.puts("After #{count} steps")
    moons
    |> Enum.map(
         fn moon -> "pos=<x= #{moon.x}, y= #{moon.y}, z= #{moon.z}>, vel=<x= #{moon.dx}, y= #{moon.dy}, z= #{moon.dz}>"
         end
       )
    |> Enum.each(&IO.puts/1)

    moons
  end

  def time_steps(moons, 0), do: moons
  def time_steps(moons, count),
      do: moons
          |> time_step
          |> display_step(count)
          |> time_steps(count - 1)

  def solve(input) do
    time_steps(input, 1000)
    |> Enum.map(&total_energy/1)
    |> Enum.sum
  end

  def solve2(input) do
    x_repeats = steps_till_axis_repeats(input, 0, MapSet.new(), :x) |> IO.inspect
    y_repeats = steps_till_axis_repeats(input, 0, MapSet.new(), :y) |> IO.inspect
    z_repeats = steps_till_axis_repeats(input, 0, MapSet.new(), :z) |> IO.inspect

    # wolfram alpha for least common multiple, i.e. first step where all are on cycle
  end

  def time_steps_with_hist(moons, count, hist) do
    new_moons = moons |> time_step
    cond do
      MapSet.member?(hist, new_moons) -> count
      true -> time_steps_with_hist(new_moons, count + 1, MapSet.put(hist, new_moons))
    end
  end

  def to_vel(axis) do
    "d#{to_string(axis)}" |> String.to_atom
  end

  def steps_till_axis_repeats(moons, count, hist, axis) do
    new_moons = moons |> time_step
    axes = new_moons |> Enum.map(&{Map.get(&1, axis), Map.get(&1, to_vel(axis))})
    cond do
      MapSet.member?(hist, axes) -> count
      true -> steps_till_axis_repeats(new_moons, count + 1, MapSet.put(hist, axes), axis)
    end
  end

end
