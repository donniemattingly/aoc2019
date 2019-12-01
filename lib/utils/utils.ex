defmodule Utils do
  @moduledoc """
  Documentation for Aoc2016.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc2016.hello()
      :world

  """
  def get_input(day, part) do
    "inputs/input-#{day}-#{part}.txt"
    |> File.read!
  end


  def time(fun) do
    {elapsed, _ } = :timer.tc(fun)

    elapsed / 1_000_000
  end

  def sample(value, threshold \\ 0.999) do
    case :rand.uniform() > threshold do
      true -> IO.inspect(value)
      _ -> value
    end
  end

  def md5(value) do
    :crypto.hash(:md5, value)
    |> Base.encode16()
    |> String.downcase
  end

  def swap(list, pos_a, pos_a), do: list
  def swap(list, pos_a, pos_b) when pos_a < pos_b do
    {initial, rest} = Enum.split(list, pos_a)
    {between, tail} = Enum.split(rest, pos_b - pos_a)
    a = hd(between)
    b = hd(tail)
    initial ++ [b] ++ tl(between) ++ [a] ++ tl(tail)
  end

  def swap(list, pos_a, pos_b) when pos_b < pos_a, do: swap(list, pos_b, pos_a)


  def permutations([]), do: [[]]
  def permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
end
