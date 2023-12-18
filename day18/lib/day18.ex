defmodule Day18 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      {dir, amt, _} = String.split(str) |> List.to_tuple()

      dir =
        case dir do
          "R" -> :right
          "L" -> :left
          "U" -> :up
          "D" -> :down
        end

      amt = String.to_integer(amt)

      {dir, amt}
    end)
  end

  def go_up({col, row}), do: {col, row - 1}
  def go_right({col, row}), do: {col + 1, row}
  def go_down({col, row}), do: {col, row + 1}
  def go_left({col, row}), do: {col - 1, row}
  def add_pos({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  def create_trench([], acc, count), do: {acc |> Enum.reverse(), count}

  def create_trench([{dir, amt} | tail], [last | _] = acc, count) do
    case dir do
      :up ->
        create_trench(tail, [add_pos(last, {0, amt * -1}) | acc], count + amt)

      :down ->
        create_trench(tail, [add_pos(last, {0, amt}) | acc], count + amt)

      :right ->
        create_trench(tail, [add_pos(last, {amt, 0}) | acc], count + amt)

      :left ->
        create_trench(tail, [add_pos(last, {amt * -1, 0}) | acc], count + amt)
    end
  end

  def shoelace(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [{x1, y1}, {x2, y2}] ->
      (y1 + y2) * (x1 - x2)
    end)
    |> Enum.sum()
  end

  @input File.read!("input.txt")

  def part1(input \\ @input) do
    {trench, trench_len} =
      input
      |> parse_input()
      |> create_trench([{0, 0}], 0)

    area = shoelace(trench)

    # Pick's theorem to get the number of interior points
    # Total points = # of interior points + # of border points
    (area / 2 - (trench_len / 2 - 1) + trench_len)
    |> floor()
  end

  def parse_input2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      {_, _, rgb} = String.split(str) |> List.to_tuple()

      amt = String.slice(rgb, 2..6) |> String.to_integer(16)

      dir =
        case String.slice(rgb, 7..7) do
          "0" -> :right
          "1" -> :down
          "2" -> :left
          "3" -> :up
        end

      {dir, amt}
    end)
  end

  def part2(input \\ @input) do
    {trench, trench_len} =
      input
      |> parse_input2()
      |> create_trench([{0, 0}], 0)

    area = shoelace(trench) / 2

    # Pick's theorem to get the number of interior points
    # Total points = # of interior points + # of border points
    (area - (trench_len / 2 - 1) + trench_len)
    |> floor()
  end
end
