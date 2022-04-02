defmodule SudokuGame do
  use GenServer, restart: :transient

  alias SudokuGame.Board

  @sup_reg SudokuGame.Game.Registry

  @type t() :: %__MODULE__{
    board: Board.t()
  }

  @type no_position_error() :: {:no_solution, {Board.x_pos(), Board.y_pos()}, Board.content()}

  defstruct [:board]

  defp via(name), do: {:via, Registry, {@sup_reg, name}}

  @spec start(game :: String.t()) :: DynamicSupervisor.on_start_child()
  def start(game, board \\ Board.new()) do
    name = via(game)
    DynamicSupervisor.start_child(SudokuGame.Games, {SudokuGame, [name, board]})
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
    {:ok, :complete} |
    {:ok, :continue} |
    {:error, [Board.position_error()] | no_position_error()}
  def play(pid \\ __MODULE__, x, y, v) do
    GenServer.call(pid, {:play, x, y, v})
  end

  @spec get_board(GenServer.server()) :: [[0..9]]
  def get_board(pid \\ __MODULE__) do
    GenServer.call(pid, :get_board)
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
    {:ok, %__MODULE__{board: board}}
  end

  @impl GenServer
  def handle_call({:play, x, y, v}, _from, state) do
    board =
      Board.put(state.board, x, y, v)
      |> Board.validate()

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

  @impl GenServer
  def handle_cast(:restart, state) do
    {:noreply, %__MODULE__{state | board: Board.generate()}}
  end
end
