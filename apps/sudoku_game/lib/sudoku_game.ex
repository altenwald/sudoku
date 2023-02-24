defmodule SudokuGame do
  use GenServer, restart: :transient

  alias SudokuGame.{Board, History}

  @sup_reg SudokuGame.Game.Registry

  @type t() :: %__MODULE__{
          board: Board.t(),
          history: pid()
        }

  @type no_position_error() :: {:no_solution, {Board.x_pos(), Board.y_pos()}, Board.content()}

  defstruct [:board, :history]

  defp via(name), do: {:via, Registry, {@sup_reg, name}}

  @spec start(game :: String.t()) :: DynamicSupervisor.on_start_child()
  def start(game, board \\ Board.generate()) do
    name = via(game)
    DynamicSupervisor.start_child(SudokuGame.Games, {SudokuGame, [name, board]})
  end

  def get_pid(name) do
    GenServer.whereis(via(name))
  end

  @spec start_link([GenServer.name() | Board.t()]) :: GenServer.on_start()
  def start_link([name, board]) do
    GenServer.start_link(__MODULE__, [board], name: name)
  end

  @spec stop(GenServer.server()) :: :ok
  def stop(pid) when is_pid(pid) do
    GenServer.stop(pid)
  end

  def stop(name) do
    GenServer.stop(via(name))
  end

  @spec play(GenServer.server(), Board.x_pos(), Board.y_pos(), Board.content()) ::
          {:ok, :complete}
          | {:ok, :continue}
          | {:error, [Board.position_error()] | no_position_error()}
  def play(pid \\ __MODULE__, x, y, v) do
    GenServer.call(pid, {:play, x, y, v})
  end

  @spec get_board(GenServer.server()) :: [[0..9]]
  def get_board(pid \\ __MODULE__) do
    GenServer.call(pid, :get_board)
  end

  def get_pos(pid \\ __MODULE__, x, y) when x in 1..9 and y in 1..9 do
    GenServer.call(pid, {:get_pos, x, y})
  end

  def undo(pid \\ __MODULE__) do
    GenServer.call(pid, :undo)
  end

  @spec is_completed?(GenServer.server()) :: boolean()
  def is_completed?(pid \\ __MODULE__) do
    GenServer.call(pid, :is_completed?)
  end

  @spec restart(GenServer.server()) :: :ok
  def restart(pid \\ __MODULE__) do
    GenServer.cast(pid, :restart)
  end

  @spec get_stats(GenServer.server()) :: Board.stats_map()
  def get_stats(pid \\ __MODULE__) do
    GenServer.call(pid, :get_stats)
  end

  @impl GenServer
  @spec init([Board.t()]) :: {:ok, t()}
  def init([board]) do
    board_list = Board.to_list(board)
    {:ok, history} = History.start_link(board_list)
    {:ok, %__MODULE__{board: board, history: history}}
  end

  @impl GenServer
  def handle_call({:play, x, y, v}, _from, state) do
    board =
      Board.put(state.board, x, y, v)
      |> Board.validate()

    History.play(state.history, NaiveDateTime.utc_now(), {x, y}, v)

    if board.valid? do
      if Board.is_completed?(board) do
        {:reply, {:ok, :complete}, %__MODULE__{state | board: board}}
      else
        if Board.has_solution?(board) do
          {:reply, {:ok, :continue}, %__MODULE__{state | board: board}}
        else
          {:reply, {:error, {:no_solution, {x, y}, v}}, %__MODULE__{state | board: board}}
        end
      end
    else
      {:reply, {:error, board.errors}, %__MODULE__{state | board: board}}
    end
  end

  def handle_call(:get_board, _from, state) do
    {:reply, Enum.to_list(state.board), state}
  end

  def handle_call(:is_completed?, _from, state) do
    {:reply, Board.is_completed?(state.board), state}
  end

  def handle_call(:get_stats, _from, state) do
    {:reply, Board.get_stats(state.board), state}
  end

  def handle_call({:get_pos, x, y}, _from, state) do
    {:reply, Board.get(state.board, x, y), state}
  end

  def handle_call(:undo, _from, state) do
    case History.undo(state.history) do
      {_t, {x, y}, old_value, _v} ->
        board =
          Board.put(state.board, x, y, old_value)
          |> Board.validate()

        if board.valid? do
          if Board.has_solution?(board) do
            {:reply, {:ok, :continue}, %__MODULE__{state | board: board}}
          else
            {:reply, {:error, {:no_solution, {x, y}, old_value}},
             %__MODULE__{state | board: board}}
          end
        else
          {:reply, {:error, board.errors}, %__MODULE__{state | board: board}}
        end

      nil ->
        IO.warn("no more undo!")
        {:reply, {:error, :no_more_undo}, state}
    end
  end

  @impl GenServer
  def handle_cast(:restart, state) do
    :ok = History.stop(state.history)
    board = Board.generate()
    board_list = Board.to_list(board)
    {:ok, history} = History.start_link(board_list)
    {:noreply, %__MODULE__{state | board: Board.generate(), history: history}}
  end
end
