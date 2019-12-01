defmodule ListUtils do
  @moduledoc"""
  from: https://github.com/reeesga/elixir-rotate-lists/blob/master/lib/list_rotation.ex
  """

  def left_rotate(l, n \\ 1)
  def left_rotate([], _), do: []
  def left_rotate(l, 0), do: l
  def left_rotate([h | t], 1), do: t ++ [h]
  def left_rotate(l, n) when n > 0, do: left_rotate(left_rotate(l, 1), n-1)
  def left_rotate(l, n), do: right_rotate(l, -n)

  def right_rotate(l, n \\ 1)
  def right_rotate(l, n) when n > 0, do: Enum.reverse(l) |> ListUtils.left_rotate(n) |> Enum.reverse
  def right_rotate(l, n), do: left_rotate(l, -n)
end