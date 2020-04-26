extends Control

class_name Screen

class NavigationButton:
    var button = Node.new()
    var signal_name = ""
    var screen_name = ""
    
    func _init(button, signal_name, screen_name):
        self.button = button
        self.signal_name = signal_name
        self.screen_name = screen_name

var navigation_buttons = []

func _ready():
    pass # Replace with function body.

func connect_navigation_buttons():
    for button in navigation_buttons:
        button.button.connect("pressed", self, "emit_signal", [button.signal_name])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
