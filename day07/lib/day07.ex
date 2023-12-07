defmodule Day07 do
  @input File.read!("input.txt")
  @strength [?A, ?K, ?Q, ?J, ?T, ?9, ?8, ?7, ?6, ?5, ?4, ?3, ?2]
            |> Enum.reverse()
            |> Enum.with_index()
            |> Map.new()

  def part1(input \\ @input) do
    hands =
      input
      |> parse_input()
      |> Enum.map(&get_type/1)

    five =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :five_of_a_kind end)
      |> Enum.sort(&compare_hands/2)

    four =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :four_of_a_kind end)
      |> Enum.sort(&compare_hands/2)

    full =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :full_house end)
      |> Enum.sort(&compare_hands/2)

    three =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :three_of_a_kind end)
      |> Enum.sort(&compare_hands/2)

    two =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :two_pair end)
      |> Enum.sort(&compare_hands/2)

    one =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :one_pair end)
      |> Enum.sort(&compare_hands/2)

    high =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :high_card end)
      |> Enum.sort(&compare_hands/2)

    (high ++ one ++ two ++ three ++ full ++ four ++ five)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, _, bid}, rank} -> rank * bid end)
    |> Enum.sum()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(&1 |> String.split() |> List.to_tuple()))
    |> Enum.map(fn {hand, bid_str} -> {hand |> to_charlist(), bid_str |> String.to_integer()} end)
  end

  def get_type({hand, bid}) do
    card_count =
      hand
      |> Enum.reduce(%{}, fn char, acc ->
        new_value = Map.get(acc, char, 0) + 1
        Map.put(acc, char, new_value)
      end)

    type =
      case Map.values(card_count) |> Enum.sort(:desc) do
        [5] ->
          :five_of_a_kind

        [4, 1] ->
          :four_of_a_kind

        [3, 2] ->
          :full_house

        [3 | _] ->
          :three_of_a_kind

        [2, 2, 1] ->
          :two_pair

        [2 | _] ->
          :one_pair

        _ ->
          :high_card
      end

    {type, hand, bid}
  end

  def compare_hands({ftype, [head | ftail], fbid}, {stype, [head | stail], sbid}) do
    compare_hands({ftype, ftail, fbid}, {stype, stail, sbid})
  end

  def compare_hands({_, [first | _], _}, {_, [second | _], _}) do
    @strength[first] < @strength[second]
  end

  @strength_joker [?A, ?K, ?Q, ?T, ?9, ?8, ?7, ?6, ?5, ?4, ?3, ?2, ?J]
                  |> Enum.reverse()
                  |> Enum.with_index()
                  |> Map.new()

  def part2(input \\ @input) do
    hands =
      input
      |> parse_input()
      |> Enum.map(&get_type2/1)

    five =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :five_of_a_kind end)
      |> Enum.sort(&compare_hands2/2)

    four =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :four_of_a_kind end)
      |> Enum.sort(&compare_hands2/2)

    full =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :full_house end)
      |> Enum.sort(&compare_hands2/2)

    three =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :three_of_a_kind end)
      |> Enum.sort(&compare_hands2/2)

    two =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :two_pair end)
      |> Enum.sort(&compare_hands2/2)

    one =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :one_pair end)
      |> Enum.sort(&compare_hands2/2)

    high =
      hands
      |> Enum.filter(fn {type, _, _} -> type == :high_card end)
      |> Enum.sort(&compare_hands2/2)

    (high ++ one ++ two ++ three ++ full ++ four ++ five)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, _, bid}, rank} -> rank * bid end)
    |> Enum.sum()
  end

  def get_type2({hand, bid}) do
    card_count =
      hand
      |> Enum.reduce(%{}, fn char, acc ->
        new_value = Map.get(acc, char, 0) + 1
        Map.put(acc, char, new_value)
      end)

    joker_count = Map.get(card_count, ?J, 0)

    card_count =
      if joker_count == 5 do
        card_count
      else
        [{key, val} | rest] =
          card_count
          |> Map.to_list()
          |> Enum.filter(fn {key, _} -> key != ?J end)
          |> Enum.sort(fn {_, v1}, {_, v2} ->
            v1 > v2
          end)

        [{key, val + joker_count} | rest] |> Map.new()
      end

    type =
      case Map.values(card_count) |> Enum.sort(:desc) do
        [5] ->
          :five_of_a_kind

        [4 | _] ->
          :four_of_a_kind

        [3, 2] ->
          :full_house

        [3 | _] ->
          :three_of_a_kind

        [2, 2, 1] ->
          :two_pair

        [2 | _] ->
          :one_pair

        _ ->
          :high_card
      end

    {type, hand, bid}
  end

  def compare_hands2({ftype, [head | ftail], fbid}, {stype, [head | stail], sbid}) do
    compare_hands2({ftype, ftail, fbid}, {stype, stail, sbid})
  end

  def compare_hands2({_, [first | _], _}, {_, [second | _], _}) do
    @strength_joker[first] < @strength_joker[second]
  end
end
