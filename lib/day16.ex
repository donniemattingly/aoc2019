defmodule Day16 do
  @moduledoc false

  def real_input do
    Utils.get_input(16, 1)
  end

  def offset(input) do
    res = input
    |> String.slice(0, 7)
    |> String.to_integer
    res |> IO.inspect
  end

  def sample_input do
    """
    80871224585914546619083218645595
    """
  end

  def sample_input2 do
    "02935109699940807407585447034323"
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
  def parse_input2(input),
      do: input
          |> String.duplicate(10000)
          |> String.trim
          |> String.split("", trim: true)
          |> Enum.map(&String.to_integer/1)
          |> Enum.drop(offset(input))

  def solve1(input),
      do: solve(input)
          |> Enum.take(8)
          |> Enum.join

  def parse_input(input) do
    input
    |> String.trim
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    solve_matrex(input)
  end

  def solve2(input) do
    partial_phase_times(input, 100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def phase_times(input, 0), do: input
  def phase_times(input, times) do
    IO.inspect(times)
    result = phase(input)
    phase_times(result, times - 1)
  end

  def partial_reducer(x, list) do
    case list do
      [] -> [x]
      [n | _] -> [rem(x + n, 10) | list ]
    end
  end

  def partial_phase_times(input, 0), do: input
  def partial_phase_times(input, times) do
    IO.inspect(times)
    result = partial_phase(input)
    partial_phase_times(result, times - 1)
  end

  def partial_phase(input) do
    sum = Enum.sum(input)

    input
    |> List.foldr([], &partial_reducer/2)
  end

  def phase(input) do
    0..length(input) - 1
    |> Enum.map(&calculate_element(input, &1))
    |> Enum.to_list
  end

  def calculate_element(input, position) do
    pattern = nth_output(position + 1)
    Stream.zip(input, pattern)
    |> Stream.map(fn {x, y} -> x * y end)
    |> Enum.sum
    |> rem(10)
    |> abs
  end

  def matrix_for_size(size) do
    Matrex.new(size, size, fn (x, y) -> funcnth(x - 1, y - 1) end)
  end

  def solve_matrex(input) do
    matrix = input
             |> length
             |> matrix_for_size
    phases_matrex(matrix, input, 100)
  end

  def phases_matrex(matrix, input, 0), do: input
  def phases_matrex(matrix, input, times) do
    result = phase_matrex(input, matrix)
    result
    |> Enum.join
    |> Utils.colorize_digits
    |> IO.puts
    phases_matrex(matrix, result, times - 1)
  end

  def phase_matrex(input, multiples_matrix) do
    input_matrix = Matrex.reshape(input, length(input), 1)
    res = Matrex.dot(multiples_matrix, input_matrix)
    Matrex.apply(
      res,
      fn x ->
        x
        |> floor
        |> rem(10)
        |> abs
      end
    )
    |> Enum.map(&floor/1)
  end


  @doc"""
  the row maps to the index of the char in the string we're working with
  so row 0 -> [0, 1, 0, -1]...
        1 -> [0, 0, 1, 1, 0, 0, -1, -1]...
    etc

  idea is to first find where the index is in relation to the pattern
  pattern is length 4n where n is the row. so col % 4n gives us the relative
  position in a single pattern. we can then do
  """
  def funcnth(0, col), do: Enum.at([0, 1, 0, -1], rem(col + 1, 4))
  def funcnth(row, col) do
    n = row + 1
    m = col + 1# one for zero index, one for shifting left
    pos_in_pattern = rem(m, 4 * n)

    # now we need to normalize around 4
    divisor = 4 * n
    case floor((4 * pos_in_pattern) / divisor) do
      0 -> 0
      1 -> 1
      2 -> 0
      3 -> -1
    end
  end

  def snth_output(val) do
    n = val - 1
    l = %{0 => 0, 1 => 1, 2 => 0, 3 => -1}
    Stream.unfold(
      {n, 0},
      fn
        {0, index} -> {l[index], {n, rem(index + 1, 4)}}
        {n, index} -> {l[index], {n - 1, index}}
      end
    )
    |> Stream.drop(1)
  end

  def nth_output(n) do
    [0, 1, 0, -1]
    |> Enum.reduce(
         [],
         fn x, acc ->
           repeated = for i <- 1..n, do: x
           repeated ++ acc
         end
       )
    |> Enum.reverse
    |> Stream.cycle
    |> Stream.drop(1)
  end
end
