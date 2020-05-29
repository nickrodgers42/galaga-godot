extends Node2D

const Bee = preload('./Bee.tscn')
const Butterfly = preload('./Butterfly.tscn')
const Boss = preload('./Boss.tscn')

export(int) var move_rate = 100

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
var spawn_timer_length = 0.2
var frame_timer_length = 0.5
var bee_dive_timer_length = 8
var phase = 0
var current_stage = 0
var current_phase = 0
var enemies = []
var global_frame = 0

class Wave:
    var enemy_type
    var num_enemies
    var path_name
    var follow_offset
    var grid_positions

    func _init(enemy_type_str, num, path, offset, positions):
        enemy_type = enemy_type_str
        num_enemies = num
        path_name = path
        follow_offset = offset
        grid_positions = positions

var stages = {
    1: [[
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
        ]]
}

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
    if enemy_str == "bee":
        var bee = $EnemyGrid.get_open_enemy(Vector2(4,0), Vector2(5,9))
        if bee != null:
            var side = get_left_or_right(bee.grid_position)
            $PathMaker.follow_path(bee, 'bee-dive-%s-1' % side)

func run_stage(stage_number):
    current_stage = stage_number
    current_phase = 0
    next_phase()
    phase_timer.start(phase_timer_length)

func next_phase():
    current_phase += 1
    if current_phase > len(stages[current_stage]):
        phase_timer.stop()
        bee_dive_timer.start(bee_dive_timer_length)
    else:
        spawn_timer.start(spawn_timer_length)

func update_frame():
    global_frame += 1
    global_frame %= 2

func spawn_enemy():
    var phase_enemies_remaining = false
    for wave in stages[current_stage][current_phase - 1]:
        if len(wave.grid_positions) != 0:
            phase_enemies_remaining = true
        var grid_position = wave.grid_positions.pop_front()
        if grid_position != null:
            var enemy = null
            if wave.enemy_type == "Bee":
                enemy = Bee.instance()
            elif wave.enemy_type == "Butterfly":
                enemy = Butterfly.instance()
            elif wave.enemy_type == "Boss-Butterfly":
                if len(wave.grid_positions) % 2 != 0:
                    enemy = Boss.instance()
                else:
                    enemy = Butterfly.instance()
            enemy.moving = true
            enemy.grid_position = grid_position
            enemies.append(enemy)
            $PathMaker.follow_path(enemy, wave.path_name, wave.follow_offset)
    if !phase_enemies_remaining:
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
