extends Screen

signal new_game_pressed
signal controls_pressed
signal high_scores_pressed
signal about_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
    navigation_buttons.append(
        NavigationButton.new($VBoxContainer/ControlsButton, "controls_pressed", "controls")
    )
    connect_button_signals()

#func Controls():
#    emit_signal("controls_pressed")
#    print('signal emitted')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
