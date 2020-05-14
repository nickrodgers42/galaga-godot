class_name PlayerMissile
extends Area2D

export(int) var move_rate = 150

func _ready():
    pass # Replace with function body.

func _process(delta):
    position.y -= move_rate * delta
    if position.y < 0:
        queue_free()
