# Class used for the level to handle obstacle generation
extends Node

const PIPE_SPEED := 500

@export var pipe_scene: PackedScene

var _pipe_spawn := 1280 ## X position where pipes are supposed to spawn

@onready var pipes: Array[Pipe]


func _process(delta: float) -> void:
	for pipe in pipes:
		pipe.position.x -= PIPE_SPEED * delta


# Spawns a pipe at a specific height
func _spawn_pipe(height: int) -> void:
	if pipe_scene:
		# If a pipe class has been specified
		# Spawn a pipe object
		print("Spawning pipe at: ", height)
		var new_object := pipe_scene.instantiate()
		add_child(new_object)
		
		if new_object is Pipe:
			# If the newly instantiated object is a Pipe
			# Change its height and add it to a class
			var new_pipe: Pipe = new_object
			new_pipe.change_height(height)
			new_pipe.position.x = _pipe_spawn
			
			pipes.append(new_pipe)
	else:
		# If a pipe class has not been specified
		printerr("Pipe scene not specified!")


func _on_pipe_creation_timer_timeout() -> void:
	_spawn_pipe(randi() % 700)
