defmodule SudokuGame.History do
  @moduledoc """
  History let us store the moves to reproduce from the beginning a game.
  This is storing the initial board and the moves with their timestamps.
  """
  use Agent

  alias SudokuGame.Board

  @type move() :: {
          NaiveDateTime.t(),
          {Board.x_pos(), Board.y_pos()},
          Board.content()
        }

  @type t() :: %__MODULE__{
          moves: [move()],
          initial_board: [[Board.content()]]
        }

  defstruct moves: [],
            initial_board: nil

  def start_link(board) do
    Agent.start_link(fn ->
      %__MODULE__{initial_board: board}
    end)
  end

  defdelegate stop(history), to: GenServer

  def play(history, t, pos, v) do
    Agent.update(history, &%__MODULE__{&1 | moves: [{t, pos, v} | &1.moves]})
  end

  def undo(history) do
    Agent.get_and_update(history, fn state ->
      case state.moves do
        [{t, {x, y}, v} | moves] ->
          old_value =
            moves
            |> Enum.find(fn {_, {xi, yi}, _value} -> xi == x and yi == y end)
            |> case do
              nil ->
                state.initial_board
                |> Enum.at(y - 1)
                |> Enum.at(x - 1)

              {_, {_x, _y}, value} ->
                value
            end

          state = %__MODULE__{state | moves: moves}
          {{t, {x, y}, old_value, v}, state}

        [] ->
          {nil, state}
      end
    end)
  end
end
