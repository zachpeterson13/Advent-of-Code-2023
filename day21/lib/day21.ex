defmodule Day21 do
  @input File.read!("input.txt")

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

    {length(rows), 1 + (List.last(cols) |> List.last() |> elem(1)), grid}
  end

  def go_up({col, row}), do: {col, row - 1}
  def go_right({col, row}), do: {col + 1, row}
  def go_down({col, row}), do: {col, row + 1}
  def go_left({col, row}), do: {col - 1, row}

  def get_neighbors(pos, grid) do
    [go_up(pos), go_right(pos), go_left(pos), go_down(pos)]
    |> Enum.filter(fn pos -> Map.has_key?(grid, pos) end)
  end

  def count_plots(grid, start, steps) do
    frontier = [start] |> MapSet.new()

    final =
      Enum.reduce(0..(steps - 1), frontier, fn _, acc ->
        loop(grid, acc |> MapSet.to_list(), MapSet.new())
      end)

    MapSet.size(final)
  end

  def loop(_, [], next), do: next

  def loop(grid, [current | rest], next) do
    next =
      get_neighbors(current, grid)
      |> Enum.reduce(next, fn pos, acc ->
        if grid[pos] != "#" do
          MapSet.put(acc, pos)
        else
          acc
        end
      end)

    loop(grid, rest, next)
  end

  def part1(input \\ @input, steps \\ 64) do
    {_, _, grid} = make_grid(input)

    {start, "S"} = Map.to_list(grid) |> Enum.filter(fn {_, val} -> val == "S" end) |> List.first()

    count_plots(grid, start, steps)
  end

  def part2(input \\ @input) do
    input
  end
end
