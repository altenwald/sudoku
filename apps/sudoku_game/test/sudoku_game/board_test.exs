defmodule SudokuGame.BoardTest do
  use ExUnit.Case
  alias SudokuGame.Board

  doctest SudokuGame.Board
  doctest String.Chars.SudokuGame.Board
  doctest Enumerable.SudokuGame.Board

  describe "generate" do
    test "struct initialization" do
      assert %Board{valid?: true, errors: []} == %Board{}
    end

    test "unsolved, solved and only one solution grant" do
      board = Board.generate()
      solved = Board.solve(board) |> Board.validate()

      refute Board.is_completed?(board)
      assert Board.is_completed?(solved)
      assert board.valid?
      assert Board.solutions(board) == 1
    end
  end

  describe "validation" do
    test "valid board" do
      board = Board.generate() |> Board.validate()

      assert [] == board.errors
      assert board.valid?
    end

    test "invalid board" do
      board =
        Board.new()
        |> Board.put(1, 1, 9)
        |> Board.put(3, 3, 9)
        |> Board.validate()

      assert [{{1, 1}, {3, 3}, 9}] == board.errors
      refute board.valid?
    end
  end

  describe "output" do
    test "empty board" do
      empty_board = """
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      """

      assert empty_board == Board.new() |> to_string()
    end

    test "central square filled board" do
      center_filled_board = """
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   || 1 | 2 | 3 ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   || 4 | 5 | 6 ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   || 7 | 8 | 9 ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      """

      board =
        Board.new()
        |> Board.put(4, 4, 1)
        |> Board.put(5, 4, 2)
        |> Board.put(6, 4, 3)
        |> Board.put(4, 5, 4)
        |> Board.put(5, 5, 5)
        |> Board.put(6, 5, 6)
        |> Board.put(4, 6, 7)
        |> Board.put(5, 6, 8)
        |> Board.put(6, 6, 9)

      assert center_filled_board == board |> to_string()
    end

    test "central square filled board from list" do
      center_filled_board = """
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   || 1 | 2 | 3 ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   || 4 | 5 | 6 ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   || 7 | 8 | 9 ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      ||   |   |   ||   |   |   ||   |   |   ||
      ++---+---+---++---+---+---++---+---+---++
      """

      board = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 2, 3, 0, 0, 0],
        [0, 0, 0, 4, 5, 6, 0, 0, 0],
        [0, 0, 0, 7, 8, 9, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0]
      ]

      assert center_filled_board == board |> SudokuGame.Board.to_string()
    end

    test "central square filled board to list" do
      center_filled_board = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 2, 3, 0, 0, 0],
        [0, 0, 0, 4, 5, 6, 0, 0, 0],
        [0, 0, 0, 7, 8, 9, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0]
      ]

      board =
        Board.new()
        |> Board.put(4, 4, 1)
        |> Board.put(5, 4, 2)
        |> Board.put(6, 4, 3)
        |> Board.put(4, 5, 4)
        |> Board.put(5, 5, 5)
        |> Board.put(6, 5, 6)
        |> Board.put(4, 6, 7)
        |> Board.put(5, 6, 8)
        |> Board.put(6, 6, 9)

      assert center_filled_board == board |> Enum.to_list()
    end
  end

  describe "stats" do
    test "get stats" do
      board =
        Board.new()
        |> Board.put(4, 4, 1)
        |> Board.put(5, 4, 2)
        |> Board.put(6, 4, 3)
        |> Board.put(4, 5, 4)
        |> Board.put(5, 5, 5)
        |> Board.put(6, 5, 6)
        |> Board.put(4, 6, 7)
        |> Board.put(5, 6, 8)
        |> Board.put(6, 6, 9)

      stats = %{
        empty: 72,
        errors: [],
        missing: for(i <- 1..9, into: %{}, do: {i, 8}),
        secs_played: 0,
        valid?: true
      }

      assert stats == Board.get_stats(board)
    end
  end
end
