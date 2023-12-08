# [--- Day 7: Camel Cards ---](https://adventofcode.com/2023/day/7)

In Camel Cards, you get a list of hands, and your goal is to order them based on
the strength of each hand. A hand consists of five cards labeled one of `A`, `K`, `Q`,
`J`, `T`, `9`, `8`, `7`, `6`, `5`, `4`, `3`, or `2`. The relative strength of each card follows this
order, where `A` is the highest and `2` is the lowest.

Every hand is exactly one type. From strongest to weakest, they are:

- Five of a kind, where all five cards have the same label: `AAAAA`
- Four of a kind, where four cards have the same label and one card has a different label: `AA8AA`
- Full house, where three cards have the same label, and the remaining two cards share a different label: `23332`
- Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: `TTT98`
- Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: `23432`
- One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: `A23A4`
- High card, where all cards' labels are distinct: `23456`

Hands are primarily ordered based on type; for example, every full house is
stronger than any three of a kind.

If two hands have the same type, a second ordering rule takes effect. Start by
comparing the first card in each hand. If these cards are different, the hand
with the stronger first card is considered stronger. If the first card in each
hand have the same label, however, then move on to considering the second card
in each hand. If they differ, the hand with the higher second card wins;
otherwise, continue with the third card in each hand, then the fourth, then the
fifth.

So, `33332` and `2AAAA` are both four of a kind hands, but `33332` is stronger
because its first card is stronger. Similarly, `77888` and `77788` are both a
full house, but `77888` is stronger because its third card is stronger (and both
hands have the same first and second card).

To play Camel Cards, you are given a list of hands and their corresponding bid (your puzzle input). For example:

```
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
```

This example shows five hands; each hand is followed by its bid amount. Each
hand wins an amount equal to its bid multiplied by its rank, where the weakest
hand gets rank 1, the second-weakest hand gets rank 2, and so on up to the
strongest hand. Because there are five hands in this example, the strongest hand
will have rank 5 and its bid will be multiplied by 5.

So, the first step is to put the hands in order of strength:

- `32T3K` is the only **one pair** and the other hands are all a stronger type,
  so it gets rank **1**.
- `KK677` and `KTJJT` are both **two pair**. Their first cards both have the
  same label, but the second card of `KK677` is stronger (`K` vs `T`), so `KTJJT`
  gets rank **2** and `KK677` gets rank **3**.
- `T55J5` and `QQQJA` are both **three of a kind**. `QQQJA` has a stronger first
  card, so it gets rank **5** and `T55J5` gets rank **4**.

Now, you can determine the total winnings of this set of hands by adding up the
result of multiplying each hand's bid with its rank (765 \* 1 + 220 \* 2 + 28 \* 3
\+ 684 \* 4 + 483 \* 5). So the total winnings in this example are `6440`.

Find the rank of every hand in your set. **What are the total winnings?**

## Part 1

Start by parsing the input

```elixir
input |> parse_input()
```

Here is the `parse_input` function.
Basically turning `"T55J5 684"` to `{'T55J5', 684}`

```elixir
def parse_input(input) do
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&(&1 |> String.split() |> List.to_tuple()))
  |> Enum.map(fn {hand, bid_str} -> {hand |> to_charlist(), bid_str |> String.to_integer()} end)
end
```

Map the `get_type` function on each hand

`get_type` works by counting the cards in each hand to determine the type

```elixir
def part1(input \\ @input) do
  hands =
    input
    |> parse_input()
    |> Enum.map(&get_type/1)

    ...
end

def get_type({hand, bid}) do
  card_count =
    hand
    |> Enum.reduce(%{}, fn char, acc ->
      new_value = Map.get(acc, char, 0) + 1
      Map.put(acc, char, new_value)
    end)

  type =
    case Map.values(card_count) |> Enum.sort(:desc) do
      [5] ->
        :five_of_a_kind

      [4, 1] ->
        :four_of_a_kind

      [3, 2] ->
        :full_house

      [3 | _] ->
        :three_of_a_kind

      [2, 2, 1] ->
        :two_pair

      [2 | _] ->
        :one_pair

      _ ->
        :high_card
    end

  {type, hand, bid}
end
```

Now filter hands based on type and sort with the `compare_hands` predicate function

```elixir
def part1(input \\ @input) do
  ...

  five =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :five_of_a_kind end)
    |> Enum.sort(&compare_hands/2)

  ...

  high =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :high_card end)
    |> Enum.sort(&compare_hands/2)

  ...
end
```

Here is the `compare_hands` function and the `@strength` map

```elixir
@strength [?A, ?K, ?Q, ?J, ?T, ?9, ?8, ?7, ?6, ?5, ?4, ?3, ?2]
          |> Enum.reverse()
          |> Enum.with_index()
          |> Map.new()

def compare_hands({ftype, [head | ftail], fbid}, {stype, [head | stail], sbid}) do
  compare_hands({ftype, ftail, fbid}, {stype, stail, sbid})
end

def compare_hands({_, [first | _], _}, {_, [second | _], _}) do
  @strength[first] < @strength[second]
end
```

Append all the sorted lists and calculate total winnings

```elixir
def part1(input \\ @input) do
  ...

  (high ++ one ++ two ++ three ++ full ++ four ++ five)
  |> Enum.with_index(1)
  |> Enum.map(fn {{_, _, bid}, rank} -> rank * bid end)
  |> Enum.sum()
end
```

## Part 2

`J` cards are now jokers - wildcards that can act like whatever card would make
the hand the strongest type possible.

To balance this, `J` cards are now the weakest individual cards, weaker even
than `2`. The other cards stay in the same order: `A`, `K`, `Q`, `T`, `9`, `8`,
`7`, `6`, `5`, `4`, `3`, `2`, `J`.

`J` cards can pretend to be whatever card is best for the purpose of determining
hand type; for example, `QJJQ2` is now considered four of a kind. However, for
the purpose of breaking ties between two hands of the same type, `J` is always
treated as `J`, not the card it's pretending to be: `JKKK2` is weaker than
`QQQQ2` because `J` is weaker than `Q`.

Now, the above example goes very differently:

```
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
```

- `32T3K` is still the only **one pair**; it doesn't contain any jokers, so its
  strength doesn't increase.
- `KK677` is now the only **two pair**, making it the second-weakest hand.
- `T55J5`, `KTJJT`, and `QQQJA` are now all four of a kind! `T55J5` gets rank 3,
  `QQQJA` gets rank 4, and `KTJJT` gets rank 5.

With the new joker rule, the total winnings in this example are `5905`.

Using the new joker rule, find the rank of every hand in your set. **What are the
new total winnings?**

---

All we need to do is adjust `get_type` and `compare_hands` functions and the
`@strength` map to fit the new requirements.

The biggest change in `get_type2` is to add joker_count to the card that hand
has the most of. There is a special case where a hand has 5 jokers, in this case
we change nothing.

`compare_hands2` just uses the new `@strength_joker` map instead.

```elixir
@strength_joker [?A, ?K, ?Q, ?T, ?9, ?8, ?7, ?6, ?5, ?4, ?3, ?2, ?J]
                |> Enum.reverse()
                |> Enum.with_index()
                |> Map.new()

def get_type2({hand, bid}) do
  card_count =
    hand
    |> Enum.reduce(%{}, fn char, acc ->
      new_value = Map.get(acc, char, 0) + 1
      Map.put(acc, char, new_value)
    end)

  joker_count = Map.get(card_count, ?J, 0)

  card_count =
    if joker_count == 5 do
      card_count
    else
      [{key, val} | rest] =
        card_count
        |> Map.to_list()
        |> Enum.filter(fn {key, _} -> key != ?J end)
        |> Enum.sort(fn {_, v1}, {_, v2} ->
          v1 > v2
        end)

      [{key, val + joker_count} | rest] |> Map.new()
    end

  type =
    case Map.values(card_count) |> Enum.sort(:desc) do
      [5] ->
        :five_of_a_kind

      [4 | _] ->
        :four_of_a_kind

      [3, 2] ->
        :full_house

      [3 | _] ->
        :three_of_a_kind

      [2, 2, 1] ->
        :two_pair

      [2 | _] ->
        :one_pair

      _ ->
        :high_card
    end

  {type, hand, bid}
end

def compare_hands2({ftype, [head | ftail], fbid}, {stype, [head | stail], sbid}) do
  compare_hands2({ftype, ftail, fbid}, {stype, stail, sbid})
end

def compare_hands2({_, [first | _], _}, {_, [second | _], _}) do
  @strength_joker[first] < @strength_joker[second]
end
```

Here is everything put together

```elixir
def part2(input \\ @input) do
  hands =
    input
    |> parse_input()
    |> Enum.map(&get_type2/1)

  five =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :five_of_a_kind end)
    |> Enum.sort(&compare_hands2/2)

  four =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :four_of_a_kind end)
    |> Enum.sort(&compare_hands2/2)

  full =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :full_house end)
    |> Enum.sort(&compare_hands2/2)

  three =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :three_of_a_kind end)
    |> Enum.sort(&compare_hands2/2)

  two =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :two_pair end)
    |> Enum.sort(&compare_hands2/2)

  one =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :one_pair end)
    |> Enum.sort(&compare_hands2/2)

  high =
    hands
    |> Enum.filter(fn {type, _, _} -> type == :high_card end)
    |> Enum.sort(&compare_hands2/2)

  (high ++ one ++ two ++ three ++ full ++ four ++ five)
  |> Enum.with_index(1)
  |> Enum.map(fn {{_, _, bid}, rank} -> rank * bid end)
  |> Enum.sum()
end
```
