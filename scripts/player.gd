# Class for the bird, a player-controlled entity that can only jump and fall
class_name Player
extends CharacterBody2D

const GRAVITY := 196
const JUMP_STRENGTH := 100

var alive := true

@onready var sprite: Sprite2D = $Sprite


func _physics_process(delta: float) -> void:
	if alive:
		velocity.y += GRAVITY * delta
		move_and_slide()


func _input(event: InputEvent) -> void:
	if alive and event.is_action_pressed("player_jump"):
		velocity.y = -JUMP_STRENGTH


# Controls the bird's actions when it dies
func die():
	sprite.modulate = Color.RED
	alive = false
