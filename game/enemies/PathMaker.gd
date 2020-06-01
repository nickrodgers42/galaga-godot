extends Node2D

var enemy_size = 16
var half_enemy = floor(enemy_size / 2)
var screen_size
var screen_center
var curves
var curve_points = {}
var paths
var path_follows = {}
var finished_queue = []
var diving_paths = [
    "bee-dive-left-1",
    "bee-dive-right-1",
    "butterfly-dive-left-1",
    "butterfly-dive-right-1",
    "boss-dive-left-1",
    "boss-dive-right-1"
]

var challenge_paths = [
    "bee-challenge-left-1",
    "bee-challenge-right-1",
    "boss-butterfly-challenge-1",
    "bee-challenge-1"
]

var path_continues = {
    "butterfly-dive-left-1" : "return-left-1",
    "butterfly-dive-right-1": "return-right-1",
    "boss-dive-left-1": "return-left-1",
    "boss-dive-right-1": "return-right-1"
}

var diving_path_follows = {}

var enemy_p
var move_rate = 100

func _ready():
    screen_size = get_viewport_rect().size
    screen_center = Vector2(
        floor(screen_size.x / 2),
        floor(screen_size.y / 2)
    )
    curve_points = CurvePoints.make_curve_points(screen_size, enemy_size)
    curves = make_curves(curve_points)
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

func flip_curve_horizontal(points):
    var new_points = []
    for point in points:
        new_points.append([
            Vector2(-point[0].x, point[0].y),
            Vector2(-point[1].x, point[1].y),
            Vector2(-point[2].x, point[2].y)
        ])
    return new_points

func make_curve(points, offset=Vector2()):
    var curve = Curve2D.new()
    for point in points:
        curve.add_point(point[0] + offset, point[1], point[2])
    return curve

func make_curves(points):
    var curves_dict = {}
    for curve in points.keys():
        curves_dict[curve] = make_curve(points[curve])
    return curves_dict

func make_paths(curves_dict):
    var paths_dict = {}
    for curve in curves_dict.keys():
        if not diving_paths.has(curve):
            paths_dict[curve] = make_path(curves_dict[curve])
    return paths_dict

func make_path(curve):
    var new_path = Path2D.new()
    new_path.set_curve(curve)
    return new_path

func make_path_follow():
    var path_follow = PathFollow2D.new()
    path_follow.loop = false
    return path_follow

func follow_path(enemy, path_name, offset=Vector2()):
    var path_follow = make_path_follow()
    path_follow.add_child(enemy)
    path_follow.h_offset = offset.x
    path_follow.v_offset = offset.y
    enemy.rotation = PI / 2
    if diving_paths.has(path_name):
        var curve = make_curve(curve_points[path_name], enemy.position)
        enemy.position = Vector2()
        var path = make_path(curve)
        add_child(path)
        path.add_child(path_follow)
        if diving_path_follows.has(path_name):
            diving_path_follows[path_name].append(path_follow)
        else:
            diving_path_follows[path_name] = [path_follow]
    else:
        if path_follows.has(path_name):
            path_follows[path_name].append(path_follow)
        else:
            path_follows[path_name] = [path_follow]
        paths[path_name].add_child(path_follow)
    return path_follow

func get_finished_queue():
    var queue = []
    for node in finished_queue:
        if is_instance_valid(node):
            remove_child(node)
            queue.append(node)
    finished_queue.clear()
    return queue

func update_path_follows(delta, path_follow_dict, remove_parent=false):
    for path_name in path_follow_dict.keys():
        for path_follow in path_follow_dict[path_name]:
            path_follow.offset += delta * move_rate
            if path_follow.unit_offset == 1:
                for child in path_follow.get_children():
                    path_follow.remove_child(child)
                    if challenge_paths.has(path_name):
                        child.is_alive = false
                    elif path_continues.has(path_name):
                        follow_path(child, path_continues[path_name])
                    else:
                        add_child(child)
                        child.position = path_follow.position
                        child.rotation = 0
                        finished_queue.append(child)
                    path_follow_dict[path_name].erase(path_follow)
                    if remove_parent:
                        path_follow.get_parent().queue_free()
                    else:
                        path_follow.queue_free()

func _process(delta):
    update_path_follows(delta, path_follows)
    update_path_follows(delta, diving_path_follows, true)
    update()

func _draw():
#    draw_polyline(curves['bee-dive-left-test'].get_baked_points(), Color('#ff0000'))
    pass
