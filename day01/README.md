# [--- Day01 - Trebuchet?! ---](https://adventofcode.com/2023/day/1)

On day 1 we need to parse the input and retrieve the first and last digit of each
line to form a single two-digit number, the sum of every number is our result

For example:

```
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
```

In this example the numbers of these four lines are `12`, `38`, `15`, and `77`
Adding these up produces `142`

## Part 1

First I needed to split the input into seperate lines

```elixir
lines
|> String.trim()
|> String.split("\n")
```

Then I wrote a helper function that parses a line into a single two-digit integer

```elixir
@spec parse_line1(String.t()) :: integer()
defp parse_line1(line) do
numbers =
  line
  |> String.to_charlist()
  |> Enum.filter(fn char -> char >= ?0 and char <= ?9 end)

[List.first(numbers), List.last(numbers)]
|> List.to_integer()
end
```

I can then map this function onto every line and sum to get the result for part1!

```elixir
@spec part1(String.t()) :: integer()
def part1(lines \\ @input) do
  lines
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn line -> parse_line1(line) end)
  |> Enum.sum()
end
```

## Part 2

For part 2 we need to consider spelled out digits as well, like: `one`, `two`, ..., `nine`

For example:

```
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

In this example, the calibration values are `29`, `83`, `13`, `24`, `42`, `14`,
and `76`. Adding these together produces `281`.

---

First I needed to split the input into seperate lines just like part 1

```elixir
lines
|> String.trim()
|> String.split("\n")
```

But now when parsing we need to consider spelled out numbers also. To do that I
wrote a new `parse_line2` function to help with that

```elixir
@spec parse_line2(String.t()) :: integer()
defp parse_line2(line) do
  numbers = line |> String.to_charlist() |> do_parse_line2([])

  [List.first(numbers), List.last(numbers)]
  |> List.to_integer()
end
```

To handle the spelled out digits, I wrote a recursive function `do_parse_line2`
that checks if the beginning of the charlist matches a digit and adds that digit
to the accumulator if it does.

The first clause of 9 for checking for spelled out digits

```elixir
defp do_parse_line2([?o | [?n | [?e | _]] = rest], acc) do
  do_parse_line2(rest, [?1 | acc])
end
```

If the chararacter is a digit then add it to the accumulator.
If the character is not a digit then skip it.

```elixir
defp do_parse_line2([head | rest], acc) do
  if head >= ?0 and head <= ?9 do
    do_parse_line2(rest, [head | acc])
  else
    do_parse_line2(rest, acc)
  end
end
```

Base case: when we run out of chararacters, return the accumulator

```elixir
defp do_parse_line2([], acc) do
  acc
  |> Enum.reverse()
end
```

We can then map `parse_line2` onto every line and sum it up to get the result for part2!

```elixir
@spec part2(String.t()) :: integer()
def part2(lines \\ @input) do
  lines
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn line -> parse_line2(line) end)
  |> Enum.sum()
end
```
