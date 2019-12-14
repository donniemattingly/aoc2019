defmodule Intcode.Computer.IO do
  use Agent

  @registry :intcode_registry
  def start_link(name, opts \\ []) do
    Agent.start_link(fn -> [input: Keyword.get(opts, :input, []), output: Keyword.get(opts, :output, [])] end, name: via_tuple(name))
  end

  def dump_state(name) do
    Agent.get(via_tuple(name), & &1)
  end

  def reset(name) do
    Agent.update(via_tuple(name), fn _state -> [input: [], output: []] end)
  end

  def get_relative_base(name) do
    Agent.get(via_tuple(name), fn state -> Keyword.get(state, :base, 0) end)
  end

  def set_relative_base(name, value) do
    Agent.update(via_tuple(name), fn state -> Keyword.put(state, :base, value) end)
  end

  def peek_input(name) do
#    IO.inspect({:peek_input, name, dump_state(name)})
    Agent.get(via_tuple(name), fn state -> pop(state, :input) |> elem(0) end)
  end

  def peek_output(name) do
#    IO.inspect({:peek_output, name, dump_state(name)})
    Agent.get(via_tuple(name), fn state -> pop(state, :output) |> elem(0) end)
  end

  def pop_input(name) do
#    IO.inspect({:pop_input, name, dump_state(name)})
    Agent.get_and_update(via_tuple(name), fn state -> pop(state, :input) end)
  end

  def pop_output(name) do
    IO.inspect({:pop_output, name, dump_state(name)})
    Agent.get_and_update(via_tuple(name), fn state -> pop(state, :output)  end)
  end

  def dequeue_input(name) do
#    IO.inspect({:dequeue_input, name, dump_state(name)})
    Agent.get_and_update(via_tuple(name), fn state -> dequeue(state, :input) end)
  end

  def dequeue_output(name) do
#    IO.inspect({:dequeue_output, name, dump_state(name)})
    Agent.get_and_update(via_tuple(name), fn state -> dequeue(state, :output)  end)
  end

  def push_input(name, input) do
#    IO.inspect({:push_input, input, name, dump_state(name)})
    Agent.update(via_tuple(name), fn state -> push(state, :input, input) end)
  end

  def push_output(name, output) do
#    IO.inspect({:push_output, output, name, dump_state(name)})
    Agent.update(via_tuple(name), fn state -> push(state, :output, output) end)
  end

  def pop(state, key) do
    case Keyword.get(state, key) do
      [h | t] -> {h, Keyword.put(state, key, t)}
      _ -> {nil, state}
    end
  end

  def dequeue(state, key) do
    case Keyword.get(state, key) |> Enum.reverse do
      [h | t] -> {h, Keyword.put(state, key, t |> Enum.reverse)}
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