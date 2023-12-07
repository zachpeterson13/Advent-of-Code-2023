defmodule Day07Test do
  use ExUnit.Case
  import Day07

  @input """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  # @tag :skip
  test "part1" do
    result = part1(@input) |> IO.inspect()

    assert result == 6440
  end

  test "get_type_5oak" do
    {result, _, _} = get_type({'AAAAA', 0})
    assert result == :five_of_a_kind
  end

  test "get_type_4oak" do
    {result, _, _} = get_type({'AAAA1', 0})
    assert result == :four_of_a_kind

    {result, _, _} = get_type({'AAA1A', 0})
    assert result == :four_of_a_kind

    {result, _, _} = get_type({'AA1AA', 0})
    assert result == :four_of_a_kind

    {result, _, _} = get_type({'A1AAA', 0})
    assert result == :four_of_a_kind

    {result, _, _} = get_type({'1AAAA', 0})
    assert result == :four_of_a_kind
  end

  test "get_type_fh" do
    {result, _, _} = get_type({'AAA11', 0})
    assert result == :full_house

    {result, _, _} = get_type({'11AAA', 0})
    assert result == :full_house

    {result, _, _} = get_type({'A111A', 0})
    assert result == :full_house
  end

  test "get_type_3oak" do
    {result, _, _} = get_type({'AAA12', 0})
    assert result == :three_of_a_kind

    {result, _, _} = get_type({'12AAA', 0})
    assert result == :three_of_a_kind
  end

  test "get_type_2p" do
    {result, _, _} = get_type({'AA112', 0})
    assert result == :two_pair

    {result, _, _} = get_type({'121AA', 0})
    assert result == :two_pair
  end

  test "get_type_1p" do
    {result, _, _} = get_type({'AA132', 0})
    assert result == :one_pair

    {result, _, _} = get_type({'1213A', 0})
    assert result == :one_pair
  end

  test "get_type_high" do
    {result, _, _} = get_type({'12345', 0})
    assert result == :high_card

    {result, _, _} = get_type({'AKQJT', 0})
    assert result == :high_card
  end

  test "compare_hands1" do
    result =
      [{:three_of_a_kind, 'QQQJA', 483}, {:three_of_a_kind, 'T55J5', 684}]
      |> Enum.sort(&compare_hands/2)

    assert result == [{:three_of_a_kind, 'T55J5', 684}, {:three_of_a_kind, 'QQQJA', 483}]
  end

  test "compare_hands2" do
    result =
      [{:three_of_a_kind, 'T55J5', 684}, {:three_of_a_kind, 'QQQJA', 483}]
      |> Enum.sort(&compare_hands/2)

    assert result == [{:three_of_a_kind, 'T55J5', 684}, {:three_of_a_kind, 'QQQJA', 483}]
  end
end
