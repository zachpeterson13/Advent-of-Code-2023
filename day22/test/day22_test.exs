defmodule Day22Test do
  use ExUnit.Case
  import Day22

  test "part1" do
    input = """
    1,0,1~1,2,1
    0,0,2~2,0,2
    0,2,3~2,2,3
    0,0,4~0,2,4
    2,0,5~2,2,5
    0,1,6~2,1,6
    1,1,8~1,1,9
    """

    result = part1(input)

    assert result == 5
  end

  test "part2" do
    input = """
    1,0,1~1,2,1
    0,0,2~2,0,2
    0,2,3~2,2,3
    0,0,4~0,2,4
    2,0,5~2,2,5
    0,1,6~2,1,6
    1,1,8~1,1,9
    """

    result = part2(input)

    assert result == 7
  end
end
