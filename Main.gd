extends Node

var screens = {
    'main-menu': preload("res://screens/MainMenu.tscn").instance(),
    'high-scores': preload("res://screens/HighScoresScreen.tscn").instance(),
    'controls': preload("res://screens/ControlsScreen.tscn").instance(),
    'about': preload('res://screens/AboutScreen.tscn').instance(),
    'game': preload('res://game/Galaga.tscn').instance(),
    'game-over': preload('res://screens/GameOverScreen.tscn').instance()
}

var current_screen = ""
var screen_stack = []

func save_score(score, player_name):
    var high_scores = File.new()
    var high_scores_dict = {"scores":[]}
    if high_scores.file_exists("user://highscores.save"):
        high_scores.open("user://highscores.save", File.READ_WRITE)
        high_scores_dict = parse_json(high_scores.get_line())
    else:
        high_scores.open("user://highscores.save", File.WRITE)
    if high_scores_dict != null and typeof(high_scores_dict) == TYPE_DICTIONARY \
        and high_scores_dict.has("scores"):
        high_scores_dict["scores"].append([score, player_name])
    else:
        high_scores_dict = {}
        high_scores_dict["scores"] = [[score, player_name]]
    high_scores.open("user://highscores.save", File.WRITE)
    high_scores.store_line(to_json(high_scores_dict))
    quit_game()

func connect_game_over_signals():
    screens['game-over'].connect("save_game", self, "save_score")
    screens['game-over'].connect("quit_game", self, "quit_game")

func connect_game_signals():
    screens['game'].connect("ship_flying", $Stars, "set_moving", [true])
    screens['game'].connect("ship_stopped", $Stars, "set_moving", [false])
    screens['game'].connect("quit_game", self, "quit_game")
    screens['game'].connect("game_over", self, "game_over")

func game_over(score):
    screens['game-over'].set_score(score)
    change_screen("game-over")
    connect_game_over_signals()

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
    if current_screen == "high-scores":
        screens["high-scores"].load_high_scores()

func quit_game():
    change_screen("main-menu")
    $Stars.set_moving(false)
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
