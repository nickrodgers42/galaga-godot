extends Screen

signal save_game
signal quit_game

var score = 0

func set_score(new_score):
    score = new_score
    $VBoxContainer/Score.text = str(new_score)

func save_game():
    if $VBoxContainer/NameField.text != "":
        emit_signal("save_game", score, $VBoxContainer/NameField.text)

func _ready():
    $VBoxContainer/SaveButton.connect("pressed", self, "save_game")
    $VBoxContainer/QuitButton.connect("pressed", self, "emit_signal", ["quit_game"])
