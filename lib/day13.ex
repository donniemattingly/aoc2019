defmodule Day13 do
  @moduledoc false

  alias Intcode.Computer

  def real_input do
    Utils.get_input(13, 1)
  end

  def sample_input do
    """
    """
  end

  def sample_input2 do
    """
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
  def parse_input2(input) do
    input
    |> parse_input
    |> List.replace_at(0, 2)
  end

  def solve1(input), do: solve(input)

  def parse_input(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solve(input) do
    input
    |> get_screen
    |> elem(0)
    |> Map.values
    |> Enum.filter(& &1 == 2)
    |> Enum.count
  end

  def solve2(input) do
    {screen, score} = input
                      |> play_game
    score
  end

  def get_screen(program) do
    name = Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Computer.set_memory(name, program)
    render_screen(name, {%{}, 0})
  end

  def update_game_state(name, {screen, score}) do
    new_state = Computer.IO.dump_state(name)
                |> Keyword.get(:output)
                |> Enum.reverse
                |> Enum.chunk_every(3, 3)
                |> Enum.reduce(
                     {screen, score},
                     fn ([x, y, v], {screen_acc, score_acc}) ->
                       case {x, y, v} do
                         {-1, 0, _} ->
                           {screen_acc, v}
                         {_, _, 3} ->
                           {
                             screen_acc
                             |> Map.put({x, y}, v)
                             |> Map.put(:paddle, {x, y}),
                             score_acc
                           }
                         {_, _, 4} ->
                           {
                             screen_acc
                             |> Map.put({x, y}, v)
                             |> Map.put(:ball, {x, y}),
                             score_acc
                           }
                         _ ->
                           {Map.put(screen_acc, {x, y}, v), score_acc}
                       end
                     end
                   )

    IO.puts(print_screen(elem(new_state, 0)))

    new_state
  end

  def render_screen(name, state) do
    case Computer.run(name) do
      {:waiting, _} ->
        Computer.IO.push_input(name, -1)
        render_screen(name, update_game_state(name, state))
      {:finished, _} -> update_game_state(name, state)
    end
  end

  def determine_joystick_move(screen) do
    {px, py} = Map.get(screen, :paddle, {0, 0})
    {bx, by} = Map.get(screen, :ball, {0, 0})

    bx - px
  end

  def render_tile(tile) do
    import IO.ANSI
    case tile do
      0 -> white() <> "█"
      1 -> black() <> "█"
      2 -> blue() <> "█"
      3 -> red() <> "█"
      4 -> green() <> "█"
      _ -> ""
    end
  end

  def print_screen(screen) do
    {{minx, miny}, {maxx, maxy}} = screen
                                   |> Map.keys
                                   |> Enum.reject(fn val -> is_atom(val) end)
                                   |> Enum.min_max
    string_screen = miny - 1..maxy + 1
    |> Enum.map(
         fn y ->
           minx..maxx
           |> Enum.map(
                fn x ->
                  Map.get(screen, {x, y}, 0)
                  |> render_tile
                end
              )
           |> Enum.join("")
         end
       )
    |> Enum.join("\n")


    string_screen <> "\n\n"
  end

  def play_game(program) do
    name = Computer.random_name()
    Intcode.Supervisor.start_computer(name)
    Computer.set_memory(name, program)
    advance_game(name, {%{}, 0})
  end

  def advance_game(name, {screen, score} = state) do
    Computer.IO.push_input(name, determine_joystick_move(screen))
    case Computer.run(name) do
      {:waiting, _} ->
        advance_game(name, update_game_state(name, state))
      {:finished, _} -> update_game_state(name, state)
    end
  end
end
