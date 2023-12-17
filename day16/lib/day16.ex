defmodule Day16 do
  def make_grid(input) do
    rows =
      input
      |> String.split("\n", trim: true)

    cols =
      rows
      |> Enum.map(&(String.graphemes(&1) |> Enum.with_index()))

    grid =
      cols
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {list, row}, acc1 ->
        Map.merge(
          acc1,
          Enum.reduce(list, %{}, fn {str, col}, acc2 ->
            Map.put(acc2, {col, row}, str)
          end)
        )
      end)

    {length(rows), grid}
  end

  def go_up({col, row}), do: {col, row - 1}
  def go_right({col, row}), do: {col + 1, row}
  def go_down({col, row}), do: {col, row + 1}
  def go_left({col, row}), do: {col - 1, row}

  def add_pos({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  def walk(_, [], [], _, set), do: set |> MapSet.size()

  def walk(grid, [], neighbors, seen, set) do
    walk(grid, neighbors, [], seen, set)
  end

  def walk(grid, [{pos, direction} | rest], neighbors, seen, set) do
    if MapSet.member?(seen, {pos, direction}) do
      walk(grid, rest, neighbors, seen, set)
    else
      seen = MapSet.put(seen, {pos, direction})

      case grid[pos] do
        "." ->
          walk(
            grid,
            rest,
            [{add_pos(pos, direction), direction} | neighbors],
            seen,
            MapSet.put(set, pos)
          )

        "\\" ->
          case direction do
            # up
            {0, -1} ->
              walk(grid, rest, [{go_left(pos), {-1, 0}} | neighbors], seen, MapSet.put(set, pos))

            # down
            {0, 1} ->
              walk(grid, rest, [{go_right(pos), {1, 0}} | neighbors], seen, MapSet.put(set, pos))

            # right
            {1, 0} ->
              walk(grid, rest, [{go_down(pos), {0, 1}} | neighbors], seen, MapSet.put(set, pos))

            # left
            {-1, 0} ->
              walk(grid, rest, [{go_up(pos), {0, -1}} | neighbors], seen, MapSet.put(set, pos))
          end

        "/" ->
          case direction do
            {0, -1} ->
              walk(grid, rest, [{go_right(pos), {1, 0}} | neighbors], seen, MapSet.put(set, pos))

            {0, 1} ->
              walk(grid, rest, [{go_left(pos), {-1, 0}} | neighbors], seen, MapSet.put(set, pos))

            {1, 0} ->
              walk(grid, rest, [{go_up(pos), {0, -1}} | neighbors], seen, MapSet.put(set, pos))

            {-1, 0} ->
              walk(grid, rest, [{go_down(pos), {0, 1}} | neighbors], seen, MapSet.put(set, pos))
          end

        "|" ->
          case direction do
            {0, -1} ->
              walk(grid, rest, [{go_up(pos), direction} | neighbors], seen, MapSet.put(set, pos))

            {0, 1} ->
              walk(
                grid,
                rest,
                [{go_down(pos), direction} | neighbors],
                seen,
                MapSet.put(set, pos)
              )

            {1, 0} ->
              walk(
                grid,
                rest,
                [{go_up(pos), {0, -1}}, {go_down(pos), {0, 1}} | neighbors],
                seen,
                MapSet.put(set, pos)
              )

            {-1, 0} ->
              walk(
                grid,
                rest,
                [{go_up(pos), {0, -1}}, {go_down(pos), {0, 1}} | neighbors],
                seen,
                MapSet.put(set, pos)
              )
          end

        "-" ->
          case direction do
            {0, -1} ->
              walk(
                grid,
                rest,
                [{go_left(pos), {-1, 0}}, {go_right(pos), {1, 0}} | neighbors],
                seen,
                MapSet.put(set, pos)
              )

            {0, 1} ->
              walk(
                grid,
                rest,
                [{go_left(pos), {-1, 0}}, {go_right(pos), {1, 0}} | neighbors],
                seen,
                MapSet.put(set, pos)
              )

            {1, 0} ->
              walk(
                grid,
                rest,
                [{go_right(pos), direction} | neighbors],
                seen,
                MapSet.put(set, pos)
              )

            {-1, 0} ->
              walk(
                grid,
                rest,
                [{go_left(pos), direction} | neighbors],
                seen,
                MapSet.put(set, pos)
              )
          end

        nil ->
          walk(grid, rest, neighbors, seen, set)
      end
    end
  end

  @input File.read!("input.txt")

  def part1(input \\ @input) do
    {_, grid} = input |> make_grid()

    walk(grid, [{{0, 0}, {1, 0}}], [], MapSet.new([{0, 0}, {1, 0}]), MapSet.new())
  end
end
