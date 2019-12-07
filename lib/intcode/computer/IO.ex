defmodule Intcode.Computer.IO do
  use Agent

  @registry :intcode_registry
  def start_link(name, opts \\ []) do
    Agent.start_link(fn -> [input: Keyword.get(opts, :input), output: Keyword.get(opts, :output)] end, name: via_tuple(name))
  end

  def input(name) do
    Agent.get(via_tuple(name), fn state -> Keyword.get(state, :input) end)
  end

  def output(name) do
    Agent.get(via_tuple(name), fn state -> Keyword.get(state, :output)  end)
  end

  def set_input(name, input) do
    Agent.update(via_tuple(name), fn state -> Keyword.put(state, :input, input) end)
  end

  def set_output(name, output) do
    Agent.update(via_tuple(name), fn state -> Keyword.put(state, :output, output) end)
  end

  ## Private
  defp via_tuple(name), do: {:via, Registry, {@registry, {name, :io}}}
end