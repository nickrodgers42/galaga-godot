extends Screen

signal back_pressed

const ScoreContainer = preload("res://components/ScoreContainer.tscn")

func load_high_scores():
    clear_vbox()
    var high_scores = File.new()
    var high_scores_dict = {"scores":[]}
    if high_scores.file_exists("user://highscores.save"):
        high_scores.open("user://highscores.save", File.READ)
        high_scores_dict = parse_json(high_scores.get_line())
    var high_scores_list = high_scores_dict["scores"]
    high_scores_list.sort_custom(self, "high_score_comparison")
    for i in range(min(5, len(high_scores_list) - 1), -1, -1):
        var container = ScoreContainer.instance()
        container.set_score(high_scores_list[i][0])
        container.set_name(high_scores_list[i][1])
        container.set_place("%d." % (i + 1))
        $VBoxContainer.add_child(container)
        $VBoxContainer.move_child(container, 0)

func high_score_comparison(a, b):
    var a_score = a[0]
    var a_name = a[1]
    var b_score = b[0]
    var b_name = b[1]
    if a_score > b_score:
        return true
    elif a_score < b_score:
        return false
    elif b_name > a_name:
        return false
    else:
        return true

func clear_vbox():
    var backButton = $VBoxContainer/BackButton
    for child in $VBoxContainer.get_children():
        $VBoxContainer.remove_child(child)
    $VBoxContainer.add_child(backButton)


func _ready():
    load_high_scores()
    navigation_buttons.append(NavigationButton.new($VBoxContainer/BackButton, 'back_pressed', 'go_back'))
    connect_button_signals()
