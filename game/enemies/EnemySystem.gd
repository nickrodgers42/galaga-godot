extends Node2D

signal fire_enemy_missile
signal stage_complete

const Bee = preload('./Bee.tscn')
const Butterfly = preload('./Butterfly.tscn')
const Boss = preload('./Boss.tscn')

export(int) var move_rate = 150

var frame_timer = Timer.new()
var phase_timer = Timer.new()
var spawn_timer = Timer.new()
var bee_dive_timer = Timer.new()
var butterfly_dive_timer = Timer.new()
var boss_dive_timer = Timer.new()
var timers = [
    frame_timer,
    phase_timer,
    spawn_timer,
    bee_dive_timer,
    butterfly_dive_timer,
    boss_dive_timer
]

var phase_timer_length = 5
var spawn_timer_length = 0.15
var frame_timer_length = 0.5
var bee_dive_timer_length = 8
var butterfly_dive_timer_length = 12
var boss_dive_timer_length = 16
var phase = 0
var current_stage = 0
var current_phase = 0
var enemies = []
var missile_timers = []
var missile_timer_delay = 0.5
var missile_spacing_delay = 0.15
var global_frame = 0
var phase_enemies_remaining = 0
var enemy_size = 16
var phase_enemies_to_shoot = 0

var all_enemies_spawned = false
var stage_complete = false

class Wave:
    var enemy_type
    var num_enemies
    var path_name
    var follow_offset
    var grid_positions
    var current_grid_position = 0

    func get_next_grid_position():
        var grid_pos = grid_positions[current_grid_position]
        current_grid_position += 1
        current_grid_position %= num_enemies
        return grid_pos

    func _init(enemy_type_str, num, path, offset, positions):
        enemy_type = enemy_type_str
        num_enemies = num
        path_name = path
        follow_offset = offset
        grid_positions = positions

var stages = [
    [[
        Wave.new("Bee", 4, "bee-1", Vector2(), [
            Vector2(4,4), Vector2(4,5), Vector2(5,4), Vector2(5,5)
        ]),
        Wave.new("Butterfly", 4, "butterfly-1", Vector2(), [
            Vector2(2,4), Vector2(2,5), Vector2(3,4), Vector2(3,5)
        ])
    ],
    [
        Wave.new("Boss-Butterfly", 8, "boss-butterfly-1", Vector2(), [
            Vector2(1,3), Vector2(2,3), Vector2(1,4), Vector2(3,3),
            Vector2(1,5), Vector2(2,6), Vector2(1,6), Vector2(3,6)
        ])
    ],
    [
        Wave.new("Butterfly", 8, "butterfly-2", Vector2(), [
            Vector2(2,7), Vector2(2,8), Vector2(3,7), Vector2(3,8),
            Vector2(2,1), Vector2(2,2), Vector2(3,1), Vector2(3,2),
        ])
    ],
    [
        Wave.new("Bee", 8, "bee-1", Vector2(), [
            Vector2(4,6), Vector2(4,7), Vector2(5,6), Vector2(5,7),
            Vector2(4,2), Vector2(4,3), Vector2(5,2), Vector2(5,3)
        ])
    ],
    [
        Wave.new("Bee", 8, "butterfly-1", Vector2(), [
            Vector2(4,0), Vector2(4,1), Vector2(5,0), Vector2(5,1),
            Vector2(4,8), Vector2(4,9), Vector2(5,8), Vector2(5,9)
        ])
    ]],
    [[
        Wave.new("Butterfly", 4, "bee-1", Vector2(), [
            Vector2(2,4), Vector2(2,5), Vector2(3,4), Vector2(3,5)
        ]),
        Wave.new("Bee", 4, "butterfly-1", Vector2(), [
            Vector2(4,4), Vector2(4,5), Vector2(5,4), Vector2(5,5)
        ])
    ],
    [
        Wave.new("Boss", 4, "boss-butterfly-1", Vector2(0, -enemy_size / 2), [
            Vector2(1,3), Vector2(1,4), Vector2(1,5), Vector2(1,6)
        ]),
        Wave.new("Butterfly", 4, "boss-butterfly-1", Vector2(0, enemy_size / 2), [
            Vector2(2,3), Vector2(3,3), Vector2(2,6), Vector2(3,6)
        ])
    ],
    [
        Wave.new("Butterfly", 4, "butterfly-2", Vector2(0, -enemy_size / 2), [
            Vector2(2,1), Vector2(2,2), Vector2(3,1), Vector2(3,2),
        ]),
        Wave.new("Butterfly", 4, "butterfly-2", Vector2(0, enemy_size / 2), [
            Vector2(2,7), Vector2(2,8), Vector2(3,7), Vector2(3,8),
        ])
    ],
    [
        Wave.new("Bee", 4, "bee-1", Vector2(0, -enemy_size / 2), [
            Vector2(4,2), Vector2(4,3), Vector2(5,2), Vector2(5,3)
        ]),
        Wave.new("Bee", 4, "bee-1", Vector2(0, enemy_size / 2), [
            Vector2(4,6), Vector2(4,7), Vector2(5,6), Vector2(5,7),
        ])
    ],
    [
        Wave.new("Bee", 4, "butterfly-1", Vector2(0, -enemy_size / 2), [
            Vector2(4,0), Vector2(4,1), Vector2(5,0), Vector2(5,1),
        ]),
        Wave.new("Bee", 4, "butterfly-1", Vector2(0, enemy_size / 2), [
            Vector2(4,8), Vector2(4,9), Vector2(5,8), Vector2(5,9)
        ])
    ]],
    [[
        Wave.new("Bee", 4, "bee-challenge-left-1", Vector2(), [
            Vector2(),Vector2(),Vector2(),Vector2(),
        ]),
        Wave.new("Bee", 4, "bee-challenge-right-1", Vector2(), [
            Vector2(),Vector2(),Vector2(),Vector2(),
        ])
    ],
    [
        Wave.new("Boss-Butterfly", 8, "boss-butterfly-challenge-1", Vector2(), [
            Vector2(),Vector2(),Vector2(),Vector2(),
            Vector2(),Vector2(),Vector2(),Vector2()
        ])
    ],
    [
        Wave.new("Bee", 8, "bee-challenge-1", Vector2(), [
            Vector2(),Vector2(),Vector2(),Vector2(),
            Vector2(),Vector2(),Vector2(),Vector2()
        ])
    ],
    [
        Wave.new("Bee", 8, "bee-challenge-left-1", Vector2(), [
            Vector2(),Vector2(),Vector2(),Vector2(),
            Vector2(),Vector2(),Vector2(),Vector2()
        ]),
    ],
    [
        Wave.new("Bee", 8, "bee-challenge-right-1", Vector2(), [
            Vector2(),Vector2(),Vector2(),Vector2(),
            Vector2(),Vector2(),Vector2(),Vector2()
        ]),
    ]]
]

func _ready():
    $PathMaker.move_rate = move_rate
    $EnemyGrid.enemy_move_rate = move_rate

    for timer in timers:
        add_child(timer)

    frame_timer.connect("timeout", self, "update_frame")

    frame_timer.start(frame_timer_length)
    phase_timer.connect("timeout", self, "next_phase")
    spawn_timer.connect("timeout", self, "spawn_enemy")

    bee_dive_timer.connect("timeout", self, "enemy_dive", ["bee"])
    butterfly_dive_timer.connect("timeout", self, "enemy_dive", ["butterfly"])
    boss_dive_timer.connect("timeout", self, "enemy_dive", ["boss"])

func get_left_or_right(grid_pos):
    if grid_pos.y < $EnemyGrid.num_cols / 2:
        return "left"
    return "right"

func enemy_dive(enemy_str):
    var enemy = null
    var path_follow = null
    if enemy_str == "bee":
        enemy = $EnemyGrid.get_open_enemy(Vector2(4,0), Vector2(5,9))
        if enemy != null:
            var side = get_left_or_right(enemy.grid_position)
            path_follow = $PathMaker.follow_path(enemy, 'bee-dive-%s-1' % side)
    elif enemy_str == "butterfly":
        enemy = $EnemyGrid.get_open_enemy(Vector2(2, 0), Vector2(3, 9))
        if enemy != null:
            var side = get_left_or_right(enemy.grid_position)
            path_follow = $PathMaker.follow_path(enemy, 'butterfly-dive-%s-1' % side)
    elif enemy_str == "boss":
        enemy = $EnemyGrid.get_open_enemy(Vector2(1,0), Vector2(1,9))
        if enemy!= null:
            var escorts = $EnemyGrid.get_escorts(enemy.grid_position)
            var side = get_left_or_right(enemy.grid_position)
            enemy.num_escorts = len(escorts)
            path_follow = $PathMaker.follow_path(enemy, "boss-dive-%s-1" % side)
            for escort in escorts:
                $PathMaker.follow_path(escort, "boss-dive-%s-1" % side)
    if enemy != null:
        $EnemyIncoming.play()
        set_missile_timers(enemy, path_follow)

func emit_missile_signal(enemy, path_follow=null):
    if is_instance_valid(enemy):
        if path_follow != null:
            emit_signal("fire_enemy_missile", path_follow)
        else:
            emit_signal("fire_enemy_missile", enemy)

func set_missile_timers(enemy, path_follow=null):
    for i in range(2):
        var timer = Timer.new()
        add_child(timer)
        if path_follow != null:
            timer.connect("timeout", self, "emit_missile_signal", [enemy, path_follow])
        else:
            timer.connect("timeout", self, "emit_signal", ["fire_enemy_missile", enemy])
        timer.one_shot = true
        timer.start(missile_timer_delay + i * missile_spacing_delay)
        missile_timers.append(timer)

func run_stage(stage_number):
    current_stage = int(abs(stage_number - 1)) % len(stages)
    current_phase = 0
    next_phase()
    phase_timer.start(phase_timer_length)
    all_enemies_spawned = false
    stage_complete = false

func next_phase():
    current_phase += 1
    if current_phase > len(stages[current_stage]):
        phase_timer.stop()
        all_enemies_spawned = true
        bee_dive_timer.start(bee_dive_timer_length)
        butterfly_dive_timer.start(butterfly_dive_timer_length)
        boss_dive_timer.start(boss_dive_timer_length)
    else:
        for wave in stages[current_stage][current_phase - 1]:
            phase_enemies_remaining += wave.num_enemies
        phase_enemies_to_shoot = len(stages[current_stage][current_phase - 1])
        spawn_timer.start(spawn_timer_length)

func update_frame():
    global_frame += 1
    global_frame %= 2

func spawn_enemy():
    for wave in stages[current_stage][current_phase - 1]:
        if phase_enemies_remaining > 0:
            var grid_position = wave.get_next_grid_position()
            phase_enemies_remaining -= 1
            if grid_position != null:
                var enemy = null
                if wave.enemy_type == "Bee":
                    enemy = Bee.instance()
                elif wave.enemy_type == "Butterfly":
                    enemy = Butterfly.instance()
                elif wave.enemy_type == "Boss":
                    enemy = Boss.instance()
                elif wave.enemy_type == "Boss-Butterfly":
                    if phase_enemies_remaining % 2 != 0:
                        enemy = Boss.instance()
                    else:
                        enemy = Butterfly.instance()
                enemy.moving = true
                enemy.grid_position = grid_position
                enemies.append(enemy)
                var path_follow = $PathMaker.follow_path(enemy, wave.path_name, wave.follow_offset)
                if phase_enemies_to_shoot > 0 and current_stage == 1:
                    set_missile_timers(enemy, path_follow)
                    phase_enemies_to_shoot -= 1
    if phase_enemies_remaining <= 0:
        spawn_timer.stop()

func _process(_delta):
    if !$PathMaker.finished_queue.empty():
        var finished = $PathMaker.get_finished_queue()
        for enemy in finished:
            $EnemyGrid.move_into_grid(enemy)
    for enemy in enemies:
        enemy.set_frame(global_frame)
        if !enemy.is_alive:
            enemies.erase(enemy)
            enemy.queue_free()
    for timer in missile_timers:
        if timer.is_stopped():
            missile_timers.erase(timer)
            timer.queue_free()
    if !stage_complete and all_enemies_spawned and len(enemies) == 0:
        stage_complete = true
        emit_signal("stage_complete")
        bee_dive_timer.stop()
        butterfly_dive_timer.stop()
        boss_dive_timer.stop()
