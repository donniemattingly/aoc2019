defmodule Day7 do
  @moduledoc false

  alias Intcode.Computer

  def real_input do
    Utils.get_input(7, 1)
  end

  def sample_input do
    """
    3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0
    """
  end

  def sample_input2 do
    """
    3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5
    """
  end

  def sample do
    sample_input()
    |> parse_input1
    |> solve1
  end

  def part1 do
    real_input1()
    |> parse_input1
    |> solve1
  end

  def sample2 do
    sample_input2()
    |> parse_input2
    |> solve2
  end

  def part2 do
    real_input2()
    |> parse_input2
    |> solve2
  end

  def real_input1, do: real_input()
  def real_input2, do: real_input()

  def parse_input1(input), do: parse_input(input)
  def parse_input2(input), do: parse_input(input)

  def solve1(input), do: solve(input)

  def parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    Utils.permutations([0, 1, 2, 3, 4])
    |> Stream.map(fn phase_setting -> {get_output_signal_for_phase_setting(phase_setting, input), phase_setting} end)
    |> Enum.max_by(fn {output_signal, setting} -> output_signal end)
  end

  def solve2(input) do
    Utils.permutations([5, 6, 7, 8, 9])
    |> Stream.map(fn phase_setting -> {get_output_signal_for_phase_setting_with_feedback(phase_setting, input), phase_setting} end)
    |> Enum.max_by(fn {output_signal, setting} -> output_signal end)
  end

  @amplifier_names [:a, :b, :c, :d, :e]
  def get_output_signal_for_phase_setting(phase_setting, program) do

    Enum.zip(@amplifier_names, phase_setting)
    |> Enum.reduce(0, fn {name, phase}, input_signal ->
      Intcode.Supervisor.start_computer(name)
      Computer.set_memory(name, program)
      Computer.IO.reset(name)
      Computer.IO.push_input(name, phase)
      Computer.IO.push_input(name, input_signal)
      {status, val} = Computer.run(name)
      val
    end)
  end

  def get_output_signal_for_phase_setting_with_feedback(phase_setting, program) do
    create_computers(Enum.zip(@amplifier_names, phase_setting))
    links = link_amplifiers(@amplifier_names)
    run(hd(@amplifier_names), program, 0, links)
  end

  def run(current_amplifier, program, input, links) do
    Computer.IO.push_input(current_amplifier, input)
    Computer.set_memory(current_amplifier, program)
    case Computer.run(current_amplifier) do
      x -> x
      {:finished, result} -> result
      {:waiting, output} ->
        run(Map.get(links, current_amplifier), program, output, links)
    end
  end

  def link_amplifiers(amplifiers) do
    Enum.chunk_every(amplifiers, 2, 1)
    |> Enum.reduce(%{}, fn x, acc ->
      case x do
        [a, b] -> Map.put(acc, a, b)
        [a] -> Map.put(acc, a, hd(amplifiers))
      end
    end)
  end

  def create_computers(names) do
    names |> Enum.each(fn {name, phase} ->
      Intcode.Supervisor.start_computer(name)
      Computer.IO.reset(name)
      Computer.IO.push_input(name, phase)
    end)
  end

end
