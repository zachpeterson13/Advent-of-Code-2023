defmodule Day06 do
  @type race() :: {integer(), integer()}

  @input """
  Time:        61     67     75     71
  Distance:   430   1036   1307   1150
  """

  @spec part1(String.t()) :: integer()
  def part1(input \\ @input) do
    input
    |> parse_input()
    |> Enum.map(&count_ways_to_win/1)
    |> Enum.reduce(&Kernel.*/2)
  end

  @spec parse_input(String.t()) :: list(race())
  def parse_input(input) do
    [times | [dist | []]] =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&(String.split(&1, ":", trim: true) |> Enum.at(1) |> String.split()))
      |> Enum.map(fn list -> Enum.map(list, &String.to_integer/1) end)

    Enum.zip(times, dist)
  end

  @spec count_ways_to_win(race()) :: integer()
  def count_ways_to_win({time, dist}) do
    0..time
    |> Enum.reduce(fn held, acc ->
      if (time - held) * held > dist do
        acc + 1
      else
        acc
      end
    end)
  end

  @spec part2(String.t()) :: integer()
  def part2(input \\ @input) do
    input
    |> parse_input2()
    |> count_ways_to_win()
  end

  @spec parse_input2(String.t()) :: race()
  def parse_input2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1, ":", trim: true) |> Enum.at(1) |> String.split()))
    |> Enum.map(fn list -> Enum.join(list) |> String.to_integer() end)
    |> List.to_tuple()
  end
end
