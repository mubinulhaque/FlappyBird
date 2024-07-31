## Class used for playing general audio
class_name CharacterAudioPlayer
extends AudioStreamPlayer

signal got_new_high_score

const CLAP_SOUND: AudioStream = preload("res://audio/sounds/well_done.ogg")
const DEATH_SOUND: AudioStream = preload("res://audio/sounds/death.wav")
const JUMP_SOUND: AudioStream = preload("res://audio/sounds/jump.wav")

var queue: Array[AudioStream] = []


func _ready() -> void:
	finished.connect(_on_finished_playing)


## Plays a player's death sound
func play_sound(sound: AudioStream) -> void:
	if sound:
		if playing:
			queue.append(sound)
		else:
			stream = sound
			play()


func _on_finished_playing() -> void:
	if queue.size() > 0:
		stream = queue.pop_front()
		play()
		
		if stream == CLAP_SOUND:
			got_new_high_score.emit()
