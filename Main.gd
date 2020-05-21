extends Node

var screens = {
    'main-menu': preload("res://screens/MainMenu.tscn").instance(),
    'controls': preload("res://screens/ControlsScreen.tscn").instance(),
    'about': preload('res://screens/AboutScreen.tscn').instance(),
    'game': preload('res://game/Galaga.tscn').instance()
}

var current_screen = ""
var screen_stack = []

func connect_game_signals():
    screens['game'].connect("ship_flying", $Stars, "set_moving", [true])
    screens['game'].connect("ship_stopped", $Stars, "set_moving", [false])
    screens['game'].connect("quit_game", self, "quit_game")

func _ready():
    change_screen("main-menu")

func change_screen(screen):
    call_deferred("_change_screen_deferred", screen)

func _change_screen_deferred(screen):
    var next_screen = screen
    if next_screen == "go_back":
        var last_screen = screen_stack.pop_back()
        if last_screen != null:
            last_screen = 'main-menu'
        next_screen = last_screen
    else:
        if current_screen != "" and current_screen != next_screen:
            screen_stack.append(current_screen)
    current_screen = next_screen
    var container = get_tree().get_current_scene().find_node("screen", false, false)
    if !container:
        var screen_node = Node.new()
        screen_node.set_name("screen")
        get_tree().get_current_scene().add_child(screen_node)
        container = screen_node
    for child in container.get_children():
        disconnect_navigation_buttons(child)
        container.remove_child(child)
    container.add_child(screens[current_screen])
    connect_navigation_buttons(screens[current_screen])
    if current_screen == "game":
        connect_game_signals()

func quit_game():
    change_screen("main-menu")
    screens['game'] = preload('res://game/Galaga.tscn').instance()

func connect_navigation_buttons(screen):
    if "navigation_buttons" in screen:
        for button in screen.navigation_buttons:
            screen.connect(button.signal_name, self, "change_screen", [button.screen_name])

func disconnect_navigation_buttons(screen):
    if "navigation_buttons" in screen:
        for button in screen.navigation_buttons:
            screen.disconnect(button.signal_name, self, "change_screen")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
