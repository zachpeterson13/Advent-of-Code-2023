defmodule Day05 do
  @test_input File.read!("test_input.txt")
  @input File.read!("input.txt")

  def part1(input \\ @input) do
    test = input |> String.split("\n\n", trim: true)

    [seeds | test] = test

    [seed_to_soil | test] = test
    [soil_to_fertilizer | test] = test
    [fertilizer_to_water | test] = test
    [water_to_light | test] = test
    [light_to_temperature | test] = test
    [temperature_to_humidity | test] = test
    [humidity_to_location | _] = test

    seeds = parse_seeds(seeds)

    seed_to_soil = parse_map(seed_to_soil)
    soil_to_fertilizer = parse_map(soil_to_fertilizer)
    fertilizer_to_water = parse_map(fertilizer_to_water)
    water_to_light = parse_map(water_to_light)
    light_to_temperature = parse_map(light_to_temperature)
    temperature_to_humidity = parse_map(temperature_to_humidity)
    humidity_to_location = parse_map(humidity_to_location)

    seeds
    |> Enum.map(&convert_to_next(&1, seed_to_soil))
    |> Enum.map(&convert_to_next(&1, soil_to_fertilizer))
    |> Enum.map(&convert_to_next(&1, fertilizer_to_water))
    |> Enum.map(&convert_to_next(&1, water_to_light))
    |> Enum.map(&convert_to_next(&1, light_to_temperature))
    |> Enum.map(&convert_to_next(&1, temperature_to_humidity))
    |> Enum.map(&convert_to_next(&1, humidity_to_location))
    |> Enum.min()
  end

  def parse_seeds(seeds) do
    seeds |> String.split(": ") |> Enum.at(1) |> String.split() |> Enum.map(&String.to_integer/1)
  end

  def parse_map(str) do
    [_ | map_str] = str |> String.split("\n", trim: true)

    map_str
    |> Enum.map(&String.split/1)
    |> Enum.map(fn list -> Enum.map(list, &String.to_integer/1) end)
    |> Enum.map(&create_mapping/1)
    |> Enum.reduce(%{}, fn {source, dest}, acc -> Map.put(acc, source, dest) end)
  end

  def create_mapping([dest | [source | [length | []]]]) do
    offset = dest - source

    source = source..(source + length - 1)

    {source, offset}
  end

  def convert_to_next(prev, next_map) do
    key =
      Map.keys(next_map)
      |> Enum.find(fn source -> prev in source end)

    if is_nil(key) do
      prev
    else
      prev + next_map[key]
    end
  end

  def part2(input \\ @input) do
    test = input |> String.split("\n\n", trim: true)

    [seeds | test] = test

    [seed_to_soil | test] = test
    [soil_to_fertilizer | test] = test
    [fertilizer_to_water | test] = test
    [water_to_light | test] = test
    [light_to_temperature | test] = test
    [temperature_to_humidity | test] = test
    [humidity_to_location | _] = test

    initial_seeds = parse_seeds2(seeds)

    operations = [
      parse_map2(seed_to_soil),
      parse_map2(soil_to_fertilizer),
      parse_map2(fertilizer_to_water),
      parse_map2(water_to_light),
      parse_map2(light_to_temperature),
      parse_map2(temperature_to_humidity),
      parse_map2(humidity_to_location)
    ]

    IO.inspect(operations, label: "Ops")

    IO.inspect(initial_seeds, label: "Initial")

    Enum.reduce(operations, initial_seeds, fn ops, acc ->
      process_seeds(acc, [], [], ops) |> IO.inspect()
    end)
    |> Enum.reduce(:infinity, fn x.._//_, acc -> min(acc, x) end)
  end

  def process_seeds(seeds, [], [], []), do: seeds

  def process_seeds([], next_ranges, next_ops, [_ | tail]) do
    process_seeds(next_ops, next_ranges, [], tail)
  end

  def process_seeds(seeds, next_ranges, [], []), do: seeds ++ next_ranges

  def process_seeds(
        [seed_range | rest],
        next_ranges,
        next_ops,
        [{op_range, offset} | _tail] = ops
      ) do
    case intersection(seed_range, op_range) do
      :less_overlap ->
        next_ranges = [(op_range.first + offset)..(seed_range.last + offset) | next_ranges]

        next_ops =
          if seed_range.first..(op_range.first - 1)//1 |> Range.size() > 0 do
            [seed_range.first..(op_range.first - 1) | next_ops]
          else
            next_ops
          end

        process_seeds(rest, next_ranges, next_ops, ops)

      :greater_overlap ->
        next_ranges = [(seed_range.first + offset)..(op_range.last + offset) | next_ranges]

        next_ops =
          if (op_range.last + 1)..seed_range.last//1 |> Range.size() > 0 do
            [(op_range.last + 1)..seed_range.last | next_ops]
          else
            next_ops
          end

        process_seeds(rest, next_ranges, next_ops, ops)

      x when x == :within or x == :same ->
        next_ranges = [(seed_range.first + offset)..(seed_range.last + offset) | next_ranges]

        process_seeds(rest, next_ranges, next_ops, ops)

      :over ->
        next_ranges = [(op_range.first + offset)..(op_range.last + offset) | next_ranges]

        next_ops =
          if seed_range.first..(op_range.first - 1)//1 |> Range.size() > 0 do
            [seed_range.first..op_range.first | next_ops]
          else
            next_ops
          end

        next_ops =
          if (op_range.last + 1)..seed_range.last//1 |> Range.size() > 0 do
            [(op_range.last + 1)..seed_range.last | next_ops]
          else
            next_ops
          end

        process_seeds(rest, next_ranges, next_ops, ops)

      :disjoint ->
        next_ops = [seed_range | next_ops]
        process_seeds(rest, next_ranges, next_ops, ops)
    end
  end

  def parse_seeds2(seeds) do
    seeds
    |> String.split(": ")
    |> Enum.at(1)
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start | [length | []]] -> start..(start + length - 1) end)
  end

  def parse_map2(str) do
    [_ | map_str] = str |> String.split("\n", trim: true)

    map_str
    |> Enum.map(&String.split/1)
    |> Enum.map(fn list -> Enum.map(list, &String.to_integer/1) end)
    |> Enum.map(&create_mapping/1)
  end

  def intersection(f1..l1//_ = r1, f2..l2//_ = r2) do
    if Range.disjoint?(r1, r2) do
      :disjoint
    else
      cond do
        f1 < f2 and l1 >= f2 and l1 < l2 ->
          :less_overlap

        f2 < f1 and f1 <= l2 and l2 < l1 ->
          :greater_overlap

        f1 == f2 and l1 == l2 ->
          :same

        f2 <= f1 and f1 <= l2 and f2 <= l1 and l1 <= l2 ->
          :within

        true ->
          :over
      end
    end
  end
end
