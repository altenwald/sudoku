defmodule SudokuGame.Board do
  @moduledoc """
  Handle the board for a Sudoku game.

  It has the functions needed to put numbers into the board, get the information
  validate the numbers you put into the board, solve a board, get the number of
  solutions and get information about a cell, row, col or square.

  Even the protocol for `to_string/1` was implemented to let us use `IO.puts/1` and
  show the board into the shell.

  We have two functions which let us start with a board. The first one is `new/0`
  and the second one is `generate/0`. The first one is creating a completely empty
  board and the second one is generating the solution and then unsolving it to
  generate a board to play with with only one possible solution.

  If you want to generate a easier board you can use:

  ```elixir
  SudokuGame.Board.new()
  |> SudokuGame.Board.solve()
  |> SudokuGame.Board.unsolve(3)
  ```

  Decreasing the number of attempts it's giving us a much much more easier to solve
  board. And if you want one more difficult you could use a higher number.

  Note that a number greater than the default (5) is taking much more time to generate
  a valid board.
  """

  @type x_pos() :: 1..9
  @type y_pos() :: 1..9
  @type content :: nil | 1..9
  @type position_error() :: {x_pos(), y_pos(), content()}

  @type t() :: %__MODULE__{
          cells: %{optional(1..9) => 1..9 | nil},
          valid?: boolean(),
          errors: [position_error()],
          started_at: NaiveDateTime.t()
        }

  defstruct cells: %{},
            valid?: true,
            errors: [],
            started_at: nil

  @max_attempts 3
  @empty_attempts 81

  @doc """
  Generates a new board completely empty.
  """
  def new() do
    %__MODULE__{
      cells: empty_board(),
      started_at: NaiveDateTime.utc_now()
    }
  end

  defp empty_board() do
    for i <- 1..9, into: %{}, do: {i, empty_line()}
  end

  defp empty_line() do
    for i <- 1..9, into: %{}, do: {i, nil}
  end

  @doc """
  Put a `value` inside of the `board` for a given position (`x` and `y`).
  """
  def put(%__MODULE__{cells: cells} = board, x, y, value) when value in 1..9 or is_nil(value) do
    %__MODULE__{board | cells: put_in(cells[x][y], value)}
  end

  @doc """
  Get the value inside of the `board` for a given position (`x` and `y`).
  """
  def get(%__MODULE__{cells: cells}, x, y), do: cells[x][y]

  @doc """
  Generate a Sudoku board to be solved. The generation of the board is using
  the functions `new/0`, `solve/0` and `unsolve/1` with the default attempts
  value (5). This means it ensures to generate a board which has only one
  solution.
  """
  def generate() do
    new()
    |> solve()
    |> unsolve(@max_attempts)
  end

  @doc """
  Clear as many cells as possible, randomly while it's granted an only one
  solution for the board. If the number of attempts is increased, it's
  possible to reach a more difficult to solve board, while if the number
  is lower, it should be easier to solve.
  """
  def unsolve(board, attempts \\ @max_attempts), do: unsolve(board, attempts, @empty_attempts)

  defp unsolve(board, 0, _empty_attempts), do: board

  defp unsolve(board, attempts, empty_attempts) do
    row = Enum.random(1..9)
    col = Enum.random(1..9)

    if get(board, col, row) do
      newboard = put(board, col, row, nil)

      if solutions(newboard) != 1 do
        unsolve(board, attempts - 1, @empty_attempts)
      else
        unsolve(newboard, attempts, @empty_attempts)
      end
    else
      unsolve(board, attempts, empty_attempts - 1)
    end
  end

  @doc """
  Give us the number of solutions the board has. It's a brute-force way
  to know how many solutions could have the board. If you use it with a
  solved board, it's giving the result immediately while if you try to
  use it with an empty board, it's trying to solve it through the complete
  number of possible solutions for a Sudoku which is:

  6,670,903,752,021,072,936,960
  """
  def solutions(board), do: solutions(board, 1, 1, 0)

  defp solutions(_board, 10, 9, solutions), do: solutions + 1
  defp solutions(board, 10, y, solutions), do: solutions(board, 1, y + 1, solutions)

  defp solutions(board, x, y, solutions) do
    if get(board, x, y) do
      solutions(board, x + 1, y, solutions)
    else
      values =
        possible_values(board, x, y)
        |> Enum.shuffle()

      solutions(board, x, y, values, solutions)
    end
  end

  defp solutions(_board, _x, _y, [], solutions), do: solutions

  defp solutions(board, x, y, [i | rest], solutions) do
    solutions =
      board
      |> put(x, y, i)
      |> solutions(x + 1, y, solutions)

    solutions(board, x, y, rest, solutions)
  end

  @doc """
  Solve a sudoku board (if possible). You get a board with the solved
  solution inside or the throwed atom `:no_solution`.
  """
  def solve(board), do: solve(board, 1, 1)

  defp solve(board, 10, 9), do: board
  defp solve(board, 10, y), do: solve(board, 1, y + 1)

  defp solve(board, x, y) do
    if get(board, x, y) do
      solve(board, x + 1, y)
    else
      values =
        possible_values(board, x, y)
        |> Enum.shuffle()

      solve(board, x, y, values)
    end
  end

  defp solve(_board, _x, _y, []), do: :no_solution

  defp solve(board, x, y, [i | rest]) do
    board
    |> put(x, y, i)
    |> solve(x + 1, y)
    |> case do
      :no_solution -> solve(board, x, y, rest)
      result -> result
    end
  end

  @doc """
  Tell us if the board is completed or not.
  """
  @spec is_completed?(t()) :: boolean()
  def is_completed?(%__MODULE__{valid?: false}), do: false

  def is_completed?(%__MODULE__{cells: cells}) do
    not Enum.any?(1..9, fn x ->
      Enum.any?(1..9, fn y ->
        is_nil(cells[x][y])
      end)
    end)
  end

  @doc """
  Validate the board. Ensure the numbers placed into the board
  are legal. The values for `valid?` and `errors` are populated accordingly.
  """
  def validate(%__MODULE__{} = board) do
    case get_invalid_positions(board) do
      [] -> %__MODULE__{board | valid?: true, errors: []}
      errors -> %__MODULE__{board | valid?: false, errors: errors}
    end
  end

  defp get_errors(data) do
    for i <- 1..8, j <- (i + 1)..9 do
      {x1, y1, ic} = Enum.at(data, i - 1)
      {x2, y2, jc} = Enum.at(data, j - 1)

      if not is_nil(ic) and not is_nil(jc) and ic == jc do
        {{x1, y1}, {x2, y2}, ic}
      end
    end
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Get a row from a board based on the second parameter of the function.
  """
  def get_row(board, i) when i in 1..9 do
    Enum.map(1..9, &{&1, i, get(board, &1, i)})
  end

  @doc """
  Get a column from a board based on the second parameter of the function.
  """
  def get_col(board, i) when i in 1..9 do
    Enum.map(1..9, &{i, &1, get(board, i, &1)})
  end

  @doc """
  Get a square from a board. The board is splitted into 9 squares. The first
  one is placed including the cells (1,1), (2,1), (3,1), (1,2), (2,2), (3,2),
  (1,3), (2,3) and (3,3). We use the parameters `xo` and `yo` to set the
  offset to retrieve these squares.

  For example, if we want the center square from (4,4) until (6,6), we have
  to pass the `xo=3` and `yo=3` to ensure the addition `x + xo` and `y + yo`
  is giving us the correct cells we want to retrieve.
  """
  def get_square(board, xo, yo) do
    for x <- 1..3, y <- 1..3 do
      {x + xo, y + yo, get(board, x + xo, y + yo)}
    end
  end

  @doc """
  Retrieve the invalid possitions (if any). If the board isn't valid we can
  retrieve the invalid positions. This function is used internally by
  `validate/1` to populate `errors`.

  Examples:

      iex> alias SudokuGame.Board
      iex> Board.new()
      iex> |> Board.put(1, 1, 9)
      iex> |> Board.put(3, 1, 9)
      iex> |> Board.get_invalid_positions()
      [{{1, 1}, {3, 1}, 9}]

      iex> alias SudokuGame.Board
      iex> Board.new()
      iex> |> Board.put(1, 1, 9)
      iex> |> Board.put(3, 3, 9)
      iex> |> Board.get_invalid_positions()
      [{{1, 1}, {3, 3}, 9}]

      iex> alias SudokuGame.Board
      iex> Board.new()
      iex> |> Board.put(1, 1, 9)
      iex> |> Board.put(1, 3, 9)
      iex> |> Board.get_invalid_positions()
      [{{1, 1}, {1, 3}, 9}]
  """
  def get_invalid_positions(%__MODULE__{} = board) do
    errors_lines =
      for i <- 1..9 do
        #  check rows
        errors_rows =
          get_row(board, i)
          |> get_errors()

        #  check columns
        errors_cols =
          get_col(board, i)
          |> get_errors()

        errors_rows ++ errors_cols
      end

    #  check squares
    errors_squares =
      for xo <- [0, 3, 6], yo <- [0, 3, 6] do
        get_square(board, xo, yo)
        |> get_errors()
      end

    List.flatten(errors_lines ++ errors_squares)
    |> Enum.uniq()
  end

  @doc """
  Give us the possible values for an empty position into the board (given by
  `x` and `y`). The result is a list of numbers ordered.

  Examples:

      iex> alias SudokuGame.Board
      iex> board = Board.new() |> Board.put(1, 1, 9)
      iex> Board.possible_values(board, 2, 1)
      [1, 2, 3, 4, 5, 6, 7, 8]

      iex> alias SudokuGame.Board
      iex> Board.new()
      iex> |> Board.put(1, 1, 1)
      iex> |> Board.put(3, 1, 3)
      iex> |> Board.put(4, 1, 4)
      iex> |> Board.put(5, 1, 5)
      iex> |> Board.put(6, 1, 6)
      iex> |> Board.put(7, 1, 7)
      iex> |> Board.put(8, 1, 8)
      iex> |> Board.put(9, 1, 9)
      iex> |> Board.possible_values(2, 1)
      [2]
  """
  def possible_values(%__MODULE__{} = board, x, y) when x in 1..9 and y in 1..9 do
    row = get_row(board, y)
    col = get_col(board, x)
    xo = div(x - 1, 3) * 3
    yo = div(y - 1, 3) * 3
    square = get_square(board, xo, yo)

    nums =
      (row ++ col ++ square)
      |> Enum.map(fn {_, _, n} -> n end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    for i <- 1..9, i not in nums, do: i
  end

  @doc """
  Convert the board into a list of lists.

  Examples:
      iex> alias SudokuGame.Board
      iex> Board.new()
      iex> |> Board.to_list()
      [
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0]
      ]

      iex> alias SudokuGame.Board
      iex> Board.new()
      iex> |> Board.put(1, 1, 1)
      iex> |> Board.put(2, 1, 2)
      iex> |> Board.put(3, 1, 3)
      iex> |> Board.to_list()
      [
        [1, 2, 3, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0]
      ]
  """
  def to_list(%__MODULE__{cells: cells}) do
    for y <- 1..9 do
      for x <- 1..9 do
        cells[x][y] || 0
      end
    end
  end

  @doc """
  Show the board from SudokuGame.Board. We can pass or the board
  struct data or the list generated by `Enum.to_list/1`.
  """
  def to_string(%_{cells: cells}) do
    draw(fn xo, yo, x, y ->
      " #{cells[x + xo][y + yo] || " "} "
    end)
  end

  def to_string(board) when is_list(board) do
    draw(fn xo, yo, x, y ->
      board
      |> Enum.at(y + yo - 1)
      |> Enum.at(x + xo - 1)
      |> case do
        0 -> "   "
        n -> " #{n} "
      end
    end)
  end

  defp draw(get_cell) do
    for yo <- [0, 3, 6] do
      for y <- 1..3 do
        for xo <- [0, 3, 6] do
          for x <- 1..3 do
            get_cell.(xo, yo, x, y)
          end
          |> Enum.join("|")
        end
        |> Enum.join("||")
        |> String.replace_prefix("", "||")
        |> String.replace_suffix("", "||\n")
        |> String.replace_suffix("", "++---+---+---++---+---+---++---+---+---++\n")
      end
      |> Enum.join("")
      |> String.replace_prefix("", "++---+---+---++---+---+---++---+---+---++\n")
    end
    |> Enum.join()
  end

  @doc """
  Get the stats for the current game. It's getting the following data:

  - `missing`: a list of the missing numbers to be put into the board,
    as a map where the key is the number and the value the count of the
    missing elements.
  - `empty`: the empty positions into the board. Only counter.
  - `sec_played`: the amount of time played (in seconds).
  - `errors`: a list of errors, copied from `errors` from board.
  - `valid?`: same as `valid?` from board.
  """
  def get_stats(board) do
    counters = for i <- 1..9, into: %{}, do: {i, 9}

    missing =
      for x <- 1..9, y <- 1..9, reduce: counters do
        counters ->
          idx = board.cells[x][y]

          if value = counters[idx] do
            %{counters | idx => value - 1}
          else
            counters
          end
      end

    empty =
      for x <- 1..9, y <- 1..9, reduce: 0 do
        empty ->
          if board.cells[x][y] do
            empty + 1
          else
            empty
          end
      end

    now = NaiveDateTime.utc_now()

    %{
      missing: missing,
      empty: 81 - empty,
      secs_played: NaiveDateTime.diff(now, board.started_at),
      errors: board.errors,
      valid?: board.valid?
    }
  end

  defimpl Enumerable, for: __MODULE__ do
    @moduledoc """
    Facility to let us enumerate the board as a list or a collection,
    using the first list to store all of the rows inside.

    Example:
        iex> alias SudokuGame.Board
        iex> Board.new()
        iex> |> Board.put(1, 1, 1)
        iex> |> Board.put(2, 1, 2)
        iex> |> Board.put(3, 1, 3)
        iex> |> Enum.to_list()
        [
          [1, 2, 3, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0]
        ]
    """

    def count(_), do: {:error, __MODULE__}
    def slice(_), do: {:error, __MODULE__}

    def member?(%_{cells: cells}, {x, y, v}) do
      {:ok, cells[x][y] == v}
    end

    def member?(_, _), do: {:error, __MODULE__}

    def reduce(board, acc, fun) do
      Enumerable.List.reduce(SudokuGame.Board.to_list(board), acc, fun)
    end
  end

  defimpl String.Chars, for: __MODULE__ do
    @moduledoc """
    Facility to show into the shell, using `IO.puts/1` (mainly), the board.
    """

    @doc """
    Show the board from SudokuGame.Board.
    """
    defdelegate to_string(board), to: SudokuGame.Board
  end
end
