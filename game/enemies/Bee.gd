class_name Bee
extends Enemy

func get_points():
    if state == formation:
        return 50
    else:
        return 100

func _ready():
    pass
