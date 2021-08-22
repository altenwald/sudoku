defmodule SudokuGameMock do
  use GenServer

  def start_link(responses) do
    GenServer.start_link(__MODULE__, [self(), responses])
  end

  def stop(pid), do: GenServer.stop(pid)

  def init([pid, responses]) do
    {:ok, {pid, responses}}
  end

  def handle_call(key, _from, {pid, responses}) do
    [response | rest_responses] = responses[key]
    send(pid, {self(), response})
    {:reply, response, {pid, Map.put(responses, key, rest_responses)}}
  end
end
