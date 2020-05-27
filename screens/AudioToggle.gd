extends HBoxContainer
tool

export(String) var audio_bus = "Master"
export(bool) var is_audio_enabled = true setget set_audio

func set_audio(is_enabled):
    is_audio_enabled = is_enabled
    set_button(is_audio_enabled)
    set_audio_bus(is_audio_enabled)

func set_audio_bus(is_enabled):
    var bus_index = AudioServer.get_bus_index(audio_bus)
    AudioServer.set_bus_mute(bus_index, !is_enabled)

func toggle_audio():
    set_audio(!is_audio_enabled)

func set_button(is_enabled):
    if is_enabled:
        $Button.text = "ON"
    else:
        $Button.text = "OFF"

func _ready():
    set_button(!AudioServer.is_bus_mute(AudioServer.get_bus_index(audio_bus)))
    is_audio_enabled = !AudioServer.is_bus_mute(AudioServer.get_bus_index(audio_bus))
    $AudioToggleLabel.text = audio_bus
    $Button.connect("pressed", self, "toggle_audio")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
