defmodule SudokuGame do
  use GenServer

  alias SudokuGame.Board

  defstruct board: Board.new()

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def play(pid \\ __MODULE__, x, y, v) do
    GenServer.call(pid, {:play, x, y, v})
  end

  def get_board(pid \\ __MODULE__) do
    GenServer.call(pid, :get_board)
  end

  def is_completed?(pid \\ __MODULE__) do
    GenServer.call(pid, :is_completed?)
  end

  def restart(pid \\ __MODULE__) do
    GenServer.cast(pid, :restart)
  end

  def get_stats(pid \\ __MODULE__) do
    GenServer.call(pid, :get_stats)
  end

  @impl GenServer
  def init([]) do
    {:ok, %__MODULE__{}}
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
        {:reply, {:ok, :continue}, %__MODULE__{state | board: board}}
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
