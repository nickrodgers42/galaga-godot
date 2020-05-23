extends Node2D

export(int) var num_rows = 6
export(int) var num_cols = 10
export(bool) var moving = true
export(int) var move_rate = 15
export(int) var cell_size = 16
export(int) var num_bounces = 3
export(int) var num_breaths = 2
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
var grid_top_left = Vector2(0, 16)

var move_direction = right
var last_direction = move_direction

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

func get_grid_width():
    return num_cols * cell_size + (num_cols - 1) * cell_spacing

func get_grid_height():
    return num_rows * cell_size + (num_rows - 1) * cell_spacing

func get_grid_center():
    var grid_center = grid_top_left
    grid_center.x += floor(get_grid_width() / 2)
    grid_center.y += floor(get_grid_height() / 2)
    return grid_center

func get_cell_center(grid_pos):
    var cell_center = Vector2()
    cell_center.x = grid_pos.y * cell_size + grid_pos.y * cell_spacing
    cell_center.x += floor(cell_size / 2)
    cell_center.y = grid_pos.x * cell_size + grid_pos.x * cell_spacing
    cell_center.y += floor(cell_size / 2)
    cell_center += grid_top_left
    return cell_center

func _init_grid_positions():
    for i in range(num_rows):
        for j in range(num_cols):
            grid[i][j].position = get_cell_center(grid[i][j].grid_position)

func grid_distance_to_right_edge():
    return screen_size.x - (grid_top_left.x + get_grid_width())

func grid_distance_to_left_edge():
    return grid_top_left.x

func update_grid_positions(delta):
    var move_amount = move_rate * delta
    if move_direction == right:
        if bounce_count == num_bounces and get_grid_center().x + move_amount > floor(screen_size.x / 2):
            bounce_count = 0
            last_direction = move_direction
            move_direction = breathing_out
            move_amount = floor(screen_size.x / 2) - get_grid_center().x
        elif grid_distance_to_right_edge() < move_amount:
            move_amount = grid_distance_to_right_edge()
            move_direction = left
            bounce_count += 1
    elif move_direction == left:
        move_amount *= -1
        if bounce_count == num_bounces and get_grid_center().x + move_amount < floor(screen_size.x / 2):
            bounce_count = 0
            last_direction = move_direction
            move_direction = breathing_out
            move_amount = floor(screen_size.x / 2) - get_grid_center().x
        elif grid_distance_to_left_edge() < -move_amount:
            move_amount = -grid_distance_to_left_edge()
            move_direction = right
            bounce_count += 1
    elif move_direction == breathing_out:
        move_amount *= -1
        if grid_distance_to_left_edge() < -move_amount:
            move_amount = -grid_distance_to_left_edge()
            move_direction = breathing_in
        elif grid_distance_to_right_edge() < -move_amount:
            move_amount = -grid_distance_to_right_edge()
            move_direction = breathing_in
        cell_spacing += -move_amount / floor((num_cols - 1) / 2)
    elif move_direction == breathing_in:
        var cell_spacing_change = -(move_amount / floor((num_cols - 1) / 2))
        if cell_spacing + cell_spacing_change < min_cell_spacing:
            cell_spacing = min_cell_spacing
            move_amount = cell_spacing - min_cell_spacing
            move_direction = breathing_out
            if breath_count == num_breaths:
                breath_count = 0
                move_direction = right if last_direction == left else left
            else:
                breath_count += 1
        cell_spacing += cell_spacing_change
    grid_top_left.x += move_amount
    for row in grid:
        for cell in row:
            cell.position = get_cell_center(cell.grid_position)

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
        draw_rect(
            Rect2(get_grid_center().x - 8, get_grid_center().y - 8, cell_size, cell_size),
            Color('#ff0000')
           )
