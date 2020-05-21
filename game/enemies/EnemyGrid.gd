extends Node2D

export(int) var num_rows = 6
export(int) var num_cols = 10

var screen_size

func _ready():
    screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
