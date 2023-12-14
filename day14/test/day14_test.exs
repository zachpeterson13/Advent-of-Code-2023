defmodule Day14Test do
  use ExUnit.Case
  import Day14

  test "part1" do
    input = """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """

    result = part1(input)

    assert result == 136
  end

  test "part2" do
    input = """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """

    result = part2(input)

    assert result == 64
  end
end
