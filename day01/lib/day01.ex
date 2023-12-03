defmodule Day01 do
  @input File.read!("./input.txt")

  @spec part1(String.t()) :: integer()
  def part1(lines \\ @input) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> parse_line1(line) end)
    |> Enum.sum()
  end

  @spec parse_line1(String.t()) :: integer()
  defp parse_line1(line) do
    numbers =
      line
      |> String.to_charlist()
      |> Enum.filter(fn char -> char >= ?0 and char <= ?9 end)

    [List.first(numbers), List.last(numbers)]
    |> List.to_integer()
  end

  @spec part2(String.t()) :: integer()
  def part2(lines \\ @input) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> parse_line2(line) end)
    |> Enum.sum()
  end

  @spec parse_line2(String.t()) :: integer()
  defp parse_line2(line) do
    numbers =
      line
      |> String.to_charlist()
      |> do_parse_line2([])

    [List.first(numbers), List.last(numbers)]
    |> List.to_integer()
  end

  defp do_parse_line2([?o | [?n | [?e | _]] = rest], acc) do
    do_parse_line2(rest, [?1 | acc])
  end

  defp do_parse_line2([?t | [?w | [?o | _]] = rest], acc) do
    do_parse_line2(rest, [?2 | acc])
  end

  defp do_parse_line2([?t | [?h | [?r | [?e | [?e | _]]]] = rest], acc) do
    do_parse_line2(rest, [?3 | acc])
  end

  defp do_parse_line2([?f | [?o | [?u | [?r | _]]] = rest], acc) do
    do_parse_line2(rest, [?4 | acc])
  end

  defp do_parse_line2([?f | [?i | [?v | [?e | _]]] = rest], acc) do
    do_parse_line2(rest, [?5 | acc])
  end

  defp do_parse_line2([?s | [?i | [?x | _]] = rest], acc) do
    do_parse_line2(rest, [?6 | acc])
  end

  defp do_parse_line2([?s | [?e | [?v | [?e | [?n | _]]]] = rest], acc) do
    do_parse_line2(rest, [?7 | acc])
  end

  defp do_parse_line2([?e | [?i | [?g | [?h | [?t | _]]]] = rest], acc) do
    do_parse_line2(rest, [?8 | acc])
  end

  defp do_parse_line2([?n | [?i | [?n | [?e | _]]] = rest], acc) do
    do_parse_line2(rest, [?9 | acc])
  end

  defp do_parse_line2([head | rest], acc) do
    if head >= ?0 and head <= ?9 do
      do_parse_line2(rest, [head | acc])
    else
      do_parse_line2(rest, acc)
    end
  end

  defp do_parse_line2([], acc) do
    acc
    |> Enum.reverse()
  end
end
