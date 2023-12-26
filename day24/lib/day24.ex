defmodule Day24 do
  @input File.read!("input.txt")

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      String.split(str, " @ ", trim: true)
      |> Enum.map(fn coord ->
        String.split(coord, ", ", trim: true)
        |> Enum.map(fn num ->
          String.trim(num) |> String.to_integer()
        end)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end

  def get_intersection({p1, v1}, {p2, v2}) do
    {x1, y1, _} = p1
    {v1x, v1y, _} = v1
    {x2, y2} = {x1 + v1x, y1 + v1y}

    {x3, y3, _} = p2
    {v2x, v2y, _} = v2
    {x4, y4} = {x3 + v2x, y3 + v2y}

    numx = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)
    numy = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)
    den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    if den == 0 do
      {:none, :none}
    else
      x = numx / den
      y = numy / den

      if same_dir({v1x, v1y}, get_vector({x1, y1}, {x, y})) and
           same_dir({v2x, v2y}, get_vector({x3, y3}, {x, y})) do
        {x, y}
      else
        {:none, :none}
      end
    end
  end

  def same_dir({x1, y1}, {x2, y2}) do
    abs(x1) + abs(x2) == abs(x1 + x2) and abs(y1) + abs(y2) == abs(y1 + y2)
  end

  def get_vector({x1, y1}, {x2, y2}) do
    {x2 - x1, y2 - y1}
  end

  def part1(input \\ @input, min \\ 200_000_000_000_000, max \\ 400_000_000_000_000) do
    hail = parse_input(input)

    Comb.combinations(hail, 2)
    |> Enum.map(fn list -> List.to_tuple(list) end)
    |> Enum.map(fn {first, second} -> get_intersection(first, second) end)
    |> Enum.filter(fn {x, y} -> x != :none and y != :none end)
    |> Enum.filter(fn {x, y} -> min <= x and x <= max and (min <= y and y <= max) end)
    |> Enum.count()
  end

  def part2(input \\ @input) do
    input
  end
end
