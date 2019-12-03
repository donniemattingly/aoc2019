defmodule Day3 do
  @moduledoc false

  defmodule Point do
    defstruct [x: 0, y: 0, da: 0, db: 0,]
  end

  def real_input do
    Utils.get_input(3, 1)
  end

  def sample_input do
    """
    R8,U5,L5,D3
    U7,R6,D4,L4
    """

    """
    R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
    U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
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
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(",", trim: true)
    |> Enum.map(&parse_direction/1)
  end

  def parse_direction(input) do
    [direction | amount] = input
                           |> String.to_charlist
    dir_atom = case direction do
      ?U -> :u
      ?L -> :l
      ?D -> :d
      ?R -> :r
    end

    {
      dir_atom,
      String.to_integer(
        amount
        |> to_string
      )
    }
  end

  def solve_old(input) do
    [a, b] = input
             |> Enum.map(&moves_to_segments/1)
    segment_pairs = for p1 <- a, p2 <- b, do: {p1, p2}

    segment_pairs
    |> Stream.map(fn {l1, l2} -> get_intersection(l1, l2) end)
    |> Stream.filter(fn x -> x != :error end)
    |> Stream.map(fn {:ok, p} -> {p, manhattan_dist(p)} end)
    |> Stream.filter(fn {{x, y}, d} -> x != 0 and y != 0 end)
    |> Enum.to_list
    |> Enum.sort_by(&elem(&1, 1))
  end

  def print(input) do
    input
    |> Enum.map(&moves_to_segments/1)
    |> generate_grid
    |> render_grid
  end

  def solve(input) do
    input
    |> Enum.map(&moves_to_segments/1)
    |> generate_grid
    |> get_intersections_from_grid
    |> Enum.min_by(fn { _, { _, a}} -> a end)
  end

  def get_intersections_from_grid(grid) do
    grid
    |> Map.to_list
    |> Enum.filter(fn {a, b} -> elem(b, 0) == "X" end)
    |> Enum.filter(fn {a, b} -> a != {0, 0} end)
  end

  def manhattan_dist({x, y}) do
    abs(x) + abs(y)
  end

  def moves_to_segments(moves) do
    {_, segments} = Enum.reduce(moves, {{0, 0, 0}, []}, &moves_to_segments_reducer/2)
    segments
    |> Enum.reverse
  end

  def moves_to_segments_reducer({dir, amt} = move, {pos, segments}) do
    new_pos = move_wire(pos, move)
    {new_pos, [{pos, new_pos} | segments]}
  end

  def move_wire({x1, y1, d}, {:u, amt}), do: {x1, y1 + amt, d + amt}
  def move_wire({x1, y1, d}, {:r, amt}), do: {x1 + amt, y1, d + amt}
  def move_wire({x1, y1, d}, {:d, amt}), do: {x1, y1 - amt, d + amt}
  def move_wire({x1, y1, d}, {:l, amt}), do: {x1 - amt, y1, d + amt}

  @doc"""
  Finds the point where two line segments intersect

  Returns `{:ok, {x, y}}` if an intersection if found, `:error` otherwise

  These are always straight lines either x1 == x2 or y1 == y2 and to intersect the constant value of one segment
  must be within the variable value of the other. If there is an intersection then the two constant values of each
  segment make up the intersecting point

  """
  def get_intersection({{ax, ay, ad}, {bx, by, bd}} = s1, {{cx, cy, cd}, {dx, dy, dd}} = s2) do
    {o1, c1, v11, v12} = get_orientation(s1)
    {o2, c2, v21, v22} = get_orientation(s2)

    [sv11, sv12] = [v11, v12]
                   |> Enum.sort
    [sv21, sv22] = [v21, v22]
                   |> Enum.sort

    cond do
      o1 == o2 -> :error
      sv11 <= c2 and c2 <= sv12 -> {:ok, {c1, c2}}
      sv21 <= c1 and c1 <= sv22 -> {:ok, {c1, c2}}
      true -> :error
    end
  end

  @doc"""
  Is this line segment up and down or left and right

  Returns `:x`, or `:y`
  """
  def get_orientation({{ax, ay, ad}, {bx, by, bd}}) do
    cond do
      ax == bx -> {:y, ax, ay, by, ad}
      ay == by -> {:x, ay, ax, bx, ad}
      true -> :error
    end
  end

  def render_grid(grid) do
    keys = Map.keys(grid)
    {max_x, _} = Enum.max_by(keys, &elem(&1, 0))
    {_, max_y} = Enum.max_by(keys, &elem(&1, 1))

    -1..max_y+1
    |> Enum.map(
         fn y ->
           -1..max_x+1
           |> Enum.map(
                fn x ->
                  Map.get(grid, {x, y}, {".", nil})
                  |> elem(0)
                end
              )
           |> Enum.join("")
         end
       )
    |> Enum.join("\n")
    |> IO.puts
  end

  def generate_grid(segments) do
    [a, b] = segments
    {grid, :a} = Enum.reduce(a, {%{}, :a}, &generate_grid_reducer/2)
    {grid, :b} = Enum.reduce(b, {grid, :b}, &generate_grid_reducer/2)

    grid
  end

  def generate_grid_reducer(segment, {grid, wire}) do
    add_segment_to_grid(get_orientation(segment), {grid, wire})
  end

  def add_segment_to_grid({:y, x, y1, y2, d}, {grid, wire}) do
    y1..y2
    |> Enum.map(fn y -> {x, y} end)
    |> Enum.map(
         fn {x, y} -> if y == y1 or y == y2, do: {{x, y}, :t, d + abs(y - y1)}, else: {{x, y}, :y, d + abs(y - y1)} end
       )
    |> Enum.reduce({grid, wire}, &update_grid/2)
  end

  def add_segment_to_grid({:x, y, x1, x2, d}, {grid, wire}) do
    x1..x2
    |> Enum.map(fn x -> {x, y} end)
    |> Enum.map(
         fn {x, y} -> if x == x1 or x == x2, do: {{x, y}, :t, d + abs(x - x1)}, else: {{x, y}, :x, d + abs(x - x1)} end
       )
    |> Enum.reduce({grid, wire}, &update_grid/2)
  end

  def update_grid({point, orientation, delay} = i, {grid, wire}) do
    char = case orientation do
      :y -> "|"
      :x -> "-"
      :t -> "+"
    end

    char = if point == {0, 0}, do: "O", else: char

    {
      Map.update(
        grid,
        point,
        {char, wire, delay},
        fn {c, w, d} ->
          if w == wire do
            {"+", w, min(d, delay)}
          else
            {"X", delay + d}
          end
        end
      ),
      wire
    }
  end

end
