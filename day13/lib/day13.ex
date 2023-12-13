defmodule Day13 do
  def enumerate_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.graphemes(&1) |> Enum.with_index()))
    |> Enum.with_index()
  end

  def make_grid(enumerated) do
    Enum.reduce(enumerated, %{}, fn {list, row}, acc1 ->
      Map.merge(
        acc1,
        Enum.reduce(list, %{}, fn {str, col}, acc2 ->
          Map.put(acc2, {col, row}, str)
        end)
      )
    end)
  end

  def find_horizontal_reflection(grid) do
    {num_cols, num_rows} =
      Map.keys(grid) |> Enum.max(fn {x1, y1}, {x2, y2} -> x1 >= x2 and y1 >= y2 end)

    rows =
      0..num_rows
      |> Enum.map(fn row ->
        0..num_cols
        |> Enum.reduce([], fn col, acc -> [grid[{col, row}] | acc] end)
        |> Enum.reverse()
      end)

    find_consecutive_dups(rows)
    |> Enum.map(&{&1, is_reflection?(&1, rows)})
    |> Enum.filter(fn {_, bool} -> bool end)
    |> Enum.map(fn {idx, _} -> idx end)
    |> List.first()
  end

  def find_vertical_reflection(grid) do
    {num_cols, num_rows} =
      Map.keys(grid) |> Enum.max(fn {x1, y1}, {x2, y2} -> x1 >= x2 and y1 >= y2 end)

    cols =
      0..num_cols
      |> Enum.map(fn col ->
        0..num_rows
        |> Enum.reduce([], fn row, acc -> [grid[{col, row}] | acc] end)
        |> Enum.reverse()
      end)

    find_consecutive_dups(cols)
    |> Enum.map(&{&1, is_reflection?(&1, cols)})
    |> Enum.filter(fn {_, bool} -> bool end)
    |> Enum.map(fn {idx, _} -> idx end)
    |> List.first()
  end

  def find_consecutive_dups(list), do: list |> Enum.with_index() |> find_consecutive_dups([])

  def find_consecutive_dups([_], acc), do: acc |> Enum.reverse()

  def find_consecutive_dups([{first, idx}, {second, _} = s | rest], acc) do
    if first == second do
      find_consecutive_dups([s | rest], [idx | acc])
    else
      find_consecutive_dups([s | rest], acc)
    end
  end

  def is_reflection?(at, list) do
    Enum.zip(at..0, (at + 1)..(length(list) - 1))
    |> Enum.all?(fn {l, r} -> Enum.at(list, l) == Enum.at(list, r) end)
  end

  @input File.read!("input.txt")

  def part1(input \\ @input) do
    patterns =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn p -> p |> enumerate_input() |> make_grid() end)

    horizonals =
      Enum.map(patterns, &find_horizontal_reflection/1)
      |> Enum.filter(fn elem -> elem != nil end)
      |> Enum.map(fn elem -> (elem + 1) * 100 end)

    verticals =
      Enum.map(patterns, &find_vertical_reflection/1)
      |> Enum.filter(fn elem -> elem != nil end)
      |> Enum.map(fn elem -> elem + 1 end)

    (verticals ++ horizonals) |> Enum.sum()
  end

  def find_horizontal_reflection2(grid) do
    {num_cols, num_rows} =
      Map.keys(grid) |> Enum.max(fn {x1, y1}, {x2, y2} -> x1 >= x2 and y1 >= y2 end)

    rows =
      0..num_rows
      |> Enum.map(fn row ->
        0..num_cols
        |> Enum.reduce([], fn col, acc ->
          if grid[{col, row}] == "#" do
            [?1 | acc]
          else
            [?0 | acc]
          end
        end)
        # treat # as 1 and . as 0 and convert each row/col to binary number
        |> Enum.reverse()
        |> List.to_integer(2)
      end)

    import Bitwise

    # go through each possible reflection point and check if it is valid by 
    # xor-ing the corrosponding numbers and adding up. if the total is 1, we 
    # know there was only 1 difference, aka our smudge!
    0..(length(rows) - 2)
    |> Enum.map(fn idx ->
      if Enum.zip(idx..0, (idx + 1)..(length(rows) - 1))
         |> Enum.reduce(0, fn {l, r}, acc ->
           acc +
             (bxor(Enum.at(rows, l), Enum.at(rows, r))
              |> Integer.digits(2)
              |> Enum.count(fn elem -> elem == 1 end))
         end) == 1 do
        idx
      else
        nil
      end
    end)
    |> Enum.filter(fn elem -> elem != nil end)
    |> List.first()
  end

  def find_vertical_reflection2(grid) do
    {num_cols, num_rows} =
      Map.keys(grid) |> Enum.max(fn {x1, y1}, {x2, y2} -> x1 >= x2 and y1 >= y2 end)

    cols =
      0..num_cols
      |> Enum.map(fn col ->
        0..num_rows
        |> Enum.reduce([], fn row, acc ->
          if grid[{col, row}] == "#" do
            [?1 | acc]
          else
            [?0 | acc]
          end
        end)
        |> Enum.reverse()
        |> List.to_integer(2)
      end)

    import Bitwise

    0..(length(cols) - 2)
    |> Enum.map(fn idx ->
      if Enum.zip(idx..0, (idx + 1)..(length(cols) - 1))
         |> Enum.reduce(0, fn {l, r}, acc ->
           acc +
             (bxor(Enum.at(cols, l), Enum.at(cols, r))
              |> Integer.digits(2)
              |> Enum.count(fn elem -> elem == 1 end))
         end) == 1 do
        idx
      else
        nil
      end
    end)
    |> Enum.filter(fn elem -> elem != nil end)
    |> List.first()
  end

  def part2(input \\ @input) do
    patterns =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn p -> p |> enumerate_input() |> make_grid() end)

    horizontals =
      Enum.map(patterns, &find_horizontal_reflection2/1)
      |> Enum.filter(fn elem -> elem != nil end)
      |> Enum.map(fn elem -> (elem + 1) * 100 end)

    verticals =
      Enum.map(patterns, &find_vertical_reflection2/1)
      |> Enum.filter(fn elem -> elem != nil end)
      |> Enum.map(fn elem -> elem + 1 end)

    (horizontals ++ verticals) |> Enum.sum()
  end
end
