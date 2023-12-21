defmodule Day20 do
  @input File.read!("input.txt")

  def parse_input(input) do
    map =
      String.split(input, "\n", trim: true)
      |> Enum.reduce(%{}, fn str, acc ->
        {key, dest} = str |> String.split(" -> ", trim: true) |> List.to_tuple()

        dest = dest |> String.split(", ", trim: true)

        {type, key} =
          case key do
            "%" <> key -> {:flip, key}
            "&" <> key -> {:con, key}
            "broadcaster" -> {:broadcaster, "broadcaster"}
          end

        case type do
          :flip ->
            Map.put(acc, key, {type, flip(), dest})

          _ ->
            Map.put(acc, key, {type, nil, dest})
        end
      end)

    # update the con modules with their initial state functions
    con_map =
      Map.filter(map, fn {_, {type, _, _}} -> type == :con end)
      |> Map.keys()
      |> Enum.reduce(map, fn con, acc ->
        initial_state =
          Map.filter(map, fn {_, {_, _, dest}} -> Enum.any?(dest, fn val -> val == con end) end)
          |> Map.keys()
          |> Map.new(fn elem -> {elem, false} end)

        {_, _, dest} = Map.get(map, con)
        Map.put(acc, con, {:con, con(initial_state), dest})
      end)

    Map.merge(map, con_map)
  end

  # true => high pulse
  # fales => low pulse

  def flip() do
    {false, fn pulse -> flip(pulse, false) end}
  end

  def flip(pulse, state) do
    case pulse do
      true -> {state, fn pulse -> flip(pulse, state) end}
      false -> {not state, fn pulse -> flip(pulse, not state) end}
    end
  end

  def con(input) do
    {true, fn key, value -> con(key, value, input) end}
  end

  def con(key, value, state) do
    new_state = Map.put(state, key, value)

    if Map.values(new_state) |> Enum.all?(fn value -> value end) do
      {false, fn key, value -> con(key, value, new_state) end}
    else
      {true, fn key, value -> con(key, value, new_state) end}
    end
  end

  def push_button(mods), do: push_button(mods, [{"broadcaster", false, "button"}], [], 0, 0)

  def push_button(mods, [], [], lows, highs), do: {mods, lows, highs}

  def push_button(mods, [], queue, lows, highs) do
    push_button(mods, Enum.reverse(queue), [], lows, highs)
  end

  def push_button(mods, [{mod, pulse, from} | tail], queue, lows, highs) do
    {type, state_func, dest} = Map.get(mods, mod, {:output, nil, nil})
    # |> IO.inspect(label: "#{from} -#{pulse}-> #{mod}")

    {new_lows, new_highs} =
      if pulse do
        {lows, highs + 1}
      else
        {lows + 1, highs}
      end

    case type do
      :broadcaster ->
        new_queue = Enum.reduce(dest, queue, fn d, acc -> [{d, pulse, mod} | acc] end)

        push_button(mods, tail, new_queue, new_lows, new_highs)

      :output ->
        push_button(mods, tail, queue, new_lows, new_highs)

      :flip ->
        if pulse == true do
          push_button(mods, tail, queue, new_lows, new_highs)
        else
          {_state, f} = state_func
          {new_state, new_f} = f.(pulse)

          updated_mods = Map.put(mods, mod, {type, {new_state, new_f}, dest})

          updated_queue = Enum.reduce(dest, queue, fn d, acc -> [{d, new_state, mod} | acc] end)

          push_button(updated_mods, tail, updated_queue, new_lows, new_highs)
        end

      :con ->
        {_state, f} = state_func

        {new_state, new_f} = f.(from, pulse)

        updated_mods = Map.put(mods, mod, {type, {new_state, new_f}, dest})

        updated_queue = Enum.reduce(dest, queue, fn d, acc -> [{d, new_state, mod} | acc] end)

        push_button(updated_mods, tail, updated_queue, new_lows, new_highs)
    end
  end

  def part1(input \\ @input) do
    mods = parse_input(input)

    {_, lows, highs} =
      Enum.reduce(0..(1000 - 1), {mods, 0, 0}, fn _, {mods, lows, highs} ->
        {new_mods, l, h} = push_button(mods)

        {new_mods, lows + l, highs + h}
      end)

    lows * highs
  end

  def part2(input \\ @input) do
    input
  end
end
