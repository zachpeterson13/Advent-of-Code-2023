defmodule Day17 do
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
            Map.put(acc2, {col, row}, String.to_integer(str))
          end)
        )
      end)

    {length(rows), 1 + (List.last(cols) |> List.last() |> elem(1)), grid}
  end

  def go_up({col, row}), do: {col, row - 1}
  def go_right({col, row}), do: {col + 1, row}
  def go_down({col, row}), do: {col, row + 1}
  def go_left({col, row}), do: {col - 1, row}

  def get_neighbors({pos, dir}) do
    case dir do
      :north ->
        right1 = go_right(pos)
        right2 = go_right(right1)
        right3 = go_right(right2)

        left1 = go_left(pos)
        left2 = go_left(left1)
        left3 = go_left(left2)

        [
          {right1, :east},
          {right2, :east},
          {right3, :east},
          {left1, :west},
          {left2, :west},
          {left3, :west}
        ]

      :east ->
        right1 = go_down(pos)
        right2 = go_down(right1)
        right3 = go_down(right2)

        left1 = go_up(pos)
        left2 = go_up(left1)
        left3 = go_up(left2)

        [
          {right1, :south},
          {right2, :south},
          {right3, :south},
          {left1, :north},
          {left2, :north},
          {left3, :north}
        ]

      :south ->
        right1 = go_left(pos)
        right2 = go_left(right1)
        right3 = go_left(right2)

        left1 = go_right(pos)
        left2 = go_right(left1)
        left3 = go_right(left2)

        [
          {right1, :west},
          {right2, :west},
          {right3, :west},
          {left1, :east},
          {left2, :east},
          {left3, :east}
        ]

      :west ->
        right1 = go_up(pos)
        right2 = go_up(right1)
        right3 = go_up(right2)

        left1 = go_down(pos)
        left2 = go_down(left1)
        left3 = go_down(left2)

        [
          {right1, :north},
          {right2, :north},
          {right3, :north},
          {left1, :south},
          {left2, :south},
          {left3, :south}
        ]
    end
  end

  def get_path(_, same, {same, _}, acc), do: [same | acc] |> Enum.reverse()

  def get_path(came_from, start, {c, _} = current, acc) do
    get_path(came_from, start, came_from[current], [c | acc])
  end

  def get_cost({x1, y1}, {x2, y2}, costs) do
    case {x2 - x1, y2 - y1} do
      {0, dy} when dy < 0 ->
        -1..dy
        |> Enum.reduce(0, fn offset, acc -> acc + costs[{x1, y1 + offset}] end)

      {0, dy} when dy > 0 ->
        1..dy
        |> Enum.reduce(0, fn offset, acc -> acc + costs[{x1, y1 + offset}] end)

      {dx, 0} when dx < 0 ->
        -1..dx
        |> Enum.reduce(0, fn offset, acc -> acc + costs[{x1 + offset, y1}] end)

      {dx, 0} when dx > 0 ->
        1..dx
        |> Enum.reduce(0, fn offset, acc -> acc + costs[{x1 + offset, y1}] end)
    end
  end

  # Part 1
  # Dijkstras: ~550ms
  # A*: ~480ms
  # Part 2
  # Dijkstras: ~1750ms
  # A*: ~1650ms
  # not sure if A* is working
  def search(costs, start, finish, neighbors, heuristic \\ fn _ -> 0 end) do
    frontier =
      PriorityQueue.new()
      |> PriorityQueue.put(0, {start, :east})
      |> PriorityQueue.put(0, {start, :south})

    came_from = %{{start, :south} => nil, {start, :east} => nil}
    cost_so_far = %{{start, :south} => 0, {start, :east} => 0}

    {_, cost_so_far} = loop(frontier, came_from, cost_so_far, costs, finish, neighbors, heuristic)

    Map.filter(cost_so_far, fn {{pos, _}, _} -> pos == finish end)
    |> Map.to_list()
    |> Enum.map(fn {finish, _} -> cost_so_far[finish] end)
    |> Enum.min()
  end

  def loop(frontier, came_from, cost_so_far, costs, finish, neighbors, heuristic) do
    {{_, {c, _} = current}, frontier} = PriorityQueue.pop(frontier, {{nil, {nil, nil}}, nil})

    if c == finish or c == nil do
      {came_from, cost_so_far}
    else
      {frontier, came_from, cost_so_far} =
        neighbors.(current)
        |> Enum.filter(fn {pos, _} -> Map.has_key?(costs, pos) end)
        |> Enum.reduce({frontier, came_from, cost_so_far}, fn {n, _} = next,
                                                              {f, cf, csf} = continue ->
          new_cost = csf[current] + get_cost(c, n, costs)

          if not Map.has_key?(csf, next) or new_cost < csf[next] do
            csf = Map.put(csf, next, new_cost)

            priority = new_cost + heuristic.(n)
            f = PriorityQueue.put(f, priority, next)

            cf = Map.put(cf, next, current)

            {f, cf, csf}
          else
            continue
          end
        end)

      loop(frontier, came_from, cost_so_far, costs, finish, neighbors, heuristic)
    end
  end

  @input File.read!("input.txt")

  def part1(input \\ @input) do
    {rows, cols, costs} = input |> make_grid()

    start = {0, 0}
    finish = {cols - 1, rows - 1}

    search(costs, start, finish, &get_neighbors/1, manhattan_dist(finish))
  end

  def add_pos({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  def get_neighbors2({pos, dir}) do
    case dir do
      :north ->
        right1 = add_pos(pos, {4, 0})
        right2 = go_right(right1)
        right3 = go_right(right2)
        right4 = go_right(right3)
        right5 = go_right(right4)
        right6 = go_right(right5)
        right7 = go_right(right6)

        left1 = add_pos(pos, {-4, 0})
        left2 = go_left(left1)
        left3 = go_left(left2)
        left4 = go_left(left3)
        left5 = go_left(left4)
        left6 = go_left(left5)
        left7 = go_left(left6)

        [
          {right1, :east},
          {right2, :east},
          {right3, :east},
          {right4, :east},
          {right5, :east},
          {right6, :east},
          {right7, :east},
          {left1, :west},
          {left2, :west},
          {left3, :west},
          {left4, :west},
          {left5, :west},
          {left6, :west},
          {left7, :west}
        ]

      :east ->
        right1 = add_pos(pos, {0, 4})
        right2 = go_down(right1)
        right3 = go_down(right2)
        right4 = go_down(right3)
        right5 = go_down(right4)
        right6 = go_down(right5)
        right7 = go_down(right6)

        left1 = add_pos(pos, {0, -4})
        left2 = go_up(left1)
        left3 = go_up(left2)
        left4 = go_up(left3)
        left5 = go_up(left4)
        left6 = go_up(left5)
        left7 = go_up(left6)

        [
          {right1, :south},
          {right2, :south},
          {right3, :south},
          {right4, :south},
          {right5, :south},
          {right6, :south},
          {right7, :south},
          {left1, :north},
          {left2, :north},
          {left3, :north},
          {left4, :north},
          {left5, :north},
          {left6, :north},
          {left7, :north}
        ]

      :south ->
        right1 = add_pos(pos, {-4, 0})
        right2 = go_left(right1)
        right3 = go_left(right2)
        right4 = go_left(right3)
        right5 = go_left(right4)
        right6 = go_left(right5)
        right7 = go_left(right6)

        left1 = add_pos(pos, {4, 0})
        left2 = go_right(left1)
        left3 = go_right(left2)
        left4 = go_right(left3)
        left5 = go_right(left4)
        left6 = go_right(left5)
        left7 = go_right(left6)

        [
          {right1, :west},
          {right2, :west},
          {right3, :west},
          {right4, :west},
          {right5, :west},
          {right6, :west},
          {right7, :west},
          {left1, :east},
          {left2, :east},
          {left3, :east},
          {left4, :east},
          {left5, :east},
          {left6, :east},
          {left7, :east}
        ]

      :west ->
        right1 = add_pos(pos, {0, -4})
        right2 = go_up(right1)
        right3 = go_up(right2)
        right4 = go_up(right3)
        right5 = go_up(right4)
        right6 = go_up(right5)
        right7 = go_up(right6)

        left1 = add_pos(pos, {0, 4})
        left2 = go_down(left1)
        left3 = go_down(left2)
        left4 = go_down(left3)
        left5 = go_down(left4)
        left6 = go_down(left5)
        left7 = go_down(left6)

        [
          {right1, :north},
          {right2, :north},
          {right3, :north},
          {right4, :north},
          {right5, :north},
          {right6, :north},
          {right7, :north},
          {left1, :south},
          {left2, :south},
          {left3, :south},
          {left4, :south},
          {left5, :south},
          {left6, :south},
          {left7, :south}
        ]
    end
  end

  def manhattan_dist({x2, y2}) do
    fn {x1, y1} ->
      abs(x1 - x2) + abs(y1 - y2)
    end
  end

  def part2(input \\ @input) do
    {rows, cols, costs} = input |> make_grid()

    start = {0, 0}
    finish = {cols - 1, rows - 1}

    search(costs, start, finish, &get_neighbors2/1, manhattan_dist(finish))
  end
end
