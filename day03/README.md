# [--- Day 3: Gear Ratios ---](https://adventofcode.com/2023/day/3)

On day 3 we need parse the input, which consists of numbers and symbols.
Any number adjacent to a symbol, even diagonally, is a number that should be
included in your sum.

For example:

```
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
```

In this schematic, two numbers are not part numbers because they are not adjacent
to a symbol: `114` (top right) and `58` (middle right). Every other number is adjacent
to a symbol and so is a part number; their sum is `4361`.

## Part 1

First I split the input into seperate lines and convert the strings to charlists

```elixir
input |> String.split("\n") |> Enum.map(&to_charlist/1)
```

In order to solve this problem, I decided to make a grid of all symbols and numbers.
The function `make_grid` constructs a map that maps a position tuple `{x, y}` to a value
This function also creates a list of all symbol positions

```elixir
def make_grid([[value | rest] | tail], grid, symbols, x, y) do
if value != ?. do
  pos = {x, y}

  if not is_numeric?(value) do
    make_grid([rest | tail], Map.put(grid, pos, value), [pos | symbols], x + 1, y)
  else
    make_grid([rest | tail], Map.put(grid, pos, value), symbols, x + 1, y)
  end
else
  make_grid([rest | tail], grid, symbols, x + 1, y)
end
end

def make_grid([[] | tail], grid, symbols, _, y), do: make_grid(tail, grid, symbols, 0, y + 1)

def make_grid([], grid, symbols, _, _), do: {grid, Enum.reverse(symbols)}
```

Pass our list of charlists to the `make_grid` function

```elixir
{grid, symbols} =
  input |> String.split("\n") |> Enum.map(&to_charlist/1) |> make_grid(%{}, [], 0, 0)
```

To help make things easier next, I defined `@adj` attribute that represents
all the directions in the grid

I also made a helper function `is_numeric?`

```elixir
@adj [{-1, 1}, {0, 1}, {1, 1}, {-1, 0}, {1, 0}, {-1, -1}, {0, -1}, {1, -1}]

def is_numeric?(char) do
  char in [?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9]
end
```

`get_adj_parts` function gets all numbers adjacent to the given `pos`

In hindsight this function should probably be a wrapper for `Enum.reduce` on the symbols list

```elixir
def get_adj_parts(grid, {pX, pY} = pos, acc, [{x, y} | rest]) do
  num = get_num(grid, {pX + x, pY + y})
  get_adj_parts(grid, pos, MapSet.put(acc, num), rest)
end

def get_adj_parts(_, _, acc, []), do: acc

```

`get_num` attempts to get the number at the given `pos`, if there is no number
it returns `nil`, otherwise it calls the recursive `do_get_num` function

`do_get_num` will walk backwards in the grid to the beginning of the number,
then return the start position and parsed number

```elixir
def get_num(grid, {x, y}) do
  if(not Map.has_key?(grid, {x, y}) or not is_numeric?(grid[{x, y}])) do
    nil
  else
    do_get_num(grid, {x, y})
  end
end

defp do_get_num(grid, {x, y}) do
  if Map.has_key?(grid, {x - 1, y}) and is_numeric?(grid[{x - 1, y}]) do
    do_get_num(grid, {x - 1, y})
  else
    start = {x, y}

    {start, parse_number(grid, start, [])}
  end
end

def parse_number(grid, {x, y} = pos, acc) do
  if Map.has_key?(grid, pos) and is_numeric?(grid[pos]) do
    parse_number(grid, {x + 1, y}, [grid[pos] | acc])
  else
    Enum.reverse(acc) |> to_string() |> String.to_integer()
  end
end
```

`p1` function calls `get_adj_parts` on every symbol position,
once every symbol position has been processed, it returns the sum of all the
adjacent numbers

```elixir
def p1(grid, [s | rest], acc) do
  p1(grid, rest, get_adj_parts(grid, s, acc, @adj))
end

def p1(_, [], acc) do
  acc
  |> MapSet.filter(&(not is_nil(&1)))
  |> MapSet.to_list()
  |> Enum.reduce(0, fn {_, num}, acc -> acc + num end)
end
```

Put it all together to solve part 1

```elixir
def part1(input \\ @input) do
  {grid, symbols} =
    input |> String.split("\n") |> Enum.map(&to_charlist/1) |> make_grid(%{}, [], 0, 0)

  p1(grid, symbols, MapSet.new())
end
```

## Part 2

This time we need to find the gear ration of every gear and them all up
A gear is any `*` symbol that is adjacent to exactly two part numbers
A gear ratio is the result of multiplying those two numbers together.

For example:

```
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
```

In this schematic, there are two gears. The first is in the top left; it has
part numbers `467` and `35`, so its gear ratio is `16345`. The second gear is in the
lower right; its gear ratio is `451490`. (The \* adjacent to `617` is not a gear because
it is only adjacent to one part number.) Adding up all of the gear ratios produces `467835`.

---

Basically everything is the same, except we only consider \*'s that have 2 numbers
adjacent.

```elixir
def p2(grid, [s | rest], acc) do
  if grid[s] != ?* do
    p2(grid, rest, acc)
  else
    parts =
      get_adj_parts(grid, s, MapSet.new(), @adj)
      |> MapSet.to_list()
      |> Enum.filter(&(not is_nil(&1)))

    if length(parts) == 2 do
      ratio = Enum.reduce(parts, 1, fn {_, num}, acc -> acc * num end)
      p2(grid, rest, acc + ratio)
    else
      p2(grid, rest, acc)
    end
  end
end

def p2(_, [], acc), do: acc
```

Put it all together

```elixir
def part2(input \\ @input) do
  {grid, symbols} =
    input |> String.split("\n") |> Enum.map(&to_charlist/1) |> make_grid(%{}, [], 0, 0)

  p2(grid, symbols, 0)
end
```
