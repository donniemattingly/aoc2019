# lib/dynamic_supervisor_example.ex
defmodule Intcode do
  # Indicate this module is an application entrypoint
  use Application

  @registry :intcode_registry

  def start(_args, _opts) do
    children = [
      {Intcode.Supervisor, []},
      {Registry, [keys: :unique, name: @registry]}
    ]

    # :one_to_one strategy indicates only the crashed child will be restarted, without affecting the rest of children.
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
