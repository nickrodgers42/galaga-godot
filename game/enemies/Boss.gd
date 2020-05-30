class_name Boss
extends Enemy

var has_been_hit = false

func get_points():
    if state == formation:
        return 150
    elif state == diving and num_escorts == 0:
        return 400
    elif state == diving and num_escorts == 1:
        return 800
    elif state == diving and num_escorts == 2:
        return 1600

func hit():
    if has_been_hit:
        is_alive = false
    else:
        has_been_hit = true
        $AnimatedSprite.animation = "hit"

func _ready():
    pass
