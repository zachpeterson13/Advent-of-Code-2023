# [--- Day 2: Cube Conundrum ---](https://adventofcode.com/2023/day/2)

On day 2 we need to parse the input of cube games and determine which games would
be possible if only 12 red cubes, 13 green cubes, and 14 blue cubes are in the game.
Add up the game IDs of the possible games to get the answer.

For example

```
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
```

In this example game `1`, `2`, and `5` would have been possible.
If we add up the Id's of the possible games we get `8`.

# Part 1

First I split the input into seperate lines

```elixir
lines
|> String.trim()
|> String.split("\n")
```

I wrote a helper function to parse each line

First I get the game ID

```elixir
def parse_line1(line) do
  "Game " <> line = line

  [num | rest] = String.split(line)
  {num, _} = Integer.parse(num)

  ...
end
```

I then split the game into seperate rounds and map the `validate_game` function onto each round.
I then check that each round was possible with the `Enum.all?` function

```elixir
def parse_line1(line) do
  ...

  line = Enum.join(rest, " ")

  valid =
    String.split(line, ";")
    |> Enum.map(&validate_game/1)
    |> Enum.all?()

  {valid, num}
end
```

Here is the `validate_game` function

```elixir
defp validate_game(game) do
  game
  |> String.split(", ")
  |> Enum.map(&String.trim/1)
  |> Enum.map(&Integer.parse/1)
  |> Enum.map(fn {num, " " <> color} ->
    case {num, color} do
      {num, "blue"} when num <= 14 -> true
      {num, "green"} when num <= 13 -> true
      {num, "red"} when num <= 12 -> true
      _ -> false
    end
  end)
  |> Enum.all?()
end
```

I can then map `parse_line1` onto every line, filter out the invalid games,
and sum the IDs of the rest

```elixir
def part1(lines \\ @input) do
  lines
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&parse_line1/1)
  |> Enum.filter(&elem(&1, 0))
  |> Enum.reduce(0, &(&2 + elem(&1, 1)))
end
```

# Part 2

For part 2 instead of having limit of cubes, we need to determine the fewest number
of cuves of each color to make a game possible. The power of a set of cubes is the
number of red, green, and blue cubes multiplied together. The result of adding up these
powers gives us our answer.

For example:

```
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
```

- In game 1, the game could have been played with as few as 4 red, 2 green, and 6 blue cubes. If any color had even one fewer cube, the game would have been impossible.
- Game 2 could have been played with a minimum of 1 red, 3 green, and 4 blue cubes.
- Game 3 must have been played with at least 20 red, 13 green, and 6 blue cubes.
- Game 4 required at least 14 red, 3 green, and 15 blue cubes.
- Game 5 needed no fewer than 6 red, 3 green, and 2 blue cubes in the bag.

The powers of games 1-5 are `48`, `12`, `1560`, `630`, and `36`. Adding these up
produces the sum `2286`

---

First we need to split the input into seperate lines just like part 1

```elixir
lines
|> String.trim()
|> String.split("\n")
```

I also defined a struct to help with counting colors

```elixir
defstruct red: 0, green: 0, blue: 0
```

This time we can ignore the game ID. I Split the game into seperate strings consisting
of a number and a color, for example: `3 blue`. Then pass this list into the `get_power` function

```elixir
defp parse_line2(line) do
  [_ | line] = String.split(line, ": ")

  List.first(line) |> String.split([",", ";"], trim: true) |> get_power()
end
```

`get_power` takes in 2 arguments, first the list of strings, and second the
accumulator, which is the scruct I defined earlier

The first clause parses the string and updates the accumulator if needed

The second and last clause multiplies the cube count to get the power when there
are no more strings to parse

```elixir
defp get_power(list, acc \\ %Day02{})

defp get_power([head | tail], acc) do
  case head |> String.trim() |> Integer.parse() do
    {num, " green"} when num > acc.green ->
      get_power(tail, %{acc | green: num})

    {num, " red"} when num > acc.red ->
      get_power(tail, %{acc | red: num})

    {num, " blue"} when num > acc.blue ->
      get_power(tail, %{acc | blue: num})

    _ ->
      get_power(tail, acc)
  end
end

defp get_power([], acc) do
  acc.blue * acc.red * acc.green
end
```

Finally we can map the `parse_line2` function onto each line and call `Enum.sum`
on the result

```elixir
def part2(lines \\ @input) do
  lines |> String.trim() |> String.split("\n") |> Enum.map(&parse_line2/1) |> Enum.sum()
end
```
