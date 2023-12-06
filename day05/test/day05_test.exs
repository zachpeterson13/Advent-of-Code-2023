defmodule Day05Test do
  use ExUnit.Case
  import Day05
  @input File.read!("test_input.txt")

  test "part1" do
    result = part1(@input)

    assert result == 35
  end

  # @tag :skip
  test "part2" do
    result = part2(@input) |> IO.inspect(charlists: :as_lists)

    assert result == 46
  end

  test "less overlap" do
    assert intersection(0..10, 5..15) == :less_overlap
  end

  test "greater overlap" do
    assert intersection(5..15, 0..10) == :greater_overlap
  end

  test "within" do
    assert intersection(5..15, 0..20) == :within
  end

  test "same" do
    assert intersection(5..15, 5..15) == :same
  end

  test "over" do
    assert intersection(0..20, 5..15) == :over
  end

  test "disjoint" do
    assert intersection(57..69, 5..15) == :disjoint
  end
end
