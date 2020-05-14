extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Dictionary) var controls = {
    'Move Left': KEY_LEFT,
    'Move Right': KEY_RIGHT,
    'Fire': KEY_SPACE,
    'Pause': KEY_ESCAPE
   }


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
