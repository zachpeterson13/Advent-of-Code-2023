defmodule Day02 do
  @input File.read!("./input.txt")

  @spec part1(String.t()) :: integer()
  def part1(lines \\ @input) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line1/1)
    |> Enum.filter(&elem(&1, 0))
    |> Enum.reduce(0, &(&2 + elem(&1, 1)))
  end

  @spec parse_line1(String.t()) :: {boolean(), integer()}
  def parse_line1(line) do
    "Game " <> line = line

    [num | rest] = String.split(line)
    {num, _} = Integer.parse(num)

    line = Enum.join(rest, " ")

    valid =
      String.split(line, ";")
      |> Enum.map(&validate_game/1)
      |> Enum.all?()

    {valid, num}
  end

  @spec validate_game(String.t()) :: boolean()
  defp validate_game(game) do
    game
    |> String.split(", ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {num, " " <> color} ->
      case {num, color} do
        {num, "blue"} when num <= 14 -> true
        {num, "green"} when num <= 13 -> true
        {num, "red"} when num <= 12 -> true
        _ -> false
      end
    end)
    |> Enum.all?()
  end

  defstruct red: 0, green: 0, blue: 0

  @spec part2(String.t()) :: integer()
  def part2(lines \\ @input) do
    lines |> String.trim() |> String.split("\n") |> Enum.map(&parse_line2/1) |> Enum.sum()
  end

  @spec parse_line2(String.t()) :: integer()
  defp parse_line2(line) do
    [_ | line] = String.split(line, ": ")

    List.first(line) |> String.split([",", ";"], trim: true) |> get_power()
  end

  @spec get_power(list(String.t()), %Day02{}) :: integer()
  defp get_power(list, acc \\ %Day02{})

  defp get_power([head | tail], acc) do
    case head |> String.trim() |> Integer.parse() do
      {num, " green"} when num > acc.green ->
        get_power(tail, %{acc | green: num})

      {num, " red"} when num > acc.red ->
        get_power(tail, %{acc | red: num})

      {num, " blue"} when num > acc.blue ->
        get_power(tail, %{acc | blue: num})

      _ ->
        get_power(tail, acc)
    end
  end

  defp get_power([], acc) do
    acc.blue * acc.red * acc.green
  end
end
