defmodule Day05Test do
  use ExUnit.Case
  import Day05
  @input File.read!("test_input.txt")

  test "part1" do
    result = part1(@input) |> IO.inspect()

    assert result == 35
  end
end
