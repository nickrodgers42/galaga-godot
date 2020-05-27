extends Node2D

var enemy_size = 16
var half_enemy = floor(enemy_size / 2)
var screen_size
var screen_center
var curves
var paths
var path_follows = {}
var finished_queue = []
var enemy_p
var move_rate = 100

func _ready():
    screen_size = get_viewport_rect().size
    screen_center = Vector2(
        floor(screen_size.x / 2),
        floor(screen_size.y / 2)
    )
    curves = make_curves()
    paths = make_paths(curves)
    for path in paths.keys():
        add_child(paths[path])

func mirror_curve_horizontal(points):
    var new_points = []
    for point in points:
        new_points.append([
            Vector2(screen_center.x + (screen_center.x - point[0].x), point[0].y),
            Vector2(-point[1].x, point[1].y),
            Vector2(-point[2].x, point[2].y)
        ])
    return new_points

func make_curve(points):
    var curve = Curve2D.new()
    for point in points:
        curve.add_point(point[0], point[1], point[2])
    return curve

func make_curves():
    var curves_dict = {
        'bee-1': [
            [
                Vector2(screen_center.x + enemy_size, 0),
                Vector2(),
                Vector2(0, 2 * enemy_size)
            ],
            [
                Vector2(1.5 * enemy_size, screen_center.y),
                Vector2(0, -3 * enemy_size),
                Vector2(0, 3 * enemy_size)
            ],
            [
                Vector2(screen_center.x - 1.5 * enemy_size, screen_center.y),
                Vector2(0, 3 * enemy_size),
                Vector2()
            ]
        ],
        'boss-butterfly-1': [
            [
                Vector2(0, screen_size.y - 2.5 * enemy_size),
                Vector2(),
                Vector2(2 * enemy_size, 0)
            ],
            [
                Vector2(screen_center.x - 1.5 * enemy_size, screen_center.y * 1.25),
                Vector2(0, 2.5 * enemy_size),
                Vector2(0, -2.5 * enemy_size)
            ],
            [
                Vector2(1.5 * enemy_size, 1.25 * screen_center.y),
                Vector2(0, -2.5 * enemy_size),
                Vector2(0, 2.5 * enemy_size)
            ],
            [
                Vector2(screen_center.x - 1.5 * enemy_size, 1.25 * screen_center.y),
                Vector2(0, 2.5 * enemy_size),
                Vector2()
            ]
        ]
    }
    curves_dict['butterfly-1'] = mirror_curve_horizontal(curves_dict['bee-1'])
    curves_dict['butterfly-2'] = mirror_curve_horizontal(curves_dict['boss-butterfly-1'])
    for curve in curves_dict.keys():
        curves_dict[curve] = make_curve(curves_dict[curve])

    return curves_dict

func make_paths(curves_dict):
    var paths_dict = {}
    for curve in curves_dict.keys():
        paths_dict[curve] = make_path(curves_dict[curve])
    return paths_dict

func make_path(curve):
    var new_path = Path2D.new()
    new_path.set_curve(curve)
    return new_path

func make_path_follow(path_name):
    var path_follow = PathFollow2D.new()
    path_follow.loop = false
    return path_follow

func follow_path(enemy, path_name, offset=Vector2()):
    var path_follow = make_path_follow(path_name)
    path_follow.add_child(enemy)
    path_follow.h_offset = offset.x
    path_follow.v_offset = offset.y

    if path_follows.has(path_name):
        path_follows[path_name].append(path_follow)
    else:
        path_follows[path_name] = [path_follow]
    paths[path_name].add_child(path_follow)

func get_finished_queue():
    var queue = []
    for node in finished_queue:
        remove_child(node)
        queue.append(node)
    finished_queue.clear()
    return queue

func _process(delta):
    for path_name in path_follows.keys():
        for path_follow in path_follows[path_name]:
            path_follow.offset += delta * move_rate
            if path_follow.unit_offset == 1:
                for child in path_follow.get_children():
                    path_follow.remove_child(child)
                    add_child(child)
                    child.position = path_follow.position
                    finished_queue.append(child)
                    child.rotation = 0
                path_follow.queue_free()
                path_follows[path_name].erase(path_follow)
    update()

func _draw():
#    draw_polyline(curves['boss-butterfly-1'].get_baked_points(), Color('#ff0000'))
    pass
