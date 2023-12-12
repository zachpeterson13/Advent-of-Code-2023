defmodule Day12 do
  use Memoize

  defmemo count_arrangements(springs, []) do
    if springs != [] and ?# in springs do
      0
    else
      1
    end
  end

  defmemo(count_arrangements([], _), do: 0)

  defmemo count_arrangements([?? | rest_s] = springs, [group_size | rest_g] = groups) do
    {slice, next} = Enum.slice(springs, 0..group_size) |> Enum.split(group_size)

    if ?. not in slice and next != '#' do
      count_arrangements(Enum.drop(springs, group_size + 1), rest_g) +
        count_arrangements(rest_s, groups)
    else
      count_arrangements(rest_s, groups)
    end
  end

  defmemo count_arrangements([?# | _] = springs, [group_size | rest_g]) do
    {slice, next} = Enum.slice(springs, 0..group_size) |> Enum.split(group_size)

    if ?. not in slice and next != '#' do
      count_arrangements(Enum.drop(springs, group_size + 1), rest_g)
    else
      0
    end
  end

  defmemo count_arrangements([?. | rest_s], groups) do
    count_arrangements(rest_s, groups)
  end

  @input File.read!("input.txt")

  def part1(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [springs, groups] ->
      groups = groups |> String.split(",") |> Enum.map(&String.to_integer/1)
      springs = (springs <> ".") |> to_charlist()

      count_arrangements(springs, groups)
    end)
    |> Enum.sum()
  end

  def part2(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [springs, groups] ->
      groups = groups |> String.split(",") |> Enum.map(&String.to_integer/1)
      groups = groups ++ groups ++ groups ++ groups ++ groups
      springs = springs <> "?" <> springs <> "?" <> springs <> "?" <> springs <> "?" <> springs
      springs = (springs <> ".") |> to_charlist()

      count_arrangements(springs, groups)
    end)
    |> Enum.sum()
  end
end
