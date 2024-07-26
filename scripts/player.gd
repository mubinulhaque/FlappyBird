# Class for the bird, a player-controlled entity that can only jump and fall
class_name Player
extends CharacterBody2D

signal jumped(player_position: Vector2)
signal died

const GRAVITY := 196
const JUMP_STRENGTH := 100

var _alive := true
var _score := 0

@onready var sprite: Sprite2D = $Sprite

func _physics_process(delta: float) -> void:
	if _alive:
		velocity.y += GRAVITY * delta
		move_and_slide()


func _input(event: InputEvent) -> void:
	if _alive and event.is_action_pressed("player_jump"):
		# If the player presses the jump button
		# Set their velocity to the jump strength
		# And play a sound
		velocity.y = -JUMP_STRENGTH
		jumped.emit(global_position)


# Controls the bird's actions when it dies
func die() -> void:
	sprite.modulate = Color.RED
	_alive = false
	get_tree().paused = true
	died.emit()


func increment_score() -> int:
	_score += 1
	return _score


## Kills the player as soon as they exit the screen
func _on_screen_exited() -> void:
	die()
