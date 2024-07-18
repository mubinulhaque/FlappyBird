# Class used for pipes, obstacles that a bird can collide into
class_name Pipe
extends Area2D

signal screen_exited ## Emitted when the pipe is no longer visible
signal gap_entered(player: Player) ## Emitted when a player passes through the gap


# Used to change the height of a pipe, with the center being the hole
# where the bird is supposed to pass through
func change_height(new_height: int) -> void:
	print("Pipe is now at: ", new_height)
	position.y = new_height


func _on_screen_exited() -> void:
	screen_exited.emit()


## Sends the signal up when a player has passed through the gap
func _on_gap_entered(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		gap_entered.emit(player)
