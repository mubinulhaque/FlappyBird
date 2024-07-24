class_name CharacterAudioPlayer
extends AudioStreamPlayer

const DEATH_SOUND: AudioStream = preload("res://audio/sounds/death.wav")
const JUMP_SOUND: AudioStream = preload("res://audio/sounds/jump.wav")


## Plays a player's death sound
func play_sound(sound: AudioStream) -> void:
	if sound:
		stream = sound
		play()
