defmodule SudokuConsole.MixProject do
  use Mix.Project

  def project do
    [
      app: :sudoku_console,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: test_coverage(),
      deps: deps()
    ]
  end

  defp test_coverage do
    [
      ignore_modules: [
        SudokuGameMock
      ],
      summary: [
        threshold: 80
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sudoku_game, in_umbrella: true}
    ]
  end
end
