class_name Screen
extends Control


class NavigationButton:
    var button = Node.new()
    var signal_name = ""
    var screen_name = ""

    func _init(_button, _signal_name, _screen_name):
        self.button = _button
        self.signal_name = _signal_name
        self.screen_name = _screen_name

var navigation_buttons = []

func _ready():
    pass # Replace with function body.

func connect_button_signals():
    for button in navigation_buttons:
        button.button.connect("pressed", self, "emit_signal", [button.signal_name])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
