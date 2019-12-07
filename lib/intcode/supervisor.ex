defmodule Intcode.Supervisor do
  use DynamicSupervisor

  def start_link(_arg),
      do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
      do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_computer(name), do: start_computer(name, [])
  def start_computer(name, memory) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: Intcode.Computer, start: {Intcode.Computer, :start_link, [name, memory]}, restart: :transient}
    )

    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: Intcode.Computer.IO, start: {Intcode.Computer.IO, :start_link, [name]}, restart: :transient}
    )
  end

end