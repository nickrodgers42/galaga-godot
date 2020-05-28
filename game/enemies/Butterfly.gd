class_name Butterfly
extends Enemy

func get_score():
    if state == formation:
        return 80
    else:
        return 160

func _ready():
    pass
