defmodule Utils do
  @moduledoc """
  Various Utility functions for solving advent of code problems.
  """

  @doc """
  Reads a file located at `inputs/input-{day}-{part}.txt`
  """
  def get_input(day, part) do
    "inputs/input-#{day}-#{part}.txt"
    |> File.read!
  end


  @doc """
  Run the function `fun` and returns the time in seconds elapsed
  while running it
  """
  def time(fun) do
    {elapsed, _ } = :timer.tc(fun)

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
    |> String.downcase
  end


  @doc"""
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


  @doc"""
  Generates all the permutations for the input `list`

  ## Examples
      iex> Utils.permutations([1, 2, 3])
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  """
  def permutations([]), do: [[]]
  def permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
end
