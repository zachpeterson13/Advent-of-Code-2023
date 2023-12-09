# [--- Day 8: Haunted Wasteland ---](https://adventofcode.com/2023/day/8)

You're still riding a camel across Desert Island when you spot a sandstorm
quickly approaching. When you turn to warn the Elf, she disappears before your
eyes! To be fair, she had just finished warning you about ghosts a few minutes
ago.

One of the camel's pouches is labeled "maps" - sure enough, it's full of
documents (your puzzle input) about how to navigate the desert. At least, you're
pretty sure that's what they are; one of the documents contains a list of
left/right instructions, and the rest of the documents seem to describe some
kind of network of labeled nodes.

It seems like you're meant to use the left/right instructions to navigate the
network. Perhaps if you have the camel follow the same instructions, you can
escape the haunted wasteland!

After examining the maps for a bit, two nodes stick out: `AAA` and `ZZZ`. You
feel like `AAA` is where you are now, and you have to follow the left/right
instructions until you reach `ZZZ`.

This format defines each node of the network individually. For example:

```
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
```

Starting with `AAA`, you need to look up the next element based on the next
left/right instruction in your input. In this example, start with `AAA` and go
right (`R`) by choosing the right element of `AAA`, `CCC`. Then, `L` means to choose the
left element of `CCC`, `ZZZ`. By following the left/right instructions, you reach
`ZZZ` in 2 steps.

Of course, you might not find `ZZZ` right away. If you run out of left/right
instructions, repeat the whole sequence of instructions as necessary: `RL`
really means `RLRLRLRLRLRLRLRL`... and so on. For example, here is a situation
that takes 6 steps to reach `ZZZ`:

```
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
```

Starting at `AAA`, follow the left/right instructions. How many steps are required to reach `ZZZ`?

## Part 1

I start by creating some fuctions to get the instructions and node map from the input

```elixir
def parse_input(input) do
  [inst, rest] = input |> String.split("\n\n", trim: true)

  inst = inst |> to_charlist() |> :queue.from_list()

  map =
    rest
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(&Map.merge/2)

  {inst, map}
end

def parse_line(line) do
  [key, rest] = line |> String.split(" = ", trim: true)

  [?(, l1, l2, l3, ?,, ?\s, r1, r2, r3, ?)] = rest |> to_charlist()

  left = [l1, l2, l3] |> to_string()
  right = [r1, r2, r3] |> to_string()

  %{key => {left, right}}
end
```

pass our input to the `parse_input` function

```elixir
def part1(input \\ @input) do
  {inst_q, map} = input |> parse_input()

  ...
end
```

`process` function walks the nodes until the `ZZZ` node.

```elixir
def process(map, inst_q, key, acc \\ 0)

def process(_, _, "ZZZ", acc), do: acc

def process(map, inst_q, key, acc) do
  {left, right} = map[key]

  {{:value, direction}, inst_q} = :queue.out(inst_q)

  inst_q = :queue.in(direction, inst_q)

  if direction == ?L do
    process(map, inst_q, left, acc + 1)
  else
    process(map, inst_q, right, acc + 1)
  end
end
```

Putting it together

```elixir
def part1(input \\ @input) do
  {inst_q, map} = input |> parse_input()

  process(map, inst_q, "AAA")
end
```

## Part 2

The sandstorm is upon you and you aren't any closer to escaping the wasteland.
You had the camel follow the instructions, but you've barely left your starting
position. It's going to take significantly more steps to escape!

What if the map isn't for people - what if the map is for ghosts? Are ghosts
even bound by the laws of spacetime? Only one way to find out.

After examining the maps a bit longer, your attention is drawn to a curious
fact: the number of nodes with names ending in `A` is equal to the number ending
in `Z`! If you were a ghost, you'd probably just start at every node that ends
with `A` and follow all of the paths at the same time until they all
simultaneously end up at nodes that end with `Z`.

For example:

```
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
```

Here, there are two starting nodes, `11A` and `22A` (because they both end with `A`).
As you follow each left/right instruction, use that instruction to
simultaneously navigate away from both nodes you're currently on. Repeat this
process until all of the nodes you're currently on end with `Z`. (If only some of
the nodes you're on end with `Z`, they act like any other node and you continue as
normal.) In this example, you would proceed as follows:

- Step 0: You are at `11A` and `22A`.
- Step 1: You choose all of the left paths, leading you to `11B` and `22B`.
- Step 2: You choose all of the right paths, leading you to `11Z` and `22C`.
- Step 3: You choose all of the left paths, leading you to `11B` and `22Z`.
- Step 4: You choose all of the right paths, leading you to `11Z` and `22B`.
- Step 5: You choose all of the left paths, leading you to `11B` and `22C`.
- Step 6: You choose all of the right paths, leading you to `11Z` and `22Z`.

So, in this example, you end up entirely on nodes that end in `Z` after `6` steps.

Simultaneously start on every node that ends with `A`. How many steps does it take before you're only on nodes that end with `Z`?

---

First thing we need to do different is find all the keys that end in `A`

The `find_starts` function does exactly that.

```elixir
def part2(input \\ @input) do
  {inst_q, map} = input |> parse_input()

  find_starts(map)
  ...
end

def find_starts(map) do
  map
  |> Map.keys()
  |> Enum.filter(fn key -> match?(<<_, _, ?A>>, key) end)
end
```

The `process2` function is the same as `process` but walks until a node that ends in `Z`

```elixir
def process2(map, inst_q, key, acc \\ 0)

def process2(_, _, <<_, _, ?Z>>, acc), do: acc

def process2(map, inst_q, key, acc) do
  {left, right} = map[key]

  {{:value, direction}, inst_q} = :queue.out(inst_q)

  inst_q = :queue.in(direction, inst_q)

  if direction == ?L do
    process2(map, inst_q, left, acc + 1)
  else
    process2(map, inst_q, right, acc + 1)
  end
end
```

Map that function on all the starting nodes. Find the least common multiple of
the counts by reducing the list with a lcm function.

```elixir
def part2(input \\ @input) do
  {inst_q, map} = input |> parse_input()

  find_starts(map)
  |> Enum.map(&process2(map, inst_q, &1))
  # |> Task.async_stream(&process2(map, inst_q, &1))
  # |> Enum.map(fn {:ok, val} -> val end)
  |> Enum.reduce(&lcm/2)
end
```

Alternitively use `Task.async_stream` instead of `Enum.map` to do a little parallization.
On my computer it is about 2x faster.

```elixir
def part2(input \\ @input) do
  {inst_q, map} = input |> parse_input()

  find_starts(map)
  # |> Enum.map(&process2(map, inst_q, &1))
  |> Task.async_stream(&process2(map, inst_q, &1))
  |> Enum.map(fn {:ok, val} -> val end)
  |> Enum.reduce(&lcm/2)
end
```
