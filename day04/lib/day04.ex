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

  @spec part2(String.t()) :: integer()
  def part2(_input) do
    0
  end
end
