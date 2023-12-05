defmodule Day04 do
  @input File.read!("input.txt")

  @spec part1(String.t()) :: integer()
  def part1(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_nums/1)
    |> Enum.map(&check_for_winners/1)
    |> Enum.sum()
  end

  @spec parse_nums(String.t()) :: {[integer()], [integer()]}
  def parse_nums(line) do
    [_ | [winners | [numbers | []]]] =
      line |> String.split([":", " | "], trim: true) |> Enum.map(&String.split/1)

    {winners |> Enum.map(&String.to_integer/1), numbers |> Enum.map(&String.to_integer/1)}
  end

  @spec check_for_winners({[integer()], [integer()]}, non_neg_integer()) :: integer()
  def check_for_winners(nums, count \\ 0)

  def check_for_winners({winners, [head | tail]}, count) do
    if head in winners do
      check_for_winners({winners, tail}, count + 1)
    else
      check_for_winners({winners, tail}, count)
    end
  end

  def check_for_winners(_, count), do: :math.pow(2, count - 1) |> floor()

  @type card_map() :: %{pos_integer() => {[integer()], [integer()]}}

  @spec part2(String.t()) :: integer()
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

  @spec parse_line(String.t()) :: card_map()
  def(parse_line(line)) do
    [game | [winners | [numbers | []]]] =
      line |> String.split([":", " | "], trim: true) |> Enum.map(&String.split/1)

    game = List.last(game) |> String.to_integer()
    winners = Enum.map(winners, &String.to_integer/1)
    numbers = Enum.map(numbers, &String.to_integer/1)

    %{game => {winners, numbers}}
  end

  @spec process_queue(card_map(), :queue.queue(), non_neg_integer()) :: integer()
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

  @spec count_winners({[integer()], [integer()]}, non_neg_integer()) :: integer()
  def count_winners(nums, count \\ 0)

  def count_winners({winners, [head | tail]}, count) do
    if head in winners do
      count_winners({winners, tail}, count + 1)
    else
      count_winners({winners, tail}, count)
    end
  end

  def count_winners(_, count), do: count
end
