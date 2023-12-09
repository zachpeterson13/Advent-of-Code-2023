defmodule Day09 do
  @input File.read!("input.txt")

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line) |> Enum.map(&String.to_integer/1)
    end)
  end

  def get_diff(hist, last \\ nil, acc \\ [])

  def get_diff([head | tail], nil, acc), do: get_diff(tail, head, acc)

  def get_diff([], _, acc), do: acc |> Enum.reverse()

  def get_diff([head | tail], last, acc) do
    diff = head - last

    get_diff(tail, head, [diff | acc])
  end

  def get_differences(hist, acc \\ []) do
    if Enum.all?(hist, &(&1 == 0)) do
      [hist | acc]
    else
      diff = get_diff(hist)

      get_differences(diff, [Enum.reverse(hist) | acc])
    end
  end

  def extrapolate(hists, acc \\ 0)

  def extrapolate([], acc), do: acc

  def extrapolate([[diff | _] | tail], acc) do
    extrapolate(tail, acc + diff)
  end

  def part1(input \\ @input) do
    input
    |> parse_input()
    |> Enum.map(fn hists -> hists |> get_differences() |> extrapolate() end)
    |> Enum.sum()
  end

  def get_differences2(hist, acc \\ []) do
    if Enum.all?(hist, &(&1 == 0)) do
      [hist | acc]
    else
      diff = get_diff(hist)

      get_differences2(diff, [hist | acc])
    end
  end

  def extrapolate2(hists, acc \\ 0)

  def extrapolate2([], acc), do: acc

  def extrapolate2([[diff | _] | tail], acc) do
    extrapolate2(tail, diff - acc)
  end

  def part2(input \\ @input) do
    input
    |> parse_input()
    |> Enum.map(fn hists -> hists |> get_differences2() |> extrapolate2() end)
    |> Enum.sum()
  end
end
