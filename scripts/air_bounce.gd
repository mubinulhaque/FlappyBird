## Class used for the effect left below a player when they jump
class_name AirBounce
extends Sprite2D

@onready var animator: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.current_animation = "fade_out"


func play(player_position: Vector2) -> void:
	animator.play("fade_out")
	global_position = player_position
	global_position.y += 8
	visible = true


func _on_animation_finished(_anim_name: StringName) -> void:
	visible = false
