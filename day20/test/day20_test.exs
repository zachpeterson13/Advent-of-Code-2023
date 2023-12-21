defmodule Day20Test do
  use ExUnit.Case
  import Day20

  # @tag :skip
  test "part1 - 1" do
    input = """
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
    """

    result = part1(input)

    assert result == 32_000_000
  end

  # @tag :skip
  test "part1 - 2" do
    input = """
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """

    result = part1(input)

    assert result == 11_687_500
  end
end
