defmodule Day16Test do
  use ExUnit.Case
  import Day16

  test "part1" do
    input = """
    .|...\\....
    |.-.\\.....
    .....|-...
    ........|.
    ..........
    .........\\
    ..../.\\\\..
    .-.-/..|..
    .|....-|.\\
    ..//.|....
    """

    result = part1(input)

    assert result == 46
  end
end
