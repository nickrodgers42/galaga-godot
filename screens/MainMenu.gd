extends Control

signal new_game_pressed
signal controls_pressed
signal high_scores_pressed
signal about_pressed

class NavigationButton:
    var button = Node.new()
    var signal_name = ""
    var screen_name = ""
    
    func _init(button, signal_name, screen_name):
        self.button = button
        self.signal_name = signal_name
        self.screen_name = screen_name

var navigation_buttons = []

# Called when the node enters the scene tree for the first time.
func _ready():
    navigation_buttons.append(NavigationButton.new($VBoxContainer/ControlsButton, "controls_pressed", "controls"))
    for button in navigation_buttons:
        button.button.connect("pressed", self, "emit_signal", [button.signal_name])
    
#func Controls():
#    emit_signal("controls_pressed")
#    print('signal emitted')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
