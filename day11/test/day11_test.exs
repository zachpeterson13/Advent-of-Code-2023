defmodule Day11Test do
  use ExUnit.Case
  import Day11

  test "part1" do
    input = """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """

    result = part1(input)

    assert result == 374
  end

  test "part2 - 10x" do
    input = """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """

    result = part2(input, 10)

    assert result == 1030
  end

  test "part2 - 100x" do
    input = """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """

    result = part2(input, 100)

    assert result == 8410
  end
end
