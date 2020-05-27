extends Node2D

const Bee = preload('./Bee.tscn')
const Butterfly = preload('./Butterfly.tscn')
const Boss = preload('./Boss.tscn')

export(int) var move_rate = 100

var frame_timer = Timer.new()
var phase_timer = Timer.new()
var spawn_timer = Timer.new()
var phase_timer_length = 5
var spawn_timer_length = 0.2
var frame_timer_length = 0.5
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
           Wave.new("Bee", 8, "bee-1", Vector2(), [
                Vector2(4,0), Vector2(4,1), Vector2(5,0), Vector2(5,1),
                Vector2(4,8), Vector2(4,9), Vector2(5,8), Vector2(5,9)
           ])
        ]]
}

func _ready():
    $PathMaker.move_rate = move_rate
    $EnemyGrid.enemy_move_rate = move_rate

    frame_timer.connect("timeout", self, "update_frame")
    add_child(frame_timer)

    frame_timer.start(frame_timer_length)
    phase_timer.connect("timeout", self, "next_phase")
    spawn_timer.connect("timeout", self, "spawn_enemy")
    add_child(phase_timer)
    add_child(spawn_timer)
    run_stage(1)

func run_stage(stage_number):
    current_stage = stage_number
    current_phase = 0
    next_phase()
    phase_timer.start(phase_timer_length)

func next_phase():
    current_phase += 1
    if current_phase > len(stages[current_stage]):
        phase_timer.stop()
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
            enemy.rotation = PI / 2
            enemies.append(enemy)
            $PathMaker.follow_path(enemy, wave.path_name, wave.follow_offset)
    if !phase_enemies_remaining:
        spawn_timer.stop()

func _process(delta):
    if !$PathMaker.finished_queue.empty():
        var finished = $PathMaker.get_finished_queue()
        for enemy in finished:
            $EnemyGrid.move_into_grid(enemy)
    for enemy in enemies:
        enemy.set_frame(global_frame)
        if !enemy.is_alive:
            enemies.erase(enemy)
            enemy.queue_free()
