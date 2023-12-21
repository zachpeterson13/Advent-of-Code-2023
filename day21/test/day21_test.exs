defmodule Day21Test do
  use ExUnit.Case
  import Day21

  test "part1" do
    input = """
    ...........
    .....###.#.
    .###.##..#.
    ..#.#...#..
    ....#.#....
    .##..S####.
    .##..#...#.
    .......##..
    .##.#.####.
    .##..##.##.
    ...........
    """

    result = part1(input, 6)

    assert result == 16
  end
end
