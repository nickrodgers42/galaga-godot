extends Control

export var stage = 1
var screen_size

var badges = {
    1: preload('res://assets/images/indicator-1.png'),
    5: preload('res://assets/images/indicator-5.png'),
    10: preload('res://assets/images/indicator-10.png'),
    20: preload('res://assets/images/indicator-20.png'),
    30: preload('res://assets/images/indicator-30.png'),
    50: preload('res://assets/images/indicator-50.png')
}

func _ready():
    screen_size = get_viewport_rect().size

func _split_badges():
    var badges_to_use = []
    var current_val = 0
    for i in range(len(badges.keys()) - 1, -1, -1):
        var badge_val = badges.keys()[i]
        while stage - current_val >= badge_val:
            badges_to_use.append(badge_val)
            current_val += badge_val
    return badges_to_use

func _draw():
    var stage_badges = _split_badges()
    var x_position = screen_size.x
    for i in range(len(stage_badges) - 1, -1, -1):
        var current_badge = stage_badges[i]
        x_position -= badges[current_badge].get_width()
        draw_texture(badges[current_badge], Vector2(x_position, screen_size.y - badges[current_badge].get_height()))

func _process(delta):
    update()
