defmodule Day14 do
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
            if str != "." do
              Map.put(acc2, {col, row}, str)
            else
              acc2
            end
          end)
        )
      end)

    {length(rows), length(cols), grid}
  end

  def slide_up(grid, nrows, ncols) do
    0..(ncols - 1)
    |> Enum.map(fn col ->
      {map, _} =
        0..(nrows - 1)
        |> Enum.reduce({%{}, 0}, fn row, {map, last_valid} ->
          case val = grid[{col, row}] do
            # if the val is a O we move it to the last_valid point and update last_valid
            "O" ->
              map = Map.put(map, {col, last_valid}, val)
              {map, last_valid + 1}

            # if the val is a # we update the last_valid
            "#" ->
              map = Map.put(map, {col, row}, val)
              {map, row + 1}

            # otherwise do nothing
            nil ->
              {map, last_valid}
          end
        end)

      map
    end)
    |> Enum.reduce(fn elem, acc -> Map.merge(elem, acc) end)
  end

  def calc_load(grid, nrows, ncols) do
    0..(nrows - 1)
    |> Enum.reduce(0, fn row, acc ->
      rocks =
        0..(ncols - 1)
        |> Enum.reduce(0, fn col, acc ->
          # if the val is a "O" add 1 to the accumulator
          case grid[{col, row}] do
            "O" -> acc + 1
            _ -> acc
          end
        end)

      # load is based on how many rows away from the south a rock is
      (nrows - row) * rocks + acc
    end)
  end

  @input File.read!("input.txt")

  def part1(input \\ @input) do
    {nrows, ncols, grid} = make_grid(input)

    slide_up(grid, nrows, ncols)
    |> calc_load(nrows, ncols)
  end

  def slide_down(grid, nrows, ncols) do
    0..(ncols - 1)
    |> Enum.map(fn col ->
      {map, _} =
        (nrows - 1)..0
        |> Enum.reduce({%{}, nrows - 1}, fn row, {map, last_valid} ->
          case val = grid[{col, row}] do
            "O" ->
              map = Map.put(map, {col, last_valid}, val)
              {map, last_valid - 1}

            "#" ->
              map = Map.put(map, {col, row}, val)
              {map, row - 1}

            nil ->
              {map, last_valid}
          end
        end)

      map
    end)
    |> Enum.reduce(fn elem, acc -> Map.merge(elem, acc) end)
  end

  def slide_left(grid, nrows, ncols) do
    0..(nrows - 1)
    |> Enum.map(fn row ->
      {map, _} =
        0..(ncols - 1)
        |> Enum.reduce({%{}, 0}, fn col, {map, last_valid} ->
          case val = grid[{col, row}] do
            "O" ->
              map = Map.put(map, {last_valid, row}, val)
              {map, last_valid + 1}

            "#" ->
              map = Map.put(map, {col, row}, val)
              {map, col + 1}

            nil ->
              {map, last_valid}
          end
        end)

      map
    end)
    |> Enum.reduce(fn elem, acc -> Map.merge(elem, acc) end)
  end

  def slide_right(grid, nrows, ncols) do
    0..(nrows - 1)
    |> Enum.map(fn row ->
      {map, _} =
        (ncols - 1)..0
        |> Enum.reduce({%{}, ncols - 1}, fn col, {map, last_valid} ->
          case val = grid[{col, row}] do
            "O" ->
              map = Map.put(map, {last_valid, row}, val)
              {map, last_valid - 1}

            "#" ->
              map = Map.put(map, {col, row}, val)
              {map, col - 1}

            nil ->
              {map, last_valid}
          end
        end)

      map
    end)
    |> Enum.reduce(fn elem, acc -> Map.merge(elem, acc) end)
  end

  def cycle(grid, nrows, ncols) do
    grid
    |> slide_up(nrows, ncols)
    |> slide_left(nrows, ncols)
    |> slide_down(nrows, ncols)
    |> slide_right(nrows, ncols)
  end

  def part2(input \\ @input) do
    {nrows, ncols, grid} = make_grid(input)

    # find the cycle_len and how many spins it took to get there
    {grid, spins, cycle_len} =
      0..(1_000_000_000 - 1)
      |> Enum.reduce_while({grid, %{}}, fn i, {grid, after_cycle_map} ->
        after_cycle = cycle(grid, nrows, ncols)

        if Map.has_key?(after_cycle_map, after_cycle) do
          {:halt, {after_cycle, i, i - after_cycle_map[after_cycle]}}
        else
          {:cont, {after_cycle, Map.put(after_cycle_map, after_cycle, i)}}
        end
      end)

    spins_remaining = rem(1_000_000_000 - spins - 1, cycle_len)

    0..(spins_remaining - 1)
    |> Enum.reduce(grid, fn _, acc -> cycle(acc, nrows, ncols) end)
    |> calc_load(nrows, ncols)
  end
end
