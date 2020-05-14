extends Label

export(bool) var showing = true
export(float) var blink_rate = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
    _show_or_hide_label()
    $BlinkTimer.connect("timeout", self, "_blink")
    $BlinkTimer.start(blink_rate)

func _show_or_hide_label():
    if showing:
        self.show()
    else:
        self.hide()

func _blink():
    showing = !showing
    _show_or_hide_label()
    $BlinkTimer.start(blink_rate)

#func _process(delta):
#    pass

