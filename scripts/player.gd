# Class for the bird, a player-controlled entity that can only jump and fall
class_name Player
extends CharacterBody2D

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
		velocity.y = -JUMP_STRENGTH


# Controls the bird's actions when it dies
func die() -> void:
	sprite.modulate = Color.RED
	_alive = false


func increment_score() -> void:
	_score += 1
	print("Score: " + str(_score))
