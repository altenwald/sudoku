defmodule SudokuConsole do
  @highlight_cell IO.ANSI.green_background()

  def start() do
    with {:ok, pid} <- SudokuGame.start_link() do
      SudokuGame.restart(pid)
      banner(pid)
      loop(pid)
    end
  end

  def start(pid) do
    if is_pid(pid) and Process.alive?(pid) do
      banner(pid)
      loop(pid)
    else
      IO.puts("incorrect game: #{inspect(pid)}")
    end
  end

  defp loop(pid) do
    board(pid)
    stats(pid)

    with "p" <- get_options("(P)lay, (Q)uit? [Pq]", ~w[p q], "p"),
         n <- gets_or_nil("Num="),
         board(pid, n),
         x <- gets("X="),
         y <- gets("Y=") do
      case SudokuGame.play(pid, x, y, n) do
        {:ok, :continue} ->
          banner(pid)
          loop(pid)

        {:error, errors} ->
          banner(pid)
          show_errors(errors)
          SudokuGame.play(pid, x, y, nil)
          loop(pid)

        {:ok, :complete} ->
          game_over(pid)
      end
    else
      "q" ->
        IO.puts("Use SudokuConsole.start/1 with the returned pid to continue.")
        {:ok, pid}
    end
  end

  defp game_over(pid) do
    board(pid)
    stats(pid)
    SudokuGame.stop(pid)
    IO.puts("G A M E    O V E R")
    :ok
  end

  defp get_options(prompt, valid_options, default) do
    with <<option::binary-size(1), "\n">> <- String.downcase(IO.gets(prompt)),
         true <- option in valid_options do
      option
    else
      <<"\n">> ->
        default

      _ ->
        IO.puts("incorrect option! valid: #{Enum.join(valid_options, ", ")}")
        get_options(prompt, valid_options, default)
    end
  end

  defp gets(prompt) do
    case IO.gets(prompt) do
      <<i::size(8), "\n">> when i in ?1..?9 ->
        i - ?0

      _ ->
        IO.puts("incorrect number! valid: 1-9")
        gets(prompt)
    end
  end

  defp show_errors([]), do: :ok

  defp show_errors([{{x1, y1}, {x2, y2}, value} | rest]) do
    IO.puts("ERROR: (#{x1},#{y1}) collides with (#{x2},#{y2}) (value=#{value})")
    show_errors(rest)
  end

  defp gets_or_nil(prompt) do
    case IO.gets(prompt) do
      <<i::size(8), "\n">> when i in ?0..?9 ->
        i - ?0

      <<"\n">> ->
        nil

      _ ->
        IO.puts("incorrect number! valid: 0-9 or empty")
        gets_or_nil(prompt)
    end
  end

  defp banner(pid) do
    """
    Altenwald Sudoku (#{inspect(pid)})
    """
  end

  defp board(pid) do
    SudokuGame.get_board(pid)
    |> SudokuGame.Board.to_string()
    |> IO.puts()
  end

  defp board(pid, n) do
    SudokuGame.get_board(pid)
    |> SudokuGame.Board.to_string(n, &"#{@highlight_cell}#{&1}#{IO.ANSI.reset()}")
    |> IO.puts()
  end

  defp stats(pid) do
    stats = SudokuGame.get_stats(pid)

    IO.puts(
      "------------------------------------------------------------------------\n" <>
        "missing: 1=#{stats.missing[1]} 2=#{stats.missing[2]} 3=#{stats.missing[3]} " <>
        "4=#{stats.missing[4]} 5=#{stats.missing[5]} 6=#{stats.missing[6]} " <>
        "7=#{stats.missing[7]} 8=#{stats.missing[8]} 9=#{stats.missing[9]} " <>
        "     empty: #{stats.empty}\n" <>
        "time: #{stats.secs_played} seconds\n" <>
        "------------------------------------------------------------------------\n"
    )
  end
end
