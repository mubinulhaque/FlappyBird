extends Control

signal back_button_pressed ## Emitted when the back button is pressed

@onready var _test_audio_player: CharacterAudioPlayer = $TestAudioPlayer


## Sets the new volume
func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	_test_audio_player.play_sound(_test_audio_player.JUMP_SOUND, false)


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
