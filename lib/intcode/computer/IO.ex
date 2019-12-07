defmodule Intcode.Computer.IO do
  use Agent

  @registry :intcode_registry
  def start_link(name, opts \\ []) do
    Agent.start_link(fn -> [input: Keyword.get(opts, :input, []), output: Keyword.get(opts, :output, [])] end, name: via_tuple(name))
  end

  def peek_input(name) do
    Agent.get(via_tuple(name), fn state -> pop(state, :input) |> elem(0) end)
  end

  def peek_output(name) do
    Agent.get(via_tuple(name), fn state -> pop(state, :output) |> elem(0) end)
  end

  def pop_input(name) do
    Agent.get_and_update(via_tuple(name), fn state -> pop(state, :input) end)
  end

  def pop_output(name) do
    Agent.get_and_update(via_tuple(name), fn state -> pop(state, :output)  end)
  end

  def push_input(name, input) do
    Agent.update(via_tuple(name), fn state -> push(state, :input, input) end)
  end

  def push_output(name, output) do
    Agent.update(via_tuple(name), fn state -> push(state, :output, output) end)
  end

  def pop(state, key) do
    case Keyword.get(state, key) do
      [h | t] -> {h, Keyword.put(state, key, t)}
      _ -> {nil, state}
    end
  end

  def push(state, key, value) do
    stack = Keyword.get(state, key)
    Keyword.put(state, key, [value | stack])
  end

  ## Private
  defp via_tuple(name), do: {:via, Registry, {@registry, {name, :io}}}
end