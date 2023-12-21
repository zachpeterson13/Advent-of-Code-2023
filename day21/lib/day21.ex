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

  def bfs(grid, start) do
    frontier = :queue.from_list([{0, start}])
    visited = Map.new()

    loop2(grid, frontier, visited)
  end

  def loop2(_, {[], []}, visited), do: visited

  def loop2(grid, frontier, visited) do
    {{:value, {dist, pos}}, frontier} = :queue.out(frontier)

    if Map.has_key?(visited, pos) do
      loop2(grid, frontier, visited)
    else
      visited = Map.put(visited, pos, dist)

      {frontier, visited} =
        get_neighbors(pos, grid)
        |> Enum.reduce({frontier, visited}, fn pos, {f, v} = continue ->
          if not Map.has_key?(visited, pos) and grid[pos] != "#" do
            f = :queue.in({dist + 1, pos}, f)

            {f, v}
          else
            continue
          end
        end)

      loop2(grid, frontier, visited)
    end
  end

  def part2(input \\ @input, steps \\ 26_501_365) do
    {rows, _, grid} = make_grid(input)

    {start, "S"} = Map.to_list(grid) |> Enum.filter(fn {_, val} -> val == "S" end) |> List.first()

    visited = bfs(grid, start)

    values = Map.values(visited)

    even_corners = values |> Enum.filter(fn v -> rem(v, 2) == 0 and v > 65 end) |> Enum.count()
    odd_corners = values |> Enum.filter(fn v -> rem(v, 2) == 1 and v > 65 end) |> Enum.count()

    even_full = values |> Enum.filter(fn v -> rem(v, 2) == 0 end) |> Enum.count()
    odd_full = values |> Enum.filter(fn v -> rem(v, 2) == 1 end) |> Enum.count()

    n = div(steps - div(rows, 2), rows)

    # ??? I have no idea only seems to work for actual input and not the test cases
    # https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
    (n + 1) * (n + 1) * odd_full + n * n * even_full - (n + 1) * odd_corners + n * even_corners
  end
end
