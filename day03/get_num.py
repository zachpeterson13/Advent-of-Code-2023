def get_num(grid, pos):
    if pos not in grid or not grid[pos].isnumeric():
        return None
    # pos is in grid, and is a digit
    while pos - 1 in grid and grid[pos - 1].isnumeric():
        pos -= 1
    start = pos
    num = ""
    while pos in grid and grid[pos].isnumeric():
        num += grid[pos]
        pos += 1
    return start, int(num)
