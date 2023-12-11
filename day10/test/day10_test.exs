defmodule Day10Test do
  use ExUnit.Case
  import Day10

  test "part1 - 1" do
    input = """
    -L|F7
    7S-7|
    L|7||
    -L-J|
    L|-JF
    """

    result = part1(input)

    assert result == 4
  end

  test "part1 - 2" do
    input = """
    7-F7-
    .FJ|7
    SJLL7
    |F--J
    LJ.LJ
    """

    result = part1(input)

    assert result == 8
  end

  test "part2" do
    input = """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """

    result = part2(input)

    assert result == 4
  end
end
