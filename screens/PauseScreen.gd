extends Screen

signal quit_pressed

func resume_game():
    get_tree().paused = false

func quit_game():
    get_tree().paused = false
    emit_signal("quit_pressed")

func _ready():
    $VBoxContainer/QuitButton.connect("pressed", self, "quit_game")
    $VBoxContainer/ResumeButton.connect("pressed", self, "resume_game")
