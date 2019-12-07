defmodule Intcode.Computer do
  @moduledoc """
  A server representing an intcode computer.

  The state for each computer contains the name, and memory.

  The IO agent is also started when this computer is started. It is stored in the registry as
  `{name, :io}` where `name` is the name used to start the computer
  """
  use GenServer
  require Logger

  @registry :intcode_registry

  ## API

  @doc """
  Starts
  """
  def start_link(name, memory) do
    GenServer.start_link(__MODULE__, {name, memory, 0}, name: via_tuple(name))
  end

  def run(name), do: GenServer.call(via_tuple(name), :execute)

  def get_memory(name), do: GenServer.call(via_tuple(name), :get_memory)

  def set_memory(name, memory), do: GenServer.call(via_tuple(name), {:set_memory, memory})

  def stop(name), do: GenServer.stop(via_tuple(name))

  def crash(name), do: GenServer.cast(via_tuple(name), :raise)

  ## Callbacks
  def init({name, memory, ip}) do
    {:ok, {name, memory, ip}}
  end

  def handle_call({:set_memory, new_memory}, _from, {name, _memory, ip}) do
    {:reply, new_memory, {name, new_memory, ip}}
  end

  def handle_call(:get_memory, _from, {name, memory, ip}) do
    {:reply, memory, {name, memory, ip}}
  end

  def handle_call(:execute, _from, {name, memory, ip}) do
    {status, new_memory, new_ip} = execute({name, memory, ip})
    output = Intcode.Computer.IO.peek_output(name)
    {:reply, {status, output}, {name, new_memory, new_ip}}
  end

  def handle_cast(:work, {name, memory, ip}) do
    {:noreply, name}
  end

  def handle_cast(:raise, name),
    do: raise(RuntimeError, message: "Error, Server #{name} has crashed")

  def terminate(reason, name) do
    Logger.info("Exiting worker with reason: #{inspect(reason)}")
  end

  ## Private
  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  defmodule Instruction do
    defstruct opcode: -1, parameters: -1, operation: :no_op, modes: []

    @typedoc """
    An opcode is a struct with a code (the integer that identifies it), the number of parameters.
    and an atom indicating the operation to perform.
    """
    @type t :: %__MODULE__{
            opcode: nil | integer(),
            parameters: integer(),
            operation: :no_op | :add | :mult | :halt,
            modes: list()
          }

    defimpl String.Chars, for: Instruction do
      def to_string(instr) do
        "%{op: #{instr.operation}}"
      end
    end
  end

  @opcode_to_instruction %{
    1 => %{
      opcode: 1,
      parameters: 3,
      operation: :add
    },
    2 => %{
      opcode: 2,
      parameters: 3,
      operation: :multiply
    },
    3 => %{
      opcode: 3,
      parameters: 1,
      operation: :input
    },
    4 => %{
      opcode: 4,
      parameters: 1,
      operation: :output
    },
    5 => %{
      opcode: 5,
      parameters: 2,
      operation: :jump_if_true
    },
    6 => %{
      opcode: 6,
      parameters: 2,
      operation: :jump_if_false
    },
    7 => %{
      opcode: 7,
      parameters: 3,
      operation: :less_than
    },
    8 => %{
      opcode: 8,
      parameters: 3,
      operation: :equals
    },
    99 => %{
      opcode: 99,
      parameters: 0,
      operation: :halt
    }
  }

  @doc """
  Given the `initial_memory` applies the `updates`, which are {index, new_value} pairs
  """
  def update_memory(initial_memory, updates) do
    Enum.reduce(
      updates,
      initial_memory,
      fn {index, new_value}, memory ->
        List.replace_at(memory, index, new_value)
      end
    )
  end

  @doc """
  Executes the instruction defined by the opcode at `ip`

  Returns a tuple of the new memory and the new instruction pointer. The new instruction pointer is found by
  incrementing the current instruction pointer by 1 + the number of parameters of this instruction. The instruction
  pointer can also be set by an instruction, and if it's value is `:halt` the program halts.
  """
  def execute({name, memory, ip}) do
    {instruction, parameters} = parse_instruction(memory, ip)

    case execute_instruction(name, memory, parameters, instruction.operation) do
      {:ok, new_memory} ->
        execute({name, new_memory, update_instruction_pointer(ip, instruction)})

      {:ok, new_memory, new_ip} ->
        execute({name, new_memory, new_ip})
      {:waiting, new_memory} ->
        {:waiting, new_memory, ip}
      {:halt, new_memory} ->
        {:finished, new_memory, 0}
    end
  end

  def execute_instruction(name, memory, [a, b, c], :simple_infix, fun) do
    input1 = get_value(memory, a)
    input2 = get_value(memory, b)
    output = Keyword.get(c, :value)

    {:ok, List.replace_at(memory, output, fun.(input1, input2))}
  end

  def execute_instruction(name, memory, [a], :input) do
    output = Keyword.get(a, :value)
    case Intcode.Computer.IO.dequeue_input(name) do
      nil -> {:waiting, memory}
      x -> {:ok, List.replace_at(memory, output, x)}
    end
  end

  def execute_instruction(name, memory, [a], :output) do
    output = get_addr(memory, Keyword.get(a, :value))
    Intcode.Computer.IO.push_output(name, output)
    {:ok, memory}
  end

  def execute_instruction(name, m, [a, b, c], :compare, comparator) do
    replacement = if comparator.(get_value(m, a), get_value(m, b)), do: 1, else: 0
    output = Keyword.get(c, :value)
    {:ok, List.replace_at(m, output, replacement)}
  end

  def execute_instruction(name, memory, params, :less_than) do
    execute_instruction(
      name,
      memory,
      params,
      :compare,
      &(&1 < &2)
    )
  end

  def execute_instruction(name, memory, params, :equals) do
    execute_instruction(
      name,
      memory,
      params,
      :compare,
      &(&1 == &2)
    )
  end

  def execute_instruction(name, memory, [a, b], :jump_if, predicate) do
    case predicate.(a) do
      true -> {:ok, memory, b}
      false -> {:ok, memory}
    end
  end

  def execute_instruction(name, memory, params, :jump_if_true) do
    execute_instruction(
      name,
      memory,
      params
      |> Enum.map(&get_value(memory, &1)),
      :jump_if,
      &(&1 != 0)
    )
  end

  def execute_instruction(name, memory, params, :jump_if_false) do
    execute_instruction(
      name,
      memory,
      params
      |> Enum.map(&get_value(memory, &1)),
      :jump_if,
      &(&1 == 0)
    )
  end

  def execute_instruction(name, memory, params, :add) do
    execute_instruction(name, memory, params, :simple_infix, &(&1 + &2))
  end

  def execute_instruction(name, memory, params, :multiply) do
    execute_instruction(name, memory, params, :simple_infix, &(&1 * &2))
  end

  def execute_instruction(name, memory, [], :halt) do
    {:halt, memory}
  end

  def update_instruction_pointer(ip, %Instruction{parameters: count}) do
    ip + count + 1
  end

  def get_value(_memory, value: x, mode: :immediate), do: x
  def get_value(memory, value: x, mode: :position), do: get_addr(memory, x)

  @doc """
  Gets the value at `address` in memory
  """
  def get_addr(memory, address) do
    #    Utils.log_inspect(address, "Address")
    Enum.at(memory, address)
  end

  @doc """
  Parses the instruction beginning at `ip`

  Returns a tuple of the instruction and it's parameters
  """
  def parse_instruction(memory, ip) do
    unparsed_opcode = get_addr(memory, ip)
    {opcode, modes} = get_opcode_and_modes(unparsed_opcode)

    instruction =
      struct(
        Instruction,
        @opcode_to_instruction
        |> Map.get(opcode)
        |> Map.put(:modes, modes)
      )

    parameters = get_parameters_for_instruction(memory, ip, instruction)
    zipped_parameters = zip_parameters_with_modes(parameters, modes)

    {instruction, zipped_parameters}
  end

  def get_opcode_and_modes(unparsed_opcode) do
    case to_charlist(unparsed_opcode)
         |> Enum.reverse() do
      'lin' ->
        {99, []}

      [a, b | rest] ->
        {
          [b, a]
          |> to_string
          |> String.to_integer(),
          rest
          |> Enum.map(&num_to_mode/1)
        }

      val ->
        {
          val
          |> Enum.reverse()
          |> to_string
          |> String.to_integer(),
          []
        }
    end
  end

  def zip_parameters_with_modes(parameters, modes) do
    Enum.zip(parameters, 0..(length(parameters) - 1))
    |> Enum.map(fn {parameter, index} -> {parameter, Enum.at(modes, index, :position)} end)
    |> Enum.map(fn {parameter, mode} -> [value: parameter, mode: mode] end)
  end

  def num_to_mode(?1), do: :immediate
  def num_to_mode(?0), do: :position

  @doc """
  Returns a list of all the parameters for the `instruction` as given by the `ip` (instruction pointer) and
  the number of parameters `count` from the `memory`
  """
  def get_parameters_for_instruction(memory, ip, %Instruction{parameters: count} = instruction) do
    Enum.slice(memory, (ip + 1)..(ip + count))
  end
end
