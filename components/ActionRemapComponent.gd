extends HBoxContainer

export(String) var label_text = 'label'
export(String) var button_text = 'button'
export(String) var button_action = 'ui_up'

# Called when the node enters the scene tree for the first time.
func _ready():
    $Label.text = label_text
    $Button.text = button_text
    $Button.set_action(button_action)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
