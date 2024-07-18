# Class used for pipes, obstacles that a bird can collide into
class_name Pipe
extends Area2D

signal screen_exited ## Emitted when the pipe is no longer visible


# Used to change the height of a pipe, with the center being the hole
# where the bird is supposed to pass through
func change_height(new_height: int) -> void:
	print("Pipe is now at: ", new_height)
	position.y = new_height


func _on_screen_exited() -> void:
	screen_exited.emit()
