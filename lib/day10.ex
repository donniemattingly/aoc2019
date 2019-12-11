defmodule Day10 do
  @moduledoc false

  @undefined_slope 100
  @bool_sort_factor 10000

  def real_input do
    Utils.get_input(10, 1)
  end

  def samples do
    [
      """
      .#..#
      .....
      #####
      ....#
      ...##
      """,
      """
      ......#.#.
      #..#.#....
      ..#######.
      .#.#.###..
      .#..#.....
      ..#....#.#
      #..#....#.
      .##.#..###
      ##...#..#.
      .#....####
      """,
      """
      #.#...#.#.
      .###....#.
      .#....#...
      ##.#.#.#.#
      ....#.#.#.
      .##..###.#
      ..#...##..
      ..##....##
      ......#...
      .####.###.
      """,
      """
      .#..#..###
      ####.###.#
      ....###.#.
      ..###.##.#
      ##.##.#.#.
      ....###..#
      ..#.#..#.#
      #..#.#.###
      .##...##.#
      .....#.#..
      """,
      """
      #.........
      ...A......
      ...B..a...
      .EDCG....a
      ..F.c.b...
      .....c....
      ..efd.c.gb
      .......c..
      ....f...c.
      ...e..d..c
      """
    ]
  end

  def sample_input do
    Enum.at(samples, 1)
  end

  def sample_input2 do
    """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
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

  def split_by_with_index(string, pattern) do
    string
    |> String.split(pattern, trim: true)
    |> Utils.List.zip_with_index
  end

  def is_asteroid?({char, point}) do
    char != "."
  end

  def get_point({char, point}), do: point

  def parse_input(input) do
    input
    |> split_by_with_index("\n")
    |> Enum.flat_map(&parse_line_with_index/1)
    |> Enum.filter(&is_asteroid?/1)
    |> Enum.map(&get_point/1)
    |> MapSet.new
  end

  def parse_line_with_index({line, y_index}) do
    line
    |> split_by_with_index("")
    |> Enum.map(fn {char, x_index} -> {char, {x_index, y_index}} end)
  end

  def get_slope({x1, y1} = p1, {x2, y2} = p2) do
    :math.atan2(y2 - y1, x2 - x1) - :math.pi() / 2
  end

  def collect_by_slopes({slope, point}, map) do
    Map.update(map, slope, [point], &[point | &1])
  end

  def distance({x1, y1} = p1, {x2, y2} = p2) do
    val = :math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)
    :math.pow(val, 0.5)
  end

  def closest_point_from(point, points) do
    points
    |> Enum.min_by(fn p -> distance(point, p) end)
  end

  def unique_slopes_for_point(point, points) do
    points
    |> Enum.reject(& &1 == point)
    |> Enum.map(&{get_slope(point, &1), &1})
    |> Enum.reduce(%{}, &collect_by_slopes/2)
  end

  @doc """
  Solves Day 10 part 1

  The idea is to for each asteroid in the input (a set of points) calculate it's slope. We can see
  one asteroid per unique slope, so we'll save those in a set as well.
  """
  def solve(input) do
    input
    |> Enum.map(
         fn point ->
           {
             point,
             unique_slopes_for_point(point, input)
             |> Map.size()
           }
         end
       )
    |> Enum.max_by(fn {point, visible_asteroids} -> visible_asteroids end)

  end

  def bool_to_int(bool) do
    case bool do
      true -> 1
      false -> 0
    end
  end


  @doc"""
  ordering is
    - positive slope, false
    - negative slope, true
    - positive slope, true
    - negative slope, false

    so we'll assign a multiplier to each case
  """
  def transform_slope({slope, offset}) do
    slope = slope + 0.0001
    case {slope, offset} do
      {slope, false} when slope >= 0 -> 100 + abs(1 / slope)
      {slope, true} when slope <= 0 -> 1000 + abs(slope)
      {slope, true} when slope >= 0 -> 10000 + abs(1 / slope)
      {slope, false} when slope <= 0 -> 100000 + abs(slope)
    end
  end

  # handling undefined slopes
#  def sort_slopes({nil, o1}, p2), do: sort_slopes({@undefined_slope, o1}, p2)
#  def sort_slopes(p1, {nil, o2}), do: sort_slopes(p1, {@undefined_slope, o2})

  @doc"""
  o1 and o1 are just measure of whether the origin point is lower (higher y or x) than the other
  point. i.e. o1 = true means the point causing this slope occurred before the origin on the line it
  shares
  """
  def sort_slopes(s1, s2) do
    s1 >= s2
  end

  @doc """
  Solves Day 10 part 1

  The idea is to for each asteroid in the input (a set of points) calculate it's slope. We can see
  one asteroid per unique slope, so we'll save those in a set as well.
  """
  def solve2(input) do
    {point, _} = solve(input)
    asteroids_by_slopes = unique_slopes_for_point(point, input)
    sorted_slopes = Map.keys(asteroids_by_slopes)
                    |> Enum.sort(&sort_slopes/2)

#     Rotate the laser
        Stream.cycle(sorted_slopes)
        |> Enum.take(10000)
        |> Enum.reduce({asteroids_by_slopes, point, 0}, &fire_laser/2)

        sorted_slopes
  end

  @doc"""
  Given a slope, returns the map of slopes to asteroids with the closest asteroid in the direction
  of slope to the laser removed
  """
  def fire_laser(slope, {asteroids_by_slopes, laser, destroyed_count}) do
    display_counts = [1, 2, 3, 10, 20, 49, 50, 51, 99, 100, 101, 199, 200, 201, 299]
    case Map.get(asteroids_by_slopes, slope) do
      nil -> {asteroids_by_slopes, laser, destroyed_count}
      targets ->
        target = closest_point_from(laser, targets)
        remaining_asteroids = List.delete(targets, target)
        if Enum.member?(display_counts, destroyed_count + 1), do: IO.inspect({target, destroyed_count + 1})
        case remaining_asteroids do
          [] -> {Map.delete(asteroids_by_slopes, slope), laser, destroyed_count + 1}
          x -> {Map.put(asteroids_by_slopes, slope, x), laser, destroyed_count + 1}
        end
    end
  end
end
