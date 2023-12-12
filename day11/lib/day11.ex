defmodule Day11 do
  @input File.read!("input.txt")

  def enumerate_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.graphemes(&1) |> Enum.with_index()))
    |> Enum.with_index()
  end

  def make_grid(enumerated) do
    {list, rows} = List.last(enumerated)
    {_, cols} = List.last(list)

    grid =
      Enum.reduce(enumerated, %{}, fn {list, row}, acc1 ->
        Map.merge(
          acc1,
          Enum.reduce(list, %{}, fn {str, col}, acc2 ->
            Map.put(acc2, {col, row}, str)
          end)
        )
      end)

    {grid, rows, cols}
  end

  def find_empty_rows(grid, num_rows, num_cols) do
    0..num_rows
    |> Enum.map(fn row -> 0..num_cols |> Enum.all?(fn col -> grid[{col, row}] == "." end) end)
    |> Enum.with_index()
    |> Enum.filter(fn {empty, _} -> empty end)
    |> Enum.map(fn {_, row} -> row end)
  end

  def find_empty_cols(grid, num_rows, num_cols) do
    0..num_cols
    |> Enum.map(fn col -> 0..num_rows |> Enum.all?(fn row -> grid[{col, row}] == "." end) end)
    |> Enum.with_index()
    |> Enum.filter(fn {empty, _} -> empty end)
    |> Enum.map(fn {_, row} -> row end)
  end

  def find_empty(grid, num_rows, num_cols) do
    {find_empty_rows(grid, num_rows, num_cols), find_empty_cols(grid, num_rows, num_cols)}
  end

  def expand_row(grid, empty_row) do
    {num_cols, num_rows} =
      Map.keys(grid) |> Enum.max(fn {x1, y1}, {x2, y2} -> x1 >= x2 and y1 >= y2 end)

    0..(num_rows + 1)
    |> Enum.map(fn row ->
      0..num_cols
      |> Enum.reduce(%{}, fn col, acc ->
        cond do
          row <= empty_row ->
            Map.put(acc, {col, row}, grid[{col, row}])

          # row == empty_row ->
          #   Map.put(acc, {col, row}, ".")

          row > empty_row ->
            Map.put(acc, {col, row}, grid[{col, row - 1}])
        end
      end)
    end)
    |> Enum.reduce(fn map, acc -> Map.merge(acc, map) end)
  end

  def expand_col(grid, empty_col) do
    {num_cols, num_rows} =
      Map.keys(grid) |> Enum.max(fn {x1, y1}, {x2, y2} -> x1 >= x2 and y1 >= y2 end)

    0..(num_cols + 1)
    |> Enum.map(fn col ->
      0..num_rows
      |> Enum.reduce(%{}, fn row, acc ->
        cond do
          col <= empty_col ->
            Map.put(acc, {col, row}, grid[{col, row}])

          # col == empty_col ->
          #   Map.put(acc, {col, row}, ".")

          col > empty_col ->
            Map.put(acc, {col, row}, grid[{col - 1, row}])
        end
      end)
    end)
    |> Enum.reduce(fn map, acc -> Map.merge(acc, map) end)
  end

  def expand(grid, empty_rows, empty_cols) do
    grid =
      empty_rows
      |> Enum.with_index()
      |> Enum.map(fn {row, offset} -> row + offset end)
      |> Enum.reduce(grid, fn row, acc -> expand_row(acc, row) end)

    empty_cols
    |> Enum.with_index()
    |> Enum.map(fn {col, offset} -> col + offset end)
    |> Enum.reduce(grid, fn col, acc -> expand_col(acc, col) end)
  end

  def distance({{x1, y1}, {x2, y2}}), do: abs(x1 - x2) + abs(y1 - y2)

  def part1(input \\ @input) do
    {grid, num_rows, num_cols} = input |> enumerate_input() |> make_grid()

    {empty_rows, empty_cols} = find_empty(grid, num_rows, num_cols)

    grid = expand(grid, empty_rows, empty_cols)

    galaxies =
      grid
      |> Map.to_list()
      |> Enum.filter(fn {_, val} -> val == "#" end)
      |> Enum.map(fn {pos, _} -> pos end)

    combinations = Comb.combinations(galaxies, 2) |> Enum.map(fn list -> List.to_tuple(list) end)

    Enum.map(combinations, &distance/1) |> Enum.sum()
  end

  def expand_row2(points, empty_row, expand_by) do
    points
    |> Enum.map(fn {col, row} ->
      cond do
        row <= empty_row ->
          {col, row}

        true ->
          {col, row + expand_by}
      end
    end)
  end

  def expand_col2(points, empty_col, expand_by) do
    points
    |> Enum.map(fn {col, row} ->
      cond do
        col <= empty_col ->
          {col, row}

        true ->
          {col + expand_by, row}
      end
    end)
  end

  def expand2(points, empty_rows, empty_cols, expand_by) do
    points =
      empty_rows
      |> Enum.with_index()
      |> Enum.map(fn {row, offset} -> row + offset * expand_by end)
      |> Enum.reduce(points, fn row, acc ->
        expand_row2(acc, row, expand_by)
      end)

    points =
      empty_cols
      |> Enum.with_index()
      |> Enum.map(fn {col, offset} -> col + offset * expand_by end)
      |> Enum.reduce(points, fn col, acc ->
        expand_col2(acc, col, expand_by)
      end)

    points
  end

  def part2(input \\ @input, expand_by \\ 1_000_000) do
    {grid, num_rows, num_cols} = input |> enumerate_input() |> make_grid()

    {empty_rows, empty_cols} = find_empty(grid, num_rows, num_cols)

    points =
      grid
      |> Map.to_list()
      |> Enum.filter(fn {_, val} -> val == "#" end)
      |> Enum.map(fn {pos, _} -> pos end)

    points
    |> expand2(empty_rows, empty_cols, expand_by - 1)
    |> Comb.combinations(2)
    |> Enum.map(fn list -> List.to_tuple(list) end)
    |> Enum.map(&distance/1)
    |> Enum.sum()
  end
end
