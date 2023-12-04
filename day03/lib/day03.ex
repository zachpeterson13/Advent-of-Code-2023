defmodule Day03 do
  @type grid() :: %{}

  @input File.read!("input.txt")
  @adj [{-1, 1}, {0, 1}, {1, 1}, {-1, 0}, {1, 0}, {-1, -1}, {0, -1}, {1, -1}]

  @spec is_numeric?(non_neg_integer()) :: boolean()
  def is_numeric?(char) do
    char in [?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9]
  end

  @spec make_grid(list(list()), grid(), list(), non_neg_integer(), non_neg_integer()) ::
          {grid(), list()}
  def make_grid([[value | rest] | tail], grid, symbols, x, y) do
    if value != ?. do
      pos = {x, y}

      if not is_numeric?(value) do
        make_grid([rest | tail], Map.put(grid, pos, value), [pos | symbols], x + 1, y)
      else
        make_grid([rest | tail], Map.put(grid, pos, value), symbols, x + 1, y)
      end
    else
      make_grid([rest | tail], grid, symbols, x + 1, y)
    end
  end

  def make_grid([[] | tail], grid, symbols, _, y), do: make_grid(tail, grid, symbols, 0, y + 1)

  def make_grid([], grid, symbols, _, _), do: {grid, Enum.reverse(symbols)}

  @spec part1(String.t()) :: integer()
  def part1(input \\ @input) do
    {grid, symbols} =
      input |> String.split("\n") |> Enum.map(&to_charlist/1) |> make_grid(%{}, [], 0, 0)

    p1(grid, symbols, MapSet.new())
  end

  @spec p1(grid(), list(), MapSet.t()) :: integer()
  def p1(grid, [s | rest], acc) do
    p1(grid, rest, get_adj_parts(grid, s, acc, @adj))
  end

  def p1(_, [], acc) do
    acc
    |> MapSet.filter(&(not is_nil(&1)))
    |> MapSet.to_list()
    |> Enum.reduce(0, fn {_, num}, acc -> acc + num end)
  end

  @spec get_adj_parts(grid(), tuple(), MapSet.t(), list(tuple())) :: MapSet.t()
  def get_adj_parts(grid, {pX, pY} = pos, acc, [{x, y} | rest]) do
    num = get_num(grid, {pX + x, pY + y})
    get_adj_parts(grid, pos, MapSet.put(acc, num), rest)
  end

  def get_adj_parts(_, _, acc, []), do: acc

  @spec get_num(grid(), tuple()) :: {{non_neg_integer(), non_neg_integer()}, integer()} | nil
  def get_num(grid, {x, y}) do
    if(not Map.has_key?(grid, {x, y}) or not is_numeric?(grid[{x, y}])) do
      nil
    else
      do_get_num(grid, {x, y})
    end
  end

  defp do_get_num(grid, {x, y}) do
    if Map.has_key?(grid, {x - 1, y}) and is_numeric?(grid[{x - 1, y}]) do
      do_get_num(grid, {x - 1, y})
    else
      start = {x, y}

      {start, parse_number(grid, start, [])}
    end
  end

  @spec parse_number(grid(), {non_neg_integer(), non_neg_integer()}, list()) :: integer()
  def parse_number(grid, {x, y} = pos, acc) do
    if Map.has_key?(grid, pos) and is_numeric?(grid[pos]) do
      parse_number(grid, {x + 1, y}, [grid[pos] | acc])
    else
      Enum.reverse(acc) |> to_string() |> String.to_integer()
    end
  end

  @spec part2(String.t()) :: integer()
  def part2(input \\ @input) do
    {grid, symbols} =
      input |> String.split("\n") |> Enum.map(&to_charlist/1) |> make_grid(%{}, [], 0, 0)

    p2(grid, symbols, 0)
  end

  def p2(grid, [s | rest], acc) do
    if grid[s] != ?* do
      p2(grid, rest, acc)
    else
      parts =
        get_adj_parts(grid, s, MapSet.new(), @adj)
        |> MapSet.to_list()
        |> Enum.filter(&(not is_nil(&1)))

      if length(parts) == 2 do
        ratio = Enum.reduce(parts, 1, fn {_, num}, acc -> acc * num end)
        p2(grid, rest, acc + ratio)
      else
        p2(grid, rest, acc)
      end
    end
  end

  def p2(_, [], acc), do: acc
end
