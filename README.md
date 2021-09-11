# Sudoku

Sudoku (数独) is an mathematical game very popular in Japan in 80s. The goal is to fill a grid of 9x9 cells (81 cells in total) avoiding repeat numbers vertically, horizontally or inside of the same subspace (3x3).

## Installation

It's easy to install. You only need to have [Elixir](https://elixir-lang.org/install.html) installed and run this to obtain the code:

```
git clone git@github.com:altenwald/sudoku.git
```

Then you can see there are a new directory in that path called `sudoku`. You can go inside using the terminal and write:

```
iex -S mix run
```

The Elixir shell will be running after the compilation. You can start the game using this command:

```elixir
SudokuConsole.start
```

Then you could see the screen of the game:

```
++---+---+---++---+---+---++---+---+---++
|| 2 | 5 |   ||   |   | 4 ||   | 6 | 8 ||
++---+---+---++---+---+---++---+---+---++
|| 9 |   |   || 2 |   | 5 || 3 | 7 | 4 ||
++---+---+---++---+---+---++---+---+---++
|| 7 | 4 |   ||   | 8 |   || 1 | 2 |   ||
++---+---+---++---+---+---++---+---+---++
++---+---+---++---+---+---++---+---+---++
||   | 8 |   ||   | 6 | 1 || 2 | 4 | 9 ||
++---+---+---++---+---+---++---+---+---++
|| 6 | 2 | 9 ||   | 4 | 7 ||   | 5 | 1 ||
++---+---+---++---+---+---++---+---+---++
|| 4 |   |   || 9 |   |   ||   | 3 | 6 ||
++---+---+---++---+---+---++---+---+---++
++---+---+---++---+---+---++---+---+---++
|| 5 | 7 |   ||   |   |   || 4 | 8 | 3 ||
++---+---+---++---+---+---++---+---+---++
||   |   | 4 ||   |   |   ||   |   |   ||
++---+---+---++---+---+---++---+---+---++
||   | 9 |   ||   |   | 3 || 5 |   | 2 ||
++---+---+---++---+---+---++---+---+---++

------------------------------------------------------------------------
missing: 1=6 2=3 3=5 4=1 5=4 6=5 7=5 8=5 9=4      empty: 38
time: 0 seconds
------------------------------------------------------------------------

X=
```

The system is asking you in every step for the X, Y and number to be put into that cell. It's giving you information about how many numbers are still missing and the time from the game started.

Enjoy!
