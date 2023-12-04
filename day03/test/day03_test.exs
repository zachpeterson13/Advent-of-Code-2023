defmodule Day03Test do
  use ExUnit.Case
  import Day03

  test "test part1" do
    input = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """

    result = part1(input)

    assert result == 4361
  end

  test "test part2" do
    input = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """

    result = part2(input)

    assert result == 467_835
  end
end
