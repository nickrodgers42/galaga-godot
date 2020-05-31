class_name PlayerMissile
extends Area2D

export(int) var move_rate = 150
var move_direction = Vector2(0, -1)
var screen_size

func get_class():
    return "PlayerMissile"

func _ready():
    screen_size = get_viewport_rect().size

func _is_off_screen():
    if position.x < 0 or position.x > screen_size.x \
        or position.y < 0 or position.y > screen_size.y:
            return true
    return false

func _process(delta):
    position.x += move_rate * delta * move_direction.x
    position.y += move_rate * delta * move_direction.y
    if _is_off_screen():
        queue_free()
