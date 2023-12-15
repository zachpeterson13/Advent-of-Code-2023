defmodule Day15 do
  @input File.read!("input.txt")

  def part1(input \\ @input) do
    input
    |> String.replace("\n", ",")
    |> String.split(",", trim: true)
    |> Enum.map(fn str ->
      str
      |> to_charlist()
      |> Enum.reduce(0, fn char, acc ->
        ((acc + char) * 17)
        |> rem(256)
      end)
    end)
    |> Enum.sum()
  end

  def hash(str) do
    str
    |> to_charlist()
    |> Enum.reduce(0, fn char, acc ->
      ((acc + char) * 17)
      |> rem(256)
    end)
  end

  def parse_step(step) do
    case String.split(step, ["=", "-"]) do
      [label, ""] -> {label, :remove}
      [label, fl] -> {label, String.to_integer(fl)}
    end
  end

  def process_steps(steps) do
    Enum.reduce(steps, %{}, fn {label, action}, acc ->
      box_num = hash(label)
      box = acc[box_num]

      case action do
        :remove ->
          if box == nil do
            acc
          else
            new_box = List.keydelete(box, label, 0)
            Map.put(acc, box_num, new_box)
          end

        fl ->
          new_box =
            if box == nil do
              [{label, fl}]
            else
              List.keystore(box, label, 0, {label, fl})
            end

          Map.put(acc, box_num, new_box)
      end
    end)
  end

  def part2(input \\ @input) do
    steps =
      input
      |> String.replace("\n", ",")
      |> String.split(",", trim: true)
      |> Enum.map(&parse_step/1)

    boxes = process_steps(steps)

    Enum.reduce(boxes, 0, fn {box_num, list}, acc ->
      acc +
        (list
         |> Enum.with_index(1)
         |> Enum.reduce(0, fn {{_, fl}, slot}, acc -> acc + (box_num + 1) * slot * fl end))
    end)
  end
end
