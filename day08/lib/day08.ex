defmodule Day08 do
  @input File.read!("input.txt")

  def part1(input \\ @input) do
    {inst_q, map} = input |> parse_input()

    process(map, inst_q, "AAA")
  end

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

  def part2(input) do
    input
  end
end
