defmodule Day2 do
  @moduledoc false

  def real_input do
    Utils.get_input(2, 1)
  end

  def sample_input do
    "1,9,10,3,2,3,11,0,99,30,40,50"
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
    new_input = transform_input(input, 12, 2)
    op({new_input, 0})
  end

  def solve2(input) do
    options = for a <- 0..99, b <- 0..99, do: {a, b}

    [{{a, b}, _}] = options
                  |> Stream.map(fn {a, b} -> {{a, b}, transform_input(input, a, b)} end)
                  |> Stream.map(fn {vals, input} -> {vals, op({input, 0})} end)
                  |> Stream.filter(fn {vals, [a | rest]} -> a == 19690720 end)
                  |> Enum.to_list()

    100 * a + b
  end

  def transform_input(input, noun, verb) do
    new_input = input
                |> List.replace_at(1, noun)
                |> List.replace_at(2, verb)
  end

  def op({list, :halt}), do: list
  def op({list, ip}) do
    range = ip..ip + 3
    case Enum.at(list, ip) do
      1 -> add(ip, list)
      2 -> mult(ip, list)
      99 -> {list, :halt}
    end
    |> op()
  end

  def get_args(ip, list) do
    Enum.slice(list, ip + 1..ip + 3)
  end

  def perform_op(list, [input1, input2, output], fun) do
    new_val = fun.(Enum.at(list, input1), Enum.at(list, input2))
    List.replace_at(list, output, new_val)
  end

  def add(ip, list) do
    {perform_op(list, get_args(ip, list), fn a, b -> a + b end), ip + 4}
  end

  def mult(ip, list) do
    {perform_op(list, get_args(ip, list), fn a, b -> a * b end), ip + 4}
  end

end
