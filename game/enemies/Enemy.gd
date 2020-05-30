extends Area2D
class_name Enemy

enum {diving, formation}

var state = diving setget set_state

func get_position():
    if get_parent().get_class() == "PathFollow2D":
        return get_parent().position
    else:
        return position

var is_alive = true
var grid_position = Vector2()
var moving = true
var playing = false
var frame = 0
var num_escorts = 0

func get_class():
    return "Enemy"

func get_points():
    return 50

func set_state(state_str):
    if state_str == "diving":
        state = diving
    else:
        state = formation

func set_frame(frame_number):
    frame_number %= $AnimatedSprite.frames.get_frame_count("default")
    $AnimatedSprite.frame = frame_number

func _ready():
    $AnimatedSprite.playing = playing

func hit():
    is_alive = false
