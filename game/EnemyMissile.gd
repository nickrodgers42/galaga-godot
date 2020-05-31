extends PlayerMissile
class_name EnemyMissile

func shoot_towards_player(player_pos):
    var angle_to_player = atan2(
        player_pos.y - position.y,
        player_pos.x - position.x
    )
    angle_to_player += PI
    angle_to_player = max((11 * PI) / 8, angle_to_player)
    angle_to_player = min((13 * PI) / 8, angle_to_player)
    move_direction = Vector2(-cos(angle_to_player), -sin(angle_to_player))

func get_class():
    return "EnemyMissile"
