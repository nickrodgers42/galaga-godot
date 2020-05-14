extends Screen

signal back_pressed

func _ready():
    navigation_buttons.append(
        NavigationButton.new($VBoxContainer/BackButton, "back_pressed", "go_back")
    )
    connect_button_signals()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
