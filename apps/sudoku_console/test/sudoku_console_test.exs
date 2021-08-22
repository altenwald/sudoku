defmodule SudokuConsoleTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "solved board, last position" do
    {:ok, game} =
      SudokuGameMock.start_link(%{
        {:play, 1, 3, 7} => [{:error, [{{1, 3}, {2, 3}, 3}, {{1, 3}, {1, 4}, 3}]}],
        {:play, 1, 3, nil} => [{:ok, :continue}],
        {:play, 2, 1, 8} => [{:ok, :continue}],
        {:play, 1, 1, 2} => [{:ok, :complete}],
        :get_board => [
          [
            [0, 0, 1, 5, 7, 6, 9, 3, 4],
            [5, 9, 6, 2, 3, 4, 1, 7, 8],
            [3, 7, 4, 1, 8, 9, 5, 6, 2],
            [7, 3, 9, 8, 1, 2, 4, 5, 6],
            [6, 2, 5, 3, 4, 7, 8, 1, 9],
            [4, 1, 8, 9, 6, 5, 3, 2, 7],
            [8, 4, 7, 6, 5, 1, 2, 9, 3],
            [1, 6, 2, 4, 9, 3, 7, 8, 5],
            [9, 5, 3, 7, 2, 8, 6, 4, 1]
          ],
          [
            [0, 0, 1, 5, 7, 6, 9, 3, 4],
            [5, 9, 6, 2, 3, 4, 1, 7, 8],
            [3, 7, 4, 1, 8, 9, 5, 6, 2],
            [7, 3, 9, 8, 1, 2, 4, 5, 6],
            [6, 2, 5, 3, 4, 7, 8, 1, 9],
            [4, 1, 8, 9, 6, 5, 3, 2, 7],
            [8, 4, 7, 6, 5, 1, 2, 9, 3],
            [1, 6, 2, 4, 9, 3, 7, 8, 5],
            [9, 5, 3, 7, 2, 8, 6, 4, 1]
          ],
          [
            [0, 8, 1, 5, 7, 6, 9, 3, 4],
            [5, 9, 6, 2, 3, 4, 1, 7, 8],
            [3, 7, 4, 1, 8, 9, 5, 6, 2],
            [7, 3, 9, 8, 1, 2, 4, 5, 6],
            [6, 2, 5, 3, 4, 7, 8, 1, 9],
            [4, 1, 8, 9, 6, 5, 3, 2, 7],
            [8, 4, 7, 6, 5, 1, 2, 9, 3],
            [1, 6, 2, 4, 9, 3, 7, 8, 5],
            [9, 5, 3, 7, 2, 8, 6, 4, 1]
          ],
          [
            [2, 8, 1, 5, 7, 6, 9, 3, 4],
            [5, 9, 6, 2, 3, 4, 1, 7, 8],
            [3, 7, 4, 1, 8, 9, 5, 6, 2],
            [7, 3, 9, 8, 1, 2, 4, 5, 6],
            [6, 2, 5, 3, 4, 7, 8, 1, 9],
            [4, 1, 8, 9, 6, 5, 3, 2, 7],
            [8, 4, 7, 6, 5, 1, 2, 9, 3],
            [1, 6, 2, 4, 9, 3, 7, 8, 5],
            [9, 5, 3, 7, 2, 8, 6, 4, 1]
          ]
        ],
        :get_stats => [
          %{
            missing:
              for i <- 1..9, into: %{} do
                if i in [2, 8], do: {i, 1}, else: {i, 0}
              end,
            empty: 2,
            secs_played: 55,
            errors: [],
            valid?: true
          },
          %{
            missing:
              for i <- 1..9, into: %{} do
                if i in [2, 8], do: {i, 1}, else: {i, 0}
              end,
            empty: 2,
            secs_played: 60,
            errors: [{{1, 3}, {2, 3}, 3}, {{1, 3}, {1, 4}, 3}],
            valid?: false
          },
          %{
            missing:
              for i <- 1..9, into: %{} do
                if i == 2, do: {i, 1}, else: {i, 0}
              end,
            empty: 1,
            secs_played: 65,
            errors: [],
            valid?: true
          },
          %{
            missing: for(i <- 1..9, into: %{}, do: {i, 0}),
            empty: 0,
            secs_played: 75,
            errors: [],
            valid?: true
          }
        ]
      })

    initial_table = """
    ++---+---+---++---+---+---++---+---+---++
    ||   |   | 1 || 5 | 7 | 6 || 9 | 3 | 4 ||
    ++---+---+---++---+---+---++---+---+---++
    || 5 | 9 | 6 || 2 | 3 | 4 || 1 | 7 | 8 ||
    ++---+---+---++---+---+---++---+---+---++
    || 3 | 7 | 4 || 1 | 8 | 9 || 5 | 6 | 2 ||
    ++---+---+---++---+---+---++---+---+---++
    ++---+---+---++---+---+---++---+---+---++
    || 7 | 3 | 9 || 8 | 1 | 2 || 4 | 5 | 6 ||
    ++---+---+---++---+---+---++---+---+---++
    || 6 | 2 | 5 || 3 | 4 | 7 || 8 | 1 | 9 ||
    ++---+---+---++---+---+---++---+---+---++
    || 4 | 1 | 8 || 9 | 6 | 5 || 3 | 2 | 7 ||
    ++---+---+---++---+---+---++---+---+---++
    ++---+---+---++---+---+---++---+---+---++
    || 8 | 4 | 7 || 6 | 5 | 1 || 2 | 9 | 3 ||
    ++---+---+---++---+---+---++---+---+---++
    || 1 | 6 | 2 || 4 | 9 | 3 || 7 | 8 | 5 ||
    ++---+---+---++---+---+---++---+---+---++
    || 9 | 5 | 3 || 7 | 2 | 8 || 6 | 4 | 1 ||
    ++---+---+---++---+---+---++---+---+---++
    """

    initial_stage = """
    #{initial_table}
    ------------------------------------------------------------------------
    missing: 1=0 2=1 3=0 4=0 5=0 6=0 7=0 8=1 9=0      empty: 2
    time: 55 seconds
    ------------------------------------------------------------------------
    """

    error_stage = """

    ERROR: (1,3) collides with (2,3) (value=3)
    ERROR: (1,3) collides with (1,4) (value=3)
    #{initial_table}
    ------------------------------------------------------------------------
    missing: 1=0 2=1 3=0 4=0 5=0 6=0 7=0 8=1 9=0      empty: 2
    time: 60 seconds
    ------------------------------------------------------------------------
    """

    continue_stage = """

    ++---+---+---++---+---+---++---+---+---++
    ||   | 8 | 1 || 5 | 7 | 6 || 9 | 3 | 4 ||
    ++---+---+---++---+---+---++---+---+---++
    || 5 | 9 | 6 || 2 | 3 | 4 || 1 | 7 | 8 ||
    ++---+---+---++---+---+---++---+---+---++
    || 3 | 7 | 4 || 1 | 8 | 9 || 5 | 6 | 2 ||
    ++---+---+---++---+---+---++---+---+---++
    ++---+---+---++---+---+---++---+---+---++
    || 7 | 3 | 9 || 8 | 1 | 2 || 4 | 5 | 6 ||
    ++---+---+---++---+---+---++---+---+---++
    || 6 | 2 | 5 || 3 | 4 | 7 || 8 | 1 | 9 ||
    ++---+---+---++---+---+---++---+---+---++
    || 4 | 1 | 8 || 9 | 6 | 5 || 3 | 2 | 7 ||
    ++---+---+---++---+---+---++---+---+---++
    ++---+---+---++---+---+---++---+---+---++
    || 8 | 4 | 7 || 6 | 5 | 1 || 2 | 9 | 3 ||
    ++---+---+---++---+---+---++---+---+---++
    || 1 | 6 | 2 || 4 | 9 | 3 || 7 | 8 | 5 ||
    ++---+---+---++---+---+---++---+---+---++
    || 9 | 5 | 3 || 7 | 2 | 8 || 6 | 4 | 1 ||
    ++---+---+---++---+---+---++---+---+---++

    ------------------------------------------------------------------------
    missing: 1=0 2=1 3=0 4=0 5=0 6=0 7=0 8=0 9=0      empty: 1
    time: 65 seconds
    ------------------------------------------------------------------------
    """

    final_stage = """

    ++---+---+---++---+---+---++---+---+---++
    || 2 | 8 | 1 || 5 | 7 | 6 || 9 | 3 | 4 ||
    ++---+---+---++---+---+---++---+---+---++
    || 5 | 9 | 6 || 2 | 3 | 4 || 1 | 7 | 8 ||
    ++---+---+---++---+---+---++---+---+---++
    || 3 | 7 | 4 || 1 | 8 | 9 || 5 | 6 | 2 ||
    ++---+---+---++---+---+---++---+---+---++
    ++---+---+---++---+---+---++---+---+---++
    || 7 | 3 | 9 || 8 | 1 | 2 || 4 | 5 | 6 ||
    ++---+---+---++---+---+---++---+---+---++
    || 6 | 2 | 5 || 3 | 4 | 7 || 8 | 1 | 9 ||
    ++---+---+---++---+---+---++---+---+---++
    || 4 | 1 | 8 || 9 | 6 | 5 || 3 | 2 | 7 ||
    ++---+---+---++---+---+---++---+---+---++
    ++---+---+---++---+---+---++---+---+---++
    || 8 | 4 | 7 || 6 | 5 | 1 || 2 | 9 | 3 ||
    ++---+---+---++---+---+---++---+---+---++
    || 1 | 6 | 2 || 4 | 9 | 3 || 7 | 8 | 5 ||
    ++---+---+---++---+---+---++---+---+---++
    || 9 | 5 | 3 || 7 | 2 | 8 || 6 | 4 | 1 ||
    ++---+---+---++---+---+---++---+---+---++

    ------------------------------------------------------------------------
    missing: 1=0 2=0 3=0 4=0 5=0 6=0 7=0 8=0 9=0      empty: 0
    time: 75 seconds
    ------------------------------------------------------------------------

    G A M E    O V E R
    """

    assert capture_io([capture_prompt: false, input: "1\n3\n7\n2\n1\n8\n\n1\n1\n2\n"], fn ->
             SudokuConsole.start(game)
           end) == "#{initial_stage}#{error_stage}#{continue_stage}#{final_stage}"
  end
end
