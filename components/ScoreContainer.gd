extends HBoxContainer

func set_name(name):
    $Name.text = str(name)

func set_score(score):
    $Score.text = str(score)

func set_place(place):
    $Place.text = str(place)

func _ready():
    pass
