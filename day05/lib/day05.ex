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

  def part2(_input) do
  end
end
