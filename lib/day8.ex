defmodule Day8 do
  @moduledoc false

  def real_input do
    Utils.get_input(8, 1)
  end

  def sample_input do
    "123456789012"
  end

  def sample_input2 do
    "0222112222120000"
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
    |> solve2(2, 2)
  end

  def part2 do
    real_input2()
    |> parse_input2
    |> solve2(25, 6)
  end

  def real_input1, do: real_input()
  def real_input2, do: real_input()

  def parse_input1(input), do: parse_input(input)
  def parse_input2(input), do: parse_input(input)

  def solve1(input), do: solve(input, 25, 6)

  def parse_input(input) do
    input
    |> String.split("", trim: true)
  end

  def solve(input, height, width) do
    layers = input |> Enum.chunk_every(height * width, height * width)

    {count, index} = layers
    |> Enum.map(fn layer -> Enum.count(layer, fn x -> x == "0" end) end)
    |> Enum.zip(0..length(layers)-1)
    |> Enum.min_by(fn {count, index} -> count end)

    layer = Enum.at(layers, index) |> IO.inspect

    count_char(layer, "1") * count_char(layer, "2")
  end

  def count_char(list, char) do
    list
    |> Enum.count(fn x -> x == char end)
  end

  def solve2(input, height, width) do
    layers = input |> Enum.chunk_every(height * width, height * width)

    0..(height*width)-1
    |> Enum.map(fn index ->
      layers
      |> Enum.map(&Enum.at(&1, index))
      |> get_visible_pixel
    end)
    |> render(height, width)
  end

  def get_visible_pixel(pixels) do
    pixels
    |> Enum.filter(fn x -> x != "2" end)
    |> hd
  end

  def render(pixels, height, width) do
    pixels
    |> Enum.map(fn x ->
      case x do
        "1" -> "■"
        "0" -> " "
      end
    end)
    |> Enum.chunk_every(height, height)
    |> Enum.map(&Enum.chunk_every(&1, width, width))
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.join("\n")
    |> IO.puts
  end

end
