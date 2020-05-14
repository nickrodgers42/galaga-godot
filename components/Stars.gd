extends Node2D

export(int) var num_stars = 100
export(bool) var moving = false setget set_moving
export(float) var move_rate = 0
export(float) var star_blink_rate = 1
export(Array, Color) var star_colors = [Color(1, 1, 1)]

var stars = []

class Star:
    var color = Color(1, 1, 1)
    var opacity = 1
    var position = Vector2()
    var increasing = true

func _ready():
    for _i in range(num_stars):
        var star = Star.new()
        star.position = Vector2(
            randi() % int(get_viewport_rect().size.x),
            randi() % int(get_viewport_rect().size.y)
        )
        star.color = star_colors[randi() % len(star_colors)]
        star.opacity = randf()
        star.increasing = bool(randi() % 2)
        stars.append(star)

func set_moving(move_val):
    moving = move_val

func _process(delta):
    for star in stars:
        if moving:
            star.position.y += move_rate * delta
            if star.position.y > get_viewport_rect().size.y:
                star.position.y -= get_viewport_rect().size.y
        if star.increasing:
            star.opacity += star_blink_rate * delta
            if star.opacity >= 1:
                star.opacity = 1
                star.increasing = false
        else:
            star.opacity -= star_blink_rate * delta
            if star.opacity <= 0:
                star.opacity = 0
                star.increasing = true
        star.color.a = star.opacity
    update()

func _draw():
    for star in stars:
        draw_rect(Rect2(star.position, Vector2(1, 1)), star.color)
