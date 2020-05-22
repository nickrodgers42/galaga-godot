extends Node2D

export(int) var num_rows = 6
export(int) var num_cols = 10
export(bool) var moving = false
export(int) var move_rate = 25
export(int) var cell_size = 16
export(int) var min_cell_spacing = 2
export(bool) var show_grid = false
export(bool) var show_grid_positions = false


class Cell:
    var enemy = null
    var position = Vector2()
    var grid_position = Vector2()
    var cell_size = 16

    func _init(grid_pos, grid_cell_size=16):
        grid_position = grid_pos
        cell_size = grid_cell_size

    func has_enemy():
        return enemy == null

var screen_size
var grid = []
var cell_spacing = min_cell_spacing
var font
var bounce_count = 0
var breath_count = 0
enum {left, right, breathing_out, breathing_in}

var move_direction = right

func _ready():
    font = DynamicFont.new()
    font.font_data = load("res://assets/PressStart2P-Regular.ttf")
    font.size = 4
    screen_size = get_viewport_rect().size
    for i in range(num_rows):
        grid.append([])
        for j in range(num_cols):
            grid[i].append(Cell.new(Vector2(i, j), cell_size))
    _init_grid_positions()

func _init_grid_positions():
    for i in range(num_rows):
        for j in range(num_cols):
            var cell = grid[i][j]
            var cell_row = cell.grid_position.x
            var cell_col = cell.grid_position.y
            var cell_size = cell.cell_size
            cell.position = Vector2(
                cell_col * cell_size + cell_col * cell_spacing + floor(cell_size / 2),
                cell_row * cell_size + cell_row * cell_spacing + floor(cell_size / 2) + 16
            )

func grid_distance_to_right_edge():
    var cell = grid[0][num_cols - 1]
    return screen_size.x - (cell.position.x + cell.cell_size / 2)

func grid_distance_to_left_edge():
    var cell = grid[0][0]
    return cell.position.x - (cell.cell_size / 2)

func update_grid_positions(delta):
    var move_amount = Vector2()
    if bounce_count == 3:
        if ((move_direction == right and grid_distance_to_left_edge() + delta * move_rate > 32)
            or (move_direction == left and grid_distance_to_left_edge() + delta * move_rate < 32)):
            move_amount.x = 32 - grid_distance_to_left_edge()
            bounce_count = 0
            move_direction = breathing_out
    elif move_direction == right:
        move_amount.x = delta * move_rate
        if grid_distance_to_right_edge() + move_amount.x < 0:
            move_amount.x = grid_distance_to_right_edge()
            move_direction = left
            bounce_count += 1
    elif move_direction == left:
        move_amount.x = delta * move_rate * -1
        if grid_distance_to_left_edge() + move_amount.x < 0:
            move_amount.x = -grid_distance_to_left_edge()
            move_direction = right
            bounce_count += 1
    elif move_direction == breathing_out:
        pass
    elif move_direction == breathing_in:
        pass
    for row in grid:
        for cell in row:
            cell.position += move_amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if moving:
        update_grid_positions(delta)
    update()

func _draw():
    if show_grid:
        for row in grid:
            for cell in row:
                draw_rect(
                    Rect2(cell.position.x - 8, cell.position.y - 8, cell_size, cell_size),
                    Color("#00ffff"))
                if show_grid_positions:
                    draw_string(
                        font,
                        Vector2(cell.position.x - 8, cell.position.y),
                        " " + str(cell.grid_position.x) + "," + str(cell.grid_position.y),
                        Color('#000000')
                    )
