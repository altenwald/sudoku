defmodule SudokuGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: SudokuGame.Game.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: SudokuGame.Games}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SudokuGame.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
