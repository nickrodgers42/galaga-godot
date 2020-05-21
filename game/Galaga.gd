extends Node2D

signal ship_flying
signal ship_stopped
signal quit_game

var stage = 1
var score = 0
var missiles = []
var screen_size
const PlayerMissile = preload('res://game/PlayerMissile.tscn')

func _ready():
    screen_size = get_viewport_rect().size
    $Player.connect("player_fire", self, "_fire_player_missile")
    $CanvasLayer/PauseOverlay/PauseScreen.connect('quit_pressed', self, "emit_signal", ["quit_game"])
    $Player.position.y = floor(screen_size.y - $Player.sprite_size.y * 1.5)
    $Player.position.x = floor(screen_size.x / 2)
    $Player.hide()
    $CoinInserted.connect("finished", self, "_start_game")
    $CoinInserted.play()

func _start_game():
    $HUD.set_stage_text("PLAYER 1")
    var theme_song_length = $ThemeSong.stream.get_length()
    
    var show_player_timer = Timer.new()
    show_player_timer.one_shot = true
    show_player_timer.connect("timeout", $Player, "show")
    show_player_timer.connect("timeout", $HUD, "set_badge_visible", [true])
    show_player_timer.connect("timeout", $HUD, "set_lives_visible", [true])
    add_child(show_player_timer)
    show_player_timer.start(theme_song_length / 2)
    
    var move_stars_timer = Timer.new()
    move_stars_timer.one_shot = true
    move_stars_timer.connect("timeout", self, "emit_signal", ["ship_flying"])
    move_stars_timer.connect("timeout", $HUD, "set_stage_text", ["STAGE 1"])
    add_child(move_stars_timer)
    move_stars_timer.start((theme_song_length / 2) + 1)
    
    var clear_text_timer = Timer.new()
    clear_text_timer.one_shot = true
    clear_text_timer.connect("timeout", $HUD, "clear_stage_text")
    add_child(clear_text_timer)
    
    $ThemeSong.connect("finished", $Player, "set_can_shoot", [true])
    $ThemeSong.connect("finished", $HUD, "set_stage_text", ["PLAYER 1\nSTAGE 1"])
    $ThemeSong.connect("finished", clear_text_timer, "start", [1])
    $ThemeSong.play()
    
func _fire_player_missile():
    if len(missiles) < 2 and $Player.can_shoot:
        $Shoot.play()
        var missile = PlayerMissile.instance()
        missile.position = $Player.position
        missile.position.y -= 8
        add_child(missile)
        missiles.append(missile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    for missile in missiles:
        if !is_instance_valid(missile):
            missiles.erase(missile)
