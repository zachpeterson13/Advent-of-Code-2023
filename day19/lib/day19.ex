defmodule Day19 do
  @input File.read!("input.txt")

  def parse_input(input) do
    {workflows, parts} = input |> String.split("\n\n", trim: true) |> List.to_tuple()

    workflows = parse_workflows(workflows)

    parts = parse_parts(parts)

    {workflows, parts}
  end

  def parse_workflows(workflows) do
    workflows
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn wrk_str, acc ->
      {name, rules} = String.split(wrk_str, ["{", "}"], trim: true) |> List.to_tuple()

      rules =
        rules
        |> String.split(",", trim: true)
        |> Enum.map(fn rule_str ->
          rule_str |> String.split(":", trim: true) |> List.to_tuple() |> parse_rule()
        end)

      Map.merge(acc, %{name => rules})
    end)
  end

  def parse_rule({send_to}), do: {send_to}

  def parse_rule({rule_str, send_to}) do
    {category, rest} = String.split_at(rule_str, 1)
    {sign, num} = String.split_at(rest, 1)
    num = String.to_integer(num)

    compare =
      case sign do
        "<" ->
          &Kernel.</2

        ">" ->
          &Kernel.>/2
      end

    rule = fn %{x: x, m: m, a: a, s: s} ->
      case category do
        "x" ->
          compare.(x, num)

        "m" ->
          compare.(m, num)

        "a" ->
          compare.(a, num)

        "s" ->
          compare.(s, num)
      end
    end

    {rule, send_to}
  end

  def parse_parts(parts) do
    parts
    |> String.split("\n", trim: true)
    |> Enum.map(fn part_str ->
      part_str
      |> String.replace(["{", "}"], "")
      |> String.split(",", trim: true)
      |> Enum.reduce(%{}, fn str, acc ->
        case str do
          "x=" <> num ->
            num = String.to_integer(num)

            Map.put(acc, :x, num)

          "m=" <> num ->
            num = String.to_integer(num)

            Map.put(acc, :m, num)

          "a=" <> num ->
            num = String.to_integer(num)

            Map.put(acc, :a, num)

          "s=" <> num ->
            num = String.to_integer(num)

            Map.put(acc, :s, num)
        end
      end)
    end)
  end

  def process(_, [{"A"}], part), do: {part, :accepted}
  def process(_, [{"R"}], part), do: {part, :rejected}
  def process(workflows, [{send_to}], part), do: process(workflows, workflows[send_to], part)

  def process(workflows, [{rule, send_to} | rest], part) do
    if rule.(part) do
      case send_to do
        "A" -> {part, :accepted}
        "R" -> {part, :rejected}
        _ -> process(workflows, workflows[send_to], part)
      end
    else
      process(workflows, rest, part)
    end
  end

  def part1(input \\ @input) do
    {workflows, parts} = input |> parse_input()

    start = workflows["in"]

    parts
    |> Enum.map(fn part ->
      process(workflows, start, part)
    end)
    |> Enum.filter(fn {_, status} -> status == :accepted end)
    |> Enum.map(fn {%{x: x, m: m, a: a, s: s}, _} -> x + m + a + s end)
    |> Enum.sum()
  end

  def parse_input2(input) do
    {workflows, _} = input |> String.split("\n\n", trim: true) |> List.to_tuple()

    workflows
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{"A" => [{"A"}], "R" => [{"R"}]}, fn wrk_str, acc ->
      {name, rules} = String.split(wrk_str, ["{", "}"], trim: true) |> List.to_tuple()

      rules =
        rules
        |> String.split(",", trim: true)
        |> Enum.map(fn rule_str ->
          rule_str |> String.split(":", trim: true) |> List.to_tuple()
        end)

      Map.merge(acc, %{name => rules})
    end)
  end

  def apply_rules(workflows, %{x: x, m: m, a: a, s: s} = range, wf) do
    rules = workflows[wf]

    Enum.reduce(rules, [{range, wf}], fn
      {rule_str, next}, [{range, _} | tail] ->
        {category, rest} = String.split_at(rule_str, 1)
        {sign, num} = String.split_at(rest, 1)
        num = String.to_integer(num)
        category = String.to_atom(category)

        new_range =
          case sign do
            "<" ->
              [
                {%{range | category => num..range[category].last}, next},
                {%{range | category => range[category].first..(num - 1)}, next}
                | tail
              ]

            ">" ->
              [
                {%{range | category => range[category].first..num}, next},
                {%{range | category => (num + 1)..range[category].last}, next}
                | tail
              ]
          end

        new_range

      {next}, [{range, _} | tail] ->
        [{range, next} | tail]
    end)
  end

  def process2(workflows, ranges) do
    if Enum.all?(ranges, fn {_, wf} -> wf == "A" or wf == "R" end) do
      ranges
    else
      new_ranges = Enum.flat_map(ranges, fn {range, wf} -> apply_rules(workflows, range, wf) end)

      process2(workflows, new_ranges)
    end
  end

  def part2(input \\ @input) do
    workflows = input |> parse_input2()

    start = [{%{x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000}, "in"}]

    process2(workflows, start)
    |> Enum.filter(fn {_, status} -> status == "A" end)
    |> Enum.map(fn {%{x: x, m: m, a: a, s: s}, _} ->
      Enum.count(x) * Enum.count(m) * Enum.count(a) * Enum.count(s)
    end)
    |> Enum.sum()
  end
end
