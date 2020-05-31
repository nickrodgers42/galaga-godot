extends Control

var texture = preload('res://assets/images/life.png')

export(int) var num_lives = 3
var screen_size

func _ready():
    screen_size = get_viewport_rect().size

func _draw():
    for i in range(num_lives - 1):
        draw_texture(texture, Vector2(i * texture.get_width(), screen_size.y - texture.get_height()))

func _process(delta):
    update()
