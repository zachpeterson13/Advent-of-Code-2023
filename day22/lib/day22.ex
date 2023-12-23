defmodule Day22 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split("~", trim: true)
      |> Enum.map(fn coord ->
        coord
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
    |> Enum.sort(fn {{_, _, z1}, _}, {{_, _, z2}, _} -> z1 < z2 end)
  end

  def get_bounds([], x, y, z), do: {x, y, z}

  def get_bounds([{{x1, y1, z1}, {x2, y2, z2}} | tail], x, y, z) do
    x = max(x1, x2) |> max(x)
    y = max(y1, y2) |> max(y)
    z = max(z1, z2) |> max(z)

    get_bounds(tail, x, y, z)
  end

  def can_move_down(_, {{_, _, z}, {_, _, _}}) when z <= 1, do: false
  def can_move_down(_, {{_, _, _}, {_, _, z}}) when z <= 1, do: false

  def can_move_down(map, {{x1, y1, z1}, {x2, y2, z2}}) do
    c =
      for x <- x1..x2,
          y <- y1..y2,
          z <- z1..z2,
          do: {x, y, z - 1}

    c
    |> Enum.all?(fn pos ->
      Map.get(map, pos, false) == false
    end)
  end

  def move_down(map, {{x1, y1, z1}, {x2, y2, z2}} = coord) do
    if can_move_down(map, coord) do
      move_down(map, {{x1, y1, z1 - 1}, {x2, y2, z2 - 1}})
    else
      c =
        for x <- x1..x2,
            y <- y1..y2,
            z <- z1..z2,
            do: {x, y, z}

      new_map =
        c
        |> Enum.reduce(map, fn pos, acc ->
          Map.put(acc, pos, true)
        end)

      {new_map, coord}
    end
  end

  def can_be_deleted(map, {{x1, y1, z1}, {x2, y2, z2}} = coord, coords) do
    cubes =
      for x <- x1..x2,
          y <- y1..y2,
          z <- z1..z2,
          do: {x, y, z}

    without = Enum.reduce(cubes, map, fn cube, acc -> Map.put(acc, cube, false) end)

    bool =
      coords
      |> Enum.filter(fn elem -> elem != coord end)
      |> Enum.any?(fn {{x1, y1, z1}, {x2, y2, z2}} = elem ->
        cubes =
          for x <- x1..x2,
              y <- y1..y2,
              z <- z1..z2,
              do: {x, y, z}

        Enum.reduce(cubes, without, fn cube, acc -> Map.put(acc, cube, false) end)
        |> can_move_down(elem)
      end)

    not bool
  end

  @input File.read!("input.txt")

  def part1(input \\ @input) do
    coords = input |> parse_input()

    {map, coords} =
      Enum.reduce(coords, {%{}, []}, fn coord, {map, new_list} ->
        {new_map, new_coord} = move_down(map, coord)

        {new_map, [new_coord | new_list]}
      end)

    Enum.map(coords, fn coord ->
      can_be_deleted(map, coord, coords)
    end)
    |> Enum.count(fn elem -> elem end)
  end

  def count_falls(map, {{x1, y1, z1}, {x2, y2, z2}} = coord, coords) do
    # remove brick
    cubes =
      for x <- x1..x2,
          y <- y1..y2,
          z <- z1..z2,
          do: {x, y, z}

    without_map = Enum.reduce(cubes, map, fn cube, acc -> Map.put(acc, cube, false) end)

    without_list =
      coords
      |> Enum.filter(fn elem -> elem != coord end)

    loop(without_map, without_list, 0)
  end

  def loop(map, list, count) do
    {new_map, new_list, bricks_fell} =
      list
      |> Enum.reduce({map, [], 0}, fn {{x1, y1, z1}, {x2, y2, z2}} = elem,
                                      {map, new_list, counter} ->
        cubes =
          for x <- x1..x2,
              y <- y1..y2,
              z <- z1..z2,
              do: {x, y, z}

        # remove the target brick from the map to see if it can move down
        without = Enum.reduce(cubes, map, fn cube, acc -> Map.put(acc, cube, false) end)

        if can_move_down(without, elem) do
          {new_map, new_coord} = move_down(without, elem)

          {new_map, [new_coord | new_list], counter + 1}
        else
          # put brick back in list if it cannot move
          with = Enum.reduce(cubes, map, fn cube, acc -> Map.put(acc, cube, true) end)
          {with, [elem | new_list], counter}
        end
      end)

    if bricks_fell != 0 do
      loop(new_map, new_list |> Enum.reverse(), count + bricks_fell)
    else
      count
    end
  end

  def part2(input \\ @input) do
    coords = input |> parse_input()

    {map, coords} =
      Enum.reduce(coords, {%{}, []}, fn coord, {map, new_list} ->
        {new_map, new_coord} = move_down(map, coord)

        {new_map, [new_coord | new_list]}
      end)

    Enum.map(coords, fn coord ->
      count_falls(map, coord, coords |> Enum.reverse())
    end)
    |> Enum.sum()
  end
end
