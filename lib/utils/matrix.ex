defmodule MatrixUtils do
  @doc """
  Shifts a given row by a certain amount

  Here we just transpose then shift col then transpose
  """
  def shift_row(matrix, y, amount) do
    matrix
    |> Matrex.transpose
    |> shift_col(y, amount)
    |> Matrex.transpose
  end


  @doc """
  Shifts a given column by a certain amount
  """
  def shift_col(matrix, x, amount) do
    new_col = matrix
    |> Matrex.column(x+1)
    |> Matrex.to_list
    |> ListUtils.right_rotate(amount)
    |> Enum.map(&List.wrap/1)
    |> Matrex.new

    Matrex.set_column(matrix, x+1, new_col)
  end

  def apply_to_sub_rect(matrix, x, y, w, h, fun) do
    coords = for i <- x..x+w, j <-y..y+h, do: {i, j}
    Matrex.apply(matrix, fn val, row, col ->
      cond do
      {row, col} in coords -> fun.(val)
      true -> val
      end
    end)
  end

end