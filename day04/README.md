# [--- Day 4: Scratchcards ---](https://adventofcode.com/2023/day/4)

Our input is a list of cards, each card has a list of winning numbers and a
list of numbers you have seperated by a vertical bar `|`

Each match of a winning number you have double the value of the card, starting at 1

For example:

```
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
```

In the above example, card 1 has five winning numbers (41, 48, 83, 86, and 17)
and eight numbers you have (83, 86, 6, 31, 17, 9, 48, and 53). Of the numbers
you have, four of them (48, 83, 17, and 86) are winning numbers! That means card
1 is worth 8 points (1 for the first match, then doubled three times for each of
the three matches after the first).

- Card 2 has two winning numbers (32 and 61), so it is worth 2 points.
- Card 3 has two winning numbers (1 and 21), so it is worth 2 points.
- Card 4 has one winning number (84), so it is worth 1 point.
- Card 5 has no winning numbers, so it is worth no points.
- Card 6 has no winning numbers, so it is worth no points.

So, in this example, the cards are worth 13 points total.

## Part 1

Start by splitting the input into seperate lines

```elixir
def part1(input \\ @input) do
  input
  |> String.split("\n", trim: true)

  ...
end
```

Map the `parse_nums` function on the lines

The `parse_nums` funcions splits the winners from the numbers you have
and then converts the string representation of numbers to integers

```elixir
def parse_nums(line) do
  [_ | [winners | [numbers | []]]] =
    line |> String.split([":", " | "], trim: true) |> Enum.map(&String.split/1)

  {winners |> Enum.map(&String.to_integer/1), numbers |> Enum.map(&String.to_integer/1)}
end

def part1(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_nums/1)
    ...
end
```

Map the `check_for_winners` function on the each card call `Enum.sum` on the result
to get the answer.

The `check_for_winners` counts how many winning numbers there are does some math
to calculate the score.

```elixir
def part1(input \\ @input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&parse_nums/1)
  |> Enum.map(&check_for_winners/1)
  |> Enum.sum()
end

def check_for_winners(nums, count \\ 0)

def check_for_winners({winners, [head | tail]}, count) do
  if head in winners do
    check_for_winners({winners, tail}, count + 1)
  else
    check_for_winners({winners, tail}, count)
  end
end

def check_for_winners(_, count), do: :math.pow(2, count - 1) |> floor()
```

## Part 2

Instead of points, each winning number wins you more scratchcards.
You win copies of next scratchcards equal to the number of winning numbers
Copies of scratchcards are scored like normal scratchcards

This time, the above example goes differently:

```
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
```

- Card 1 has four matching numbers, so you win one copy each of the next four cards: cards 2, 3, 4, and 5.
- Your original card 2 has two matching numbers, so you win one copy each of cards 3 and 4.
- Your copy of card 2 also wins one copy each of cards 3 and 4.
- Your four instances of card 3 (one original and three copies) have two matching numbers, so you win four copies each of cards 4 and 5.
- Your eight instances of card 4 (one original and seven copies) have one matching number, so you win eight copies of card 5.
- Your fourteen instances of card 5 (one original and thirteen copies) have no matching numbers and win no more cards.
- Your one instance of card 6 (one original) has no matching numbers and wins no more cards.

Once all of the originals and copies have been processed, you end up with 1
instance of card 1, 2 instances of card 2, 4 instances of card 3, 8 instances
of card 4, 14 instances of card 5, and 1 instance of card 6. In total, this
example pile of scratchcards causes you to ultimately have 30 scratchcards!

---

We start off by mapping the `parse_line` function on all the cards.
We then reduce the resulting maps into a single map. We then create a queue from the
keys of our map, which represents our initial set of cards

The `parse_line` function maps game number to a tuple containing the winning
numbers and your numbers

Optimization oportunity: Instead of creating a mapping between game number and
a tuple containing the winning numbers and your numbers, it would be better to
calculate the count of winning numbers here and create mapping between game number
and the number of winning numbers.

```elixir
def part2(input \\ @input) do
  card_map =
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, fn map, acc -> Map.merge(map, acc) end)

  q =
    card_map
    |> Map.keys()
    |> :queue.from_list()

  ...
end

def(parse_line(line)) do
  [game | [winners | [numbers | []]]] =
    line |> String.split([":", " | "], trim: true) |> Enum.map(&String.split/1)

  game = List.last(game) |> String.to_integer()
  winners = Enum.map(winners, &String.to_integer/1)
  numbers = Enum.map(numbers, &String.to_integer/1)

  %{game => {winners, numbers}}
end

```

The `process_queue` function takes out a card number from the queue and counts the winners.
Then adds the cards we won to the queue.

The `count_winners` is basically the same as `check_for_winners` but instead returns the
count of winning numbers instead of points

```elixir
def process_queue(_, {[], []}, count), do: count

def process_queue(map, q, count) do
  {{:value, num}, q} = :queue.out(q)
  winners = count_winners(map[num])

  if winners == 0 do
    process_queue(map, q, count + winners)
  else
    q =
      (num + 1)..(num + winners)
      |> Enum.reduce(q, fn n, acc -> :queue.in(n, acc) end)

    process_queue(map, q, count + winners)
  end
end

def count_winners(nums, count \\ 0)

def count_winners({winners, [head | tail]}, count) do
  if head in winners do
    count_winners({winners, tail}, count + 1)
  else
    count_winners({winners, tail}, count)
  end
end

def count_winners(_, count), do: count
```

Put it all together.

```elixir
def part2(input \\ @input) do
  card_map =
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, fn map, acc -> Map.merge(map, acc) end)

  q =
    card_map
    |> Map.keys()
    |> :queue.from_list()

  process_queue(card_map, q, :queue.len(q))
end
```
