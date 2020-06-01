extends Node

var screen_size = Vector2()
var screen_center = Vector2()
var enemy_size = 0

func _set_screen_size(screen):
    screen_size = screen
    screen_center = Vector2(
        floor(screen_size.x / 2),
        floor(screen_size.y / 2)
    )

func _mirror_curve_horizontal(points):
    var new_points = []
    for point in points:
        new_points.append([
            Vector2(screen_center.x + (screen_center.x - point[0].x), point[0].y),
            Vector2(-point[1].x, point[1].y),
            Vector2(-point[2].x, point[2].y)
        ])
    return new_points

func _flip_curve_horizontal(points):
    var new_points = []
    for point in points:
        new_points.append([
            Vector2(-point[0].x, point[0].y),
            Vector2(-point[1].x, point[1].y),
            Vector2(-point[2].x, point[2].y)
        ])
    return new_points

func make_curve_points(screen, enemy):
    _set_screen_size(screen)
    enemy_size = enemy
    var curve_points = {
        'bee-1': [
            [
                Vector2(screen_center.x + enemy_size, 0),
                Vector2(),
                Vector2(0, 2 * enemy_size)
            ],
            [
                Vector2(1.5 * enemy_size, 1.25 * screen_center.y),
                Vector2(0, -3 * enemy_size),
                Vector2(0, 3 * enemy_size)
            ],
            [
                Vector2(screen_center.x - 1.5 * enemy_size, 1.25 * screen_center.y),
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
        ],
        'bee-dive-left-1': [
            [
                Vector2(0, 0),
                Vector2(),
                Vector2(0, -enemy_size)
            ],
            [
                Vector2(-1.5 * enemy_size, 0),
                Vector2(0, -enemy_size),
                Vector2(0, enemy_size)
            ],
            [
                Vector2(screen_center.x, 2 * enemy_size),
                Vector2(0, -enemy_size),
                Vector2(0, enemy_size)
            ],
            [
                Vector2(screen_center.x,  0.5 * screen_size.y - 1.5 * enemy_size),
                Vector2(0, -4 * enemy_size),
                Vector2(0, 4 * enemy_size)
            ],
            [
                Vector2(0, 0.5 * screen_size.y - 1.5 * enemy_size),
                Vector2(0, 4 * enemy_size),
                Vector2()
            ]
        ],
        'butterfly-dive-left-1': [
            [
                Vector2(0, 0),
                Vector2(),
                Vector2(0, -enemy_size)
            ],
            [
                Vector2(-1.5 * enemy_size, 0),
                Vector2(0, -enemy_size),
                Vector2(0, enemy_size)
            ],
            [
                Vector2(screen_center.x - 3 * enemy_size, 2 * enemy_size),
                Vector2(0, -2 * enemy_size),
                Vector2(0, 2 * enemy_size)
            ],
            [
                Vector2(-2 * enemy_size, screen_center.y - 2 * enemy_size),
                Vector2(0, -4 * enemy_size),
                Vector2(0, 4 * enemy_size)
            ],
            [
                Vector2(4 * enemy_size, 0.85 * screen_size.y),
                Vector2(0, -4 * enemy_size),
                Vector2(0, 4 * enemy_size)
            ]
        ],
        'return-left-1': [
            [
                Vector2(0.25 * screen_size.x, 0),
                Vector2(),
                Vector2()
            ],
            [
                Vector2(0.25 * screen_size.x - enemy_size, 0),
                Vector2(enemy_size, 0),
                Vector2()
            ]
        ],
        'boss-dive-left-1': [
            [
                Vector2(0, 0),
                Vector2(),
                Vector2(0, -enemy_size)
            ],
            [
                Vector2(-1.5 * enemy_size, 0),
                Vector2(0, -enemy_size),
                Vector2(0, enemy_size)
            ],
            [
                Vector2(0, 0.5 * screen_center.y),
                Vector2(0, -2.5 * enemy_size),
                Vector2(0, 2.5 * enemy_size)
            ],
            [
                Vector2(0.5 * screen_center.x, 0.5 * screen_center.y),
                Vector2(0, 2.5 * enemy_size),
                Vector2(0, -2.5 * enemy_size)
            ],
            [
                Vector2(0, 0.5 * screen_center.y),
                Vector2(0, -2.5 * enemy_size),
                Vector2(0, 2.5 * enemy_size)
            ],
            [
                Vector2(0.5 * screen_center.x, .9 * screen_size.y),
                Vector2(0, -4 * enemy_size),
                Vector2()
            ]
        ],
        'bee-challenge-left-1': [
            [
                Vector2(screen_center.x + 1.5 * enemy_size, 0),
                Vector2(),
                Vector2(0, 1.5 * enemy_size)
            ],
            [
                Vector2(screen_center.x - 1.5 * enemy_size, 0.75 * screen_size.y),
                Vector2(enemy_size, -2 * enemy_size),
                Vector2(-enemy_size, 2 * enemy_size)
            ],
            [
                Vector2(1.5 * enemy_size, 0.75 * screen_size.y),
                Vector2(0, 3 * enemy_size),
                Vector2(0, -3 * enemy_size)
            ],
            [
                Vector2(screen_size.x, screen_center.y - 2.5 * enemy_size),
                Vector2(-2 * enemy_size, 0),
                Vector2()
            ]
        ],
        'boss-butterfly-challenge-1': [
            [
                Vector2(0, screen_size.y - 2.5 * enemy_size),
                Vector2(),
                Vector2(2 * enemy_size, 0)
            ],
            [
                Vector2(0.75 * screen_size.x, screen_center.y),
                Vector2(0, 2 * enemy_size),
                Vector2(0, -2 * enemy_size)
            ],
            [
                Vector2(0.75 * screen_size.x, 0.25 * screen_size.y),
                Vector2(0, 2 * enemy_size),
                Vector2(0, -2 * enemy_size)
            ],
            [
                Vector2(0.75 * screen_size.x - 1.5 * enemy_size, 0.25 * screen_size.y),
                Vector2(0, -2 * enemy_size),
                Vector2(0, 2 * enemy_size)
            ],
            [
                Vector2(0.75 * screen_size.x - 1.5 * enemy_size, screen_center.y),
                Vector2(0, -enemy_size),
                Vector2(0, enemy_size)
            ],
            [
                Vector2(screen_size.x, 0.25 * screen_size.y - enemy_size),
                Vector2(0, 2 * enemy_size),
                Vector2()
            ]
        ],
    }
    curve_points['butterfly-1'] = _mirror_curve_horizontal(curve_points['bee-1'])
    curve_points['butterfly-2'] = _mirror_curve_horizontal(curve_points['boss-butterfly-1'])
    curve_points['bee-dive-right-1'] = _flip_curve_horizontal(curve_points['bee-dive-left-1'])
    curve_points['butterfly-dive-right-1'] = _flip_curve_horizontal(curve_points['butterfly-dive-left-1'])
    curve_points['boss-dive-right-1'] = _flip_curve_horizontal(curve_points['boss-dive-left-1'])
    curve_points['return-right-1'] = _mirror_curve_horizontal(curve_points['return-left-1'])
    curve_points['bee-challenge-right-1'] = _mirror_curve_horizontal(curve_points['bee-challenge-left-1'])
    curve_points['bee-challenge-1'] = _mirror_curve_horizontal(curve_points['boss-butterfly-challenge-1'])
    curve_points['bee-dive-left-test'] = []
    var offset = Vector2()
    for point in curve_points['boss-butterfly-challenge-1']:
        curve_points['bee-dive-left-test'].append([point[0] + offset, point[1], point[2]])
    return curve_points

func _ready():
    pass
