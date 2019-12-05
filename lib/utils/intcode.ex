defmodule Intcode do
  @moduledoc"""
  Intcode seems to be important this year for Advent of Code, so I'm preemptively moving out
  some helper functions here.
  """

  @input 5

  defmodule Instruction do
    defstruct [opcode: -1, parameters: -1, operation: :no_op, modes: []]

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
        "Instruction: opcode: #{instr.opcode}"
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


  @doc"""
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

  @doc"""
  Executes the given intcode program in `memory` (a list of integers) and returns the memory after the program halts.

  This sets the instruction pointer to 0 initially.
  """
  def execute(memory, :start) do
    execute({memory, 0})
  end

  @doc"""
  Executes the instruction defined by the opcode at `ip`

  Returns a tuple of the new memory and the new instruction pointer. The new instruction pointer is found by
  incrementing the current instruction pointer by 1 + the number of parameters of this instruction. The instruction
  pointer can also be set by an instruction, and if it's value is `:halt` the program halts.
  """
  def execute({memory, ip}) do
    {instruction, parameters} = parse_instruction(memory, ip)
    case execute_instruction(memory, parameters, instruction.operation)
         |> Utils.log_inspect("New memory after execution") do
      {:ok, new_memory} -> execute({new_memory, update_instruction_pointer(ip, instruction)})
      {:ok, new_memory, new_ip} -> execute({new_memory, new_ip})
      {:halt, new_memory} -> new_memory
    end
  end

  def execute_instruction(memory, [a, b, c], :simple_infix, fun) do
    input1 = get_value(memory, a)
    input2 = get_value(memory, b)
    output = Keyword.get(c, :value)

    Utils.log_inspect([a, b, c], "Parameters")
    Utils.log_inspect([input1, input2, output], "Input and output")

    {:ok, List.replace_at(memory, output, fun.(input1, input2))}
  end

  def execute_instruction(memory, [a], :input) do
    output = Keyword.get(a, :value)
    {:ok, List.replace_at(memory, output, @input)}
  end

  def execute_instruction(memory, [a], :output) do
    output = Keyword.get(a, :value)
    IO.puts("Output: #{get_addr(memory, output)}")
    {:ok, memory}
  end

  def execute_instruction(memory, [a, b, c], :compare, comparator) do
    output = Keyword.get(c, :value)
    replacement = if comparator.(a, b), do: 1, else: 0
    {:ok, List.replace_at(memory, output, 1)}
  end

  def execute_instruction(memory, params, :less_than) do
    execute_instruction(
      memory,
      params
      |> Enum.map(&get_value(memory, &1)),
      :compare,
      & &1 == &2
    )
  end

  def execute_instruction(memory, params, :equals) do
    execute_instruction(
      memory,
      params
      |> Enum.map(&get_value(memory, &1)),
      :compare,
      & &1 == &2
    )
  end

  def execute_instruction(memory, [a, b], :jump_if, predicate) do
    case predicate.(a) do
      true -> {:ok, memory, b}
      false -> {:ok, memory}
    end
  end

  def execute_instruction(memory, params, :jump_if_true) do
    execute_instruction(
      memory,
      params
      |> Enum.map(&get_value(memory, &1)),
      :jump_if,
      & &1 == 1
    )
  end

  def execute_instruction(memory, params, :jump_if_false) do
    execute_instruction(
      memory,
      params
      |> Enum.map(&get_value(memory, &1)),
      :jump_if,
      & &1 == 0
    )
  end

  def execute_instruction(memory, params, :add) do
    execute_instruction(memory, params, :simple_infix, &(&1 + &2))
    |> Utils.log_inspect("add result")
  end

  def execute_instruction(memory, params, :multiply) do
    execute_instruction(memory, params, :simple_infix, &(&1 * &2))
    |> Utils.log_inspect("multiply result")
  end

  def execute_instruction(memory, [], :halt) do
    {:halt, memory}
  end

  def update_instruction_pointer(ip, %Instruction{parameters: count}) do
    ip + count + 1
  end

  def get_value(_memory, [value: x, mode: :immediate]), do: x
  def get_value(memory, [value: x, mode: :position]), do: get_addr(memory, x)

  @doc"""
  Gets the value at `address` in memory
  """
  def get_addr(memory, address) do
    Utils.log_inspect(address, "Address")
    Enum.at(memory, address)
  end

  @doc"""
  Parses the instruction beginning at `ip`

  Returns a tuple of the instruction and it's parameters
  """
  def parse_instruction(memory, ip) do
    unparsed_opcode = get_addr(memory, ip)
    {opcode, modes} = get_opcode_and_modes(unparsed_opcode)
    instruction = struct(
      Instruction,
      @opcode_to_instruction
      |> Map.get(opcode)
      |> Map.put(:modes, modes)
    )

    Utils.log_inspect(instruction, "Instruction")
    parameters = get_parameters_for_instruction(memory, ip, instruction)
    zipped_parameters = zip_parameters_with_modes(parameters, modes)

    {instruction, zipped_parameters}
  end

  def get_opcode_and_modes(unparsed_opcode) do
    case to_charlist(unparsed_opcode) |> Utils.log_inspect("Unparsed opcode")
         |> Enum.reverse do
      'lin' -> {99, []}
      [a, b | rest] ->
        {
          [b, a]
          |> to_string
          |> String.to_integer,
          rest
          |> Enum.map(&num_to_mode/1)
        }
      val ->
        {
          val
          |> Enum.reverse
          |> to_string
          |> String.to_integer,
          []
        }
    end
  end

  def zip_parameters_with_modes(parameters, modes) do
    Enum.zip(parameters, 0..length(parameters) - 1)
    |> Enum.map(fn {parameter, index} -> {parameter, Enum.at(modes, index, :position)}end)
    |> Enum.map(fn {parameter, mode} -> [value: parameter, mode: mode] end)
  end

  def num_to_mode(?1), do: :immediate
  def num_to_mode(?0), do: :position

  @doc"""
  Returns a list of all the parameters for the `instruction` as given by the `ip` (instruction pointer) and
  the number of parameters `count` from the `memory`
  """
  def get_parameters_for_instruction(memory, ip, %Instruction{parameters: count} = instruction) do
    Enum.slice(memory, ip + 1..ip + count)
    |> Utils.log_inspect("Found Parameters")
  end

end