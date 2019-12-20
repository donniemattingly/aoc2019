defmodule Intcode.Functional do
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
    9 => %{
      opcode: 9,
      parameters: 1,
      operation: :adjust_base
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
        Map.put(memory, index, new_value)
      end
    )
  end

  def random_name() do
    :crypto.strong_rand_bytes(10)
    |> Base.url_encode64()
    |> binary_part(0, 10)
  end

  def execute({name, memory, ip}) when is_list(memory) do
    memory_map = 0..length(memory) - 1 |> Enum.zip(memory) |> Enum.into(%{})
    execute({name, memory_map, ip})
  end

  def memory_map_to_list(memory) do
    {min, max} = memory |> Map.keys() |> Enum.min_max()
    min..max
    |> Enum.map(&Map.get(memory, &1, 0))
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
        new_ip = update_instruction_pointer(ip, instruction)
        {:waiting, new_memory, ip}
      {:halt, new_memory} ->
        {:finished, new_memory, 0}
    end
  end


  ######## Instructions ########

  def execute_instruction(name, memory, [a, b, c], :simple_infix, fun) do
    input1 = get_value(name, memory, a)
    input2 = get_value(name, memory, b)
    output = get_output(name, c)

    {:ok, Map.put(memory, output, fun.(input1, input2))}
  end

  def execute_instruction(name, memory, [a], :input) do
    output = get_output(name, a)
    case Intcode.Computer.IO.dequeue_input(name)  do
      nil -> {:waiting, memory}
      x -> {:ok, Map.put(memory, output, x)}
    end
  end

  def execute_instruction(name, memory, [a], :output) do
    output = get_value(name, memory, a)
    Intcode.Computer.IO.push_output(name, output)
    {:ok, memory}
  end

  def execute_instruction(name, memory, [a], :adjust_base) do
    base = Intcode.Computer.IO.get_relative_base(name)
    Intcode.Computer.IO.set_relative_base(name, base + get_value(name, memory, a))
    {:ok, memory}
  end

  def execute_instruction(name, m, [a, b, c], :compare, comparator) do
    replacement = if comparator.(get_value(name, m, a), get_value(name, m, b)), do: 1, else: 0
    output = get_output(name, c)
    {:ok, Map.put(m, output, replacement)}
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
      |> Enum.map(&get_value(name, memory, &1)),
      :jump_if,
      &(&1 != 0)
    )
  end

  def execute_instruction(name, memory, params, :jump_if_false) do
    execute_instruction(
      name,
      memory,
      params
      |> Enum.map(&get_value(name, memory, &1)),
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

  def execute_instruction(name, memory, params, :halt) do
    {:halt, memory}
  end

  def update_instruction_pointer(ip, %Instruction{parameters: count}) do
    ip + count + 1
  end

  def get_base(name), do: Intcode.Computer.IO.get_relative_base(name)

  def get_output(name, value: x, mode: :immediate), do: x
  def get_output(name, value: x, mode: :position), do: x
  def get_output(name, value: x, mode: :relative), do: x + get_base(name)

  def get_value(name, _memory, value: x, mode: :immediate), do: x
  def get_value(name, memory, value: x, mode: :position), do: get_addr(memory, x)
  def get_value(name, memory, value: x, mode: :relative), do: get_addr(memory, x + get_base(name))

  @doc """
  Gets the value at `address` in memory
  """
  def get_addr(memory, address) do
    Map.get(memory, address, 0)
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

  def num_to_mode(?2), do: :relative
  def num_to_mode(?1), do: :immediate
  def num_to_mode(?0), do: :position

  @doc """
  Returns a list of all the parameters for the `instruction` as given by the `ip` (instruction pointer) and
  the number of parameters `count` from the `memory`
  """
  def get_parameters_for_instruction(memory, ip, %Instruction{parameters: count} = instruction) do
    (ip + 1)..(ip + count)
    |> Enum.map(fn index -> Map.get(memory, index) end)
  end
end
