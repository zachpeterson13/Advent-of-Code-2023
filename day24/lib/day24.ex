defmodule Day24 do
  @input File.read!("input.txt")

  def part1(input \\ @input, min \\ 200_000_000_000_000, max \\ 400_000_000_000_000) do
    {input, min, max}
  end

  def part2(input \\ @input) do
    input
  end
end
