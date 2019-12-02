defmodule Intcode do
  @moduledoc"""
  Intcode seems to be important this year for Advent of Code, so I'm preemptively moving out
  some helper functions here.
  """

  defmodule Instruction do
    defstruct [opcode: -1, parameters: -1, operation: :no_op]

    @typedoc """
    An opcode is a struct with a code (the integer that identifies it), the number of parameters.
    and an atom indicating the operation to perform.
    """
    @type t :: %__MODULE__{
                 opcode: nil | integer(),
                 parameters: integer(),
                 operation: :no_op | :add | :mult | :halt
               }
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
    case execute_instruction(memory, parameters, instruction.operation) do
      {:ok, new_memory} -> execute({new_memory, update_instruction_pointer(ip, instruction)})
      {:halt, new_memory} -> new_memory
    end
  end

  def execute_instruction(memory, [a, b, c], :simple_infix, fun) do
    input1 = get_addr(memory, a)
    input2 = get_addr(memory, b)
    {:ok, List.replace_at(memory, c, fun.(input1, input2))}
  end

  def execute_instruction(memory, params, :add) do
    execute_instruction(memory, params, :simple_infix, &(&1 + &2))
  end

  def execute_instruction(memory, params, :multiply) do
    execute_instruction(memory, params, :simple_infix, &(&1 * &2))
  end

  def execute_instruction(memory, [], :halt) do
    {:halt, memory}
  end

  def update_instruction_pointer(ip, %Instruction{parameters: count}) do
    ip + count + 1
  end


  @doc"""
  Gets the value at `address` in memory
  """
  def get_addr(memory, address) do
    Enum.at(memory, address)
  end

  @doc"""
  Parses the instruction beginning at `ip`

  Returns a tuple of the instruction and it's parameters
  """
  def parse_instruction(memory, ip) do
    instruction = struct(Instruction, Map.get(@opcode_to_instruction, get_addr(memory, ip)))
    parameters = get_parameters_for_instruction(memory, ip, instruction)
    {instruction, parameters}
  end

  @doc"""
  Returns a list of all the parameters for the `instruction` as given by the `ip` (instruction pointer) and
  the number of parameters `count` from the `memory`
  """
  def get_parameters_for_instruction(memory, ip, %Instruction{parameters: count} = instruction) do
    Enum.slice(memory, ip + 1..ip + count)
  end

end