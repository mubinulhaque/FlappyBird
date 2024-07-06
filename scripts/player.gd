# Class for the bird, a player-controlled entity that can only jump and fall
extends CharacterBody2D

const GRAVITY := 9.8
const JUMP_STRENGTH := 500


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_jump"):
		print("Player jumped!")
		velocity.y = -JUMP_STRENGTH
