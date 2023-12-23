defmodule Day23 do
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
            if str == "#" do
              acc2
            else
              Map.put(acc2, {col, row}, str)
            end
          end)
        )
      end)

    {length(rows), 1 + (List.last(cols) |> List.last() |> elem(1)), grid}
  end

  def go_up({col, row}), do: {col, row - 1}
  def go_right({col, row}), do: {col + 1, row}
  def go_down({col, row}), do: {col, row + 1}
  def go_left({col, row}), do: {col - 1, row}

  def get_neighbors(grid, pos) do
    case Map.get(grid, pos) do
      ">" ->
        [go_right(pos)]

      "<" ->
        [go_left(pos)]

      "^" ->
        [go_up(pos)]

      "v" ->
        [go_down(pos)]

      _ ->
        [go_up(pos), go_right(pos), go_left(pos), go_down(pos)]
    end
    |> Enum.filter(fn pos -> Map.has_key?(grid, pos) end)
  end

  def bfs(grid, start, finish) do
    frontier = :queue.from_list([{start, 0, nil}])

    loop(grid, frontier, finish, [])
    |> Enum.max()
  end

  def loop(_, {[], []}, _, lengths), do: lengths

  def loop(grid, frontier, fin, lengths) do
    {{:value, {current, steps, prev}}, frontier} = :queue.out(frontier)

    if current == fin do
      loop(grid, frontier, fin, [steps | lengths])
    else
      frontier =
        get_neighbors(grid, current)
        |> Enum.reduce(frontier, fn next, f ->
          if next == prev do
            f
          else
            :queue.in({next, steps + 1, current}, f)
          end
        end)

      loop(grid, frontier, fin, lengths)
    end
  end

  def get_path(_, same, same, path), do: [same | path] |> Enum.reverse()

  def get_path(came_from, start, current, path) do
    new_path = [current | path]
    get_path(came_from, start, came_from[current], new_path)
  end

  def part1(input \\ @input) do
    {n, m, grid} = input |> make_grid()

    start = {1, 0}
    fin = {n - 2, m - 1}

    bfs(grid, start, fin)
  end

  def dfs(edges, current, fin, dist, seen \\ MapSet.new())

  def dfs(_, same, same, dist, _), do: dist

  def dfs(edges, current, fin, dist, seen) do
    if MapSet.member?(seen, current) do
      0
    else
      seen = MapSet.put(seen, current)

      edges[current]
      |> Enum.reduce(0, fn {r, c, length}, acc ->
        max(dfs(edges, {r, c}, fin, dist + length, seen), acc)
      end)
    end
  end

  def nodes_to_edges(grid) do
    Map.to_list(grid)
    |> Enum.reduce(%{}, fn {k, _}, acc ->
      value =
        get_neighbors(grid, k)
        |> Enum.reduce([], fn {nr, nc}, acc2 ->
          [{nr, nc, 1} | acc2]
        end)

      Map.put(acc, k, value)
    end)
  end

  def collapse(edges) do
    if Map.filter(edges, fn {_, v} -> length(v) == 2 end) |> map_size() == 0 do
      edges
    else
      {{c, r}, e} =
        Map.to_list(edges) |> Enum.filter(fn {_, v} -> length(v) == 2 end) |> List.first()

      [a, b] = e

      {ac, ar, al} = a
      {bc, br, bl} = b

      a = List.delete(edges[{ac, ar}], {c, r, al})
      b = List.delete(edges[{bc, br}], {c, r, bl})

      a = [{bc, br, al + bl} | a]
      b = [{ac, ar, al + bl} | b]

      edges =
        Map.put(edges, {ac, ar}, a)
        |> Map.put({bc, br}, b)
        |> Map.delete({c, r})

      collapse(edges)
    end
  end

  def part2(input \\ @input) do
    {n, m, grid} = input |> make_grid()

    grid =
      Map.to_list(grid)
      |> Enum.filter(fn {_, v} -> v in ["<", ">", "v", "^"] end)
      |> Enum.map(fn {k, _} -> {k, "."} end)
      |> Enum.reduce(grid, fn {k, v}, map -> Map.put(map, k, v) end)

    start = {1, 0}
    fin = {n - 2, m - 1}

    edges =
      nodes_to_edges(grid)
      |> collapse()

    dfs(edges, start, fin, 0)
  end
end
