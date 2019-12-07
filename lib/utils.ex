defmodule Utils do
  @moduledoc """
  Various Utility functions for solving advent of code problems.
  """

  @log true

  @doc ~S"""
  Reads a file located at `inputs/input-{day}-{part}.txt`


  ## Options

  - `:stream`
    if true will use `File.stream!/1` defaults to  `File.read!/1`

  - `:split`
    if true will split the input line by line


  ## Examples

      iex> Utils.get_input(0, 0)
      "Test File\nWith Lines"

      iex> Utils.get_input(0, 0, split: true)
      ["Test File", "With Lines"]

      iex> Utils.get_input(0, 0, stream: true) |> Stream.run
      :ok
  """
  def get_input(day, part, options \\ []) do
    read =
      case Keyword.get(options, :stream, false) do
        true -> &File.stream!/1
        false -> &File.read!/1
      end

    map =
      case Keyword.get(options, :split, false) do
        true -> fn x -> String.split(x, "\n", trim: true) end
        false -> fn x -> x end
      end

    "inputs/input-#{day}-#{part}.txt"
    |> read.()
    |> map.()
  end

  @doc """
  Run the function `fun` and returns the time in seconds elapsed
  while running it
  """
  def time(fun) do
    {elapsed, _} = :timer.tc(fun)

    elapsed / 1_000_000
  end

  @doc """
  Inspects a value, but only if a random value generate is greater than
  `threshold`

  This is intended to be used with large streams of data that you
  want to investigate without printing every value.
  """
  def sample(value, threshold \\ 0.999) do
    case :rand.uniform() > threshold do
      true -> IO.inspect(value)
      _ -> value
    end
  end

  @doc """
  Generates the md5 hash of a value and encodes it as a lowercase base16 encoded string.

  ## Examples

      iex> Utils.md5("advent of code")
      "498fa12185ebe8a9231b9072da43c988"
  """
  def md5(value) do
    :crypto.hash(:md5, value)
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Swaps the element at `pos_a` in `list` with the element at `pos_b`

  ## Examples
      iex> Utils.swap([1, 2, 3], 0, 1)
      [2, 1, 3]

  """
  def swap(list, pos_a, pos_a), do: list

  def swap(list, pos_a, pos_b) when pos_a < pos_b do
    {initial, rest} = Enum.split(list, pos_a)
    {between, tail} = Enum.split(rest, pos_b - pos_a)
    a = hd(between)
    b = hd(tail)
    initial ++ [b] ++ tl(between) ++ [a] ++ tl(tail)
  end

  def swap(list, pos_a, pos_b) when pos_b < pos_a, do: swap(list, pos_b, pos_a)

  @doc """
  Generates all the permutations for the input `list`

  ## Examples
      iex> Utils.permutations([1, 2, 3])
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  """
  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def log_inspect(value, description, opts \\ []) when @log do
    IO.puts(description <> ": ")
    IO.inspect(value, opts)
  end

  def log_inspect(value), do: value
end
