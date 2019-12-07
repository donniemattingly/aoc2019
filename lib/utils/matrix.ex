defmodule Utils.Matrix do
  @moduledoc """
  A few functions on top of the [Matrex](https://github.com/versilov/matrex) library for manipulating matrices.
  """

  @doc """
  Shifts the row `y` by `amount`

  Here we just transpose then `shift_col/3` then transpose again
  """
  def shift_row(matrix, y, amount) do
    matrix
    |> Matrex.transpose()
    |> shift_col(y, amount)
    |> Matrex.transpose()
  end

  @doc """
  Shifts the column `x` by `amount`
  """
  def shift_col(matrix, x, amount) do
    new_col =
      matrix
      |> Matrex.column(x + 1)
      |> Matrex.to_list()
      |> ListUtils.right_rotate(amount)
      |> Enum.map(&List.wrap/1)
      |> Matrex.new()

    Matrex.set_column(matrix, x + 1, new_col)
  end

  @doc """
  Given a `matrix` will apply the function `fun` to every element in the
  sub-matrix starting at `[x, y]` with width `w` and height `h`
  """
  def apply_to_sub_rect(matrix, x, y, w, h, fun) do
    coords = for i <- x..(x + w), j <- y..(y + h), do: {i, j}

    Matrex.apply(matrix, fn val, row, col ->
      cond do
        {row, col} in coords -> fun.(val)
        true -> val
      end
    end)
  end
end
