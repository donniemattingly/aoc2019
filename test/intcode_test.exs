defmodule ComputerTest do
  use ExUnit.Case

  alias Intcode.Computer

  setup do
    %{
      name: Computer.random_name()
    }
  end

  test "Simple Add", %{name: name} do
    {status, memory, ip} =  Computer.execute({name, [1, 0, 0, 0, 99], 0})
    assert Computer.memory_map_to_list(memory) ==  [2, 0, 0, 0, 99]
  end

  test "Simple Multiply", %{name: name} do
    {status, memory, ip} =   Computer.execute({name, [2, 3, 0, 3, 99], 0})
    assert Computer.memory_map_to_list(memory) ==  [2, 3, 0, 6, 99]
  end

  test "Day 2 Part 1 Works", %{name: name} do
    input =
      Day2.real_input()
      |> Day2.parse_input()
      |> List.replace_at(1, 12)
      |> List.replace_at(2, 2)

    assert (Computer.execute({name, input, 0}) |> elem(1) |> Map.get(0)) == 3_267_740
  end

  test "Day 5 part 1 works", %{name: name} do
    input =
      Day5.real_input()
      |> Day5.parse_input()

    Computer.IO.start_link(name, input: [1])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 13_787_043
  end

  test "equal to 8 when in position mode and input is not 8", %{name: name} do
    input = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]
    Computer.IO.start_link(name, input: [0])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 0
  end

  test "equal to 8 when in position mode and input is 8", %{name: name} do
    input = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]
    Computer.IO.start_link(name, input: [8])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 1
  end

  test "less than 8 when in position mode and input is 8", %{name: name} do
    input = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]
    Computer.IO.start_link(name, input: [8])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 0
  end

  test "less than 8 when in position mode and input is less than 8", %{name: name} do
    input = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]
    Computer.IO.start_link(name, input: [5])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 1
  end

  test "equal to 8 when in immediate mode and input is not 8", %{name: name} do
    input = [3, 3, 1108, -1, 8, 3, 4, 3, 99]
    Computer.IO.start_link(name, input: [0])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 0
  end

  test "equal to 8 when in immediate mode and input is 8", %{name: name} do
    input = [3, 3, 1108, -1, 8, 3, 4, 3, 99]
    Computer.IO.start_link(name, input: [8])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 1
  end

  test "less than 8 when in immediate mode and input is 8", %{name: name} do
    input = [3, 3, 1107, -1, 8, 3, 4, 3, 99]
    Computer.IO.start_link(name, input: [8])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 0
  end

  test "less than 8 when in immediate mode and input is less than 8", %{name: name} do
    input = [3, 3, 1107, -1, 8, 3, 4, 3, 99]
    Computer.IO.start_link(name, input: [5])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 1
  end

  test "jump if when in position mode and input is 0", %{name: name} do
    input = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]
    Computer.IO.start_link(name, input: [0])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 0
  end

  test "jump if when in position mode and input is not 0", %{name: name} do
    input = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]
    Computer.IO.start_link(name, input: [12])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 1
  end

  test "jump if when in immediate mode and input is 0", %{name: name} do
    input = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]
    Computer.IO.start_link(name, input: [0])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 0
  end

  test "jump if when in immediate mode and input is not 0", %{name: name} do
    input = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]
    Computer.IO.start_link(name, input: [12])
    Computer.execute({name, input, 0})

    assert Computer.IO.peek_output(name) == 1
  end

  test "Simple Add w/ Supervised Computer", %{name: name} do
    Intcode.Supervisor.start_computer(name, [1, 0, 0, 0, 99])
    Computer.run(name)
    assert Computer.get_memory(name) |> Computer.memory_map_to_list() == [2, 0, 0, 0, 99]
  end

  test "Computer.run returns output", %{name: name} do
    program = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]
    Intcode.Supervisor.start_computer(name, program)
    Computer.IO.push_input(name, 12)
    assert Computer.run(name) == {:finished, 1}
  end

  test "Relative base works", %{name: name} do
    program = [109, 2000, 99]
    Intcode.Supervisor.start_computer(name, program)
    Computer.run(name)
    base = Computer.IO.dump_state(name) |> Keyword.get(:base)
    assert base == 2000
  end

  test "relative output", %{name: name} do
    program = [109, 10, 204, -8, 99]
    Intcode.Supervisor.start_computer(name, program)
    Computer.run(name)
    input = Computer.IO.dump_state(name) |> Keyword.get(:output)

    assert input == [204]
  end

  test "Relative base instruction produces correct output", %{name: name} do
    program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    Intcode.Supervisor.start_computer(name, program)
    Computer.IO.reset(name)
    Computer.run(name)
    output = Computer.IO.dump_state(name) |> Keyword.get(:output) |> Enum.reverse
    assert program == output
  end
end
