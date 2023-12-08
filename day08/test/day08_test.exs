defmodule Day08Test do
  use ExUnit.Case
  import Day08

  @input1 """
  RL

  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
  """

  @input2 """
  LLR

  AAA = (BBB, BBB)
  BBB = (AAA, ZZZ)
  ZZZ = (ZZZ, ZZZ)
  """

  test "part1 input1" do
    result = part1(@input1)

    assert result == 2
  end

  test "part1 input2" do
    result = part1(@input2)

    assert result == 6
  end
end
