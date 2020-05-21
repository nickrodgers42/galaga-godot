extends Control

func _ready():
    self.visible = false
    self.pause_mode = Node.PAUSE_MODE_PROCESS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("pause"):
        get_tree().paused = !get_tree().paused
    self.visible = get_tree().paused
