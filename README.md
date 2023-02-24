# Sudoku

Sudoku (数独) is a mathematical game very popular in Japan in the 80s. The goal is to fill a grid of 9x9 cells (81 cells in total) avoiding repeat numbers vertically, horizontally or inside of the same subspace (3x3).

## Installation

It's easy to install. You only need to have [Elixir](https://elixir-lang.org/install.html) installed and run this to obtain the code:

```
git clone git@github.com:altenwald/sudoku.git
```

Then you can see there is a new directory in that path called `sudoku`. You can go inside using the terminal and write:

```
iex -S mix run
```

The Elixir shell will be running after the compilation. Then you could see the screen of the game:

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

iex(1)>
```

You can use then one of the following functions (they are imported to the shell):

- `chosen/1` - you can choose a number to play with. It's useful for highlighting them on the screen.
- `write/2` - once you have chosen a number, you can write down a number on the board using the two parameters as `x` and `y` positions in the range of `1..9`.

You can see more functions in the `SudokuConsole` module.

Enjoy!
