extends Node2D

signal ship_flying
signal ship_stopped
signal quit_game
signal game_over

var stage = 1
var score = 0
var high_score = 0
var player_missiles = []
var enemy_missiles = []
var screen_size
const PlayerMissile = preload('./PlayerMissile.tscn')
const EnemyMissile = preload('./EnemyMissile.tscn')
const EnemyExplosion = preload('./enemies/EnemyExplosion.tscn')
const PlayerExplosion = preload('./PlayerExplosion.tscn')

var shots_fired = 0
var shots_hit = 0

func _ready():
    screen_size = get_viewport_rect().size
    $Player.connect("player_fire", self, "_fire_player_missile")
    $Player.connect("area_entered", self, "_player_hit")
    $CanvasLayer/PauseOverlay/PauseScreen.connect('quit_pressed', self, "emit_signal", ["quit_game"])
    $Player.position.y = floor(screen_size.y - $Player.sprite_size.y * 1.5)
    $Player.position.x = floor(screen_size.x / 2)
    $Player.hide()
    $CoinInserted.connect("finished", self, "_start_game")
    $CoinInserted.play()
    $EnemySystem.connect("fire_enemy_missile", self, "_fire_enemy_missile")
    $EnemySystem.connect("stage_complete", self, "transition_stage")

func _player_hit(area_2d):
    if $Player.visible:
        if area_2d.get_class() == "Enemy":
            area_2d.is_alive = false
            kill_enemy(area_2d)
        elif area_2d.get_class() == "EnemyMissile":
            area_2d.queue_free()
        kill_player()

func kill_player():
    $PlayerKill.play()
    $Player.hide()
    $Player.num_lives -= 1
    var explosion = PlayerExplosion.instance()
    add_child(explosion)
    explosion.playing = true
    explosion.position = $Player.position
    $Player.position.x = screen_size.x / 2
    explosion.connect("animation_finished", explosion, "queue_free")
    $HUD.set_num_lives($Player.num_lives)

    var respawn_length = 5

    if $Player.num_lives > 0:
        var show_text_timer = Timer.new()
        show_text_timer.one_shot = true
        show_text_timer.connect("timeout", $HUD, "set_stage_text", ["READY"])
        add_child(show_text_timer)
        show_text_timer.start(respawn_length / 2)

    var respawn_timer = Timer.new()
    respawn_timer.one_shot = true
    respawn_timer.connect("timeout", $Player, "show")
    if $Player.num_lives == 0:
        respawn_timer.connect("timeout", self, "show_end_screen")
    else:
        respawn_timer.connect("timeout", $HUD, "clear_stage_text")
    respawn_timer.connect("timeout", respawn_timer, "queue_free")
    add_child(respawn_timer)
    respawn_timer.start(respawn_length)

func show_end_screen():
    $GameOver.play()
    remove_child($EnemySystem)
    var accuracy_str = "SHOTS FIRED: %d\n" % shots_fired
    accuracy_str += "SHOTS HIT: %d\n" % shots_hit
    if shots_fired == 0:
        shots_fired += 1
    accuracy_str += "ACCURACY: %.2f%%" % ((float(shots_hit) / float(shots_fired)) * 100)
    $HUD.set_stage_text(accuracy_str)
    $GameOver.connect("finished", $HUD, "clear_stage_text")
    $GameOver.connect("finished", self, "emit_signal", ["game_over", score])

func _start_game():
    $HUD.set_stage_text("PLAYER 1")
    $HUD.set_stage_badge(stage)
    var theme_song_length = $ThemeSong.stream.get_length()

    var show_player_timer = Timer.new()
    show_player_timer.one_shot = true
    show_player_timer.connect("timeout", $Player, "show")
    show_player_timer.connect("timeout", $HUD, "set_badge_visible", [true])
    show_player_timer.connect("timeout", $HUD, "set_lives_visible", [true])
    show_player_timer.connect("timeout", show_player_timer, "queue_free")

    add_child(show_player_timer)
    show_player_timer.start(theme_song_length / 2)

    var move_stars_timer = Timer.new()
    move_stars_timer.one_shot = true
    move_stars_timer.connect("timeout", self, "emit_signal", ["ship_flying"])
    move_stars_timer.connect("timeout", $HUD, "set_stage_text", ["STAGE %d" % stage])
    move_stars_timer.connect("timeout", move_stars_timer,"queue_free")
    add_child(move_stars_timer)
    move_stars_timer.start((theme_song_length / 2) + 1)

    var clear_text_timer = Timer.new()
    clear_text_timer.one_shot = true
    clear_text_timer.connect("timeout", $HUD, "clear_stage_text")
    clear_text_timer.connect("timeout", clear_text_timer, "queue_free")
    clear_text_timer.connect("timeout", $EnemySystem, "run_stage", [stage])
    add_child(clear_text_timer)

    $ThemeSong.connect("finished", $Player, "set_can_shoot", [true])
    $ThemeSong.connect("finished", $EnemySystem/EnemyGrid, "set_moving", [true])
    $ThemeSong.connect("finished", $HUD, "set_stage_text", ["PLAYER 1\nSTAGE %d" % stage])
    $ThemeSong.connect("finished", clear_text_timer, "start", [1])
    $ThemeSong.play()

func transition_stage():
    stage += 1
    $LevelStart.play()
    if stage % 3 == 0:
        $HUD.set_stage_text("CHALLENGING STAGE")
    else:
        $HUD.set_stage_text("STAGE %d" % stage)
    $HUD.set_stage_badge(stage)
    var transition_timer = Timer.new()
    transition_timer.one_shot = true
    transition_timer.connect("timeout", $HUD, "clear_stage_text")
    transition_timer.connect("timeout", $EnemySystem, "run_stage", [stage])
    transition_timer.connect("timeout", transition_timer, "queue_free")
    add_child(transition_timer)
    transition_timer.start($LevelStart.stream.get_length() + 1)

func _fire_player_missile():
    if len(player_missiles) < 2 and $Player.can_shoot and $Player.visible:
        $Shoot.play()
        var missile = PlayerMissile.instance()
        missile.position = $Player.position
        missile.position.y -= 8
        missile.connect("area_entered", self, "missile_hit", [missile])
        add_child(missile)
        player_missiles.append(missile)
        shots_fired += 1

func _fire_enemy_missile(enemy):
    var missile = EnemyMissile.instance()
    missile.position = enemy.position
    missile.screen_size = screen_size
    missile.shoot_towards_player($Player.position)
    missile.position.y -= 8
    add_child(missile)
    enemy_missiles.append(missile)


func place_explosion(pos):
    var explosion = EnemyExplosion.instance()
    explosion.position = pos
    explosion.connect("animation_finished", explosion, "queue_free")
    add_child(explosion)
    explosion.playing = true

func update_score(new_score):
    score = new_score
    $HUD.set_score(score)
    if score >= high_score:
        high_score = score
        $HUD.set_high_score(score)

func kill_enemy(enemy):
    enemy.is_alive = false
    $EnemyKill.play()
    update_score(score + enemy.get_points())
    place_explosion(enemy.get_position())

func missile_hit(area_2d, missile):
    if area_2d.get_class() == "Enemy":
        var enemy = area_2d
        player_missiles.erase(missile)
        missile.queue_free()
        enemy.hit()
        shots_hit += 1
        if !enemy.is_alive:
            kill_enemy(enemy)
        else:
            $EnemyHit.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    for missile in player_missiles:
        if !is_instance_valid(missile):
            player_missiles.erase(missile)
    for missile in enemy_missiles:
        if !is_instance_valid(missile):
            enemy_missiles.erase(missile)
