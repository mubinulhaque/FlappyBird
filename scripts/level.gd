# Class used for the level to handle obstacle generation
extends Node

const PIPE_SPEED := 500 ## Speed at which pipes move

@export var pipe_scene: PackedScene

var _pipe_spawn := 1500 ## X position where pipes are supposed to spawn
var _pipe_index := 0 ## Index of the pipe to move

@onready var pipes: Array[Pipe]


func _process(delta: float) -> void:
	# Move the pipes to the left
	for pipe in pipes:
		pipe.position.x -= PIPE_SPEED * delta


# Spawns a pipe at a specific height
func _spawn_pipe(height: int) -> void:
	var width := DisplayServer.window_get_size()[0]
	var max_pipe_count := (width / PIPE_SPEED) + 1
	
	if pipes.size() < max_pipe_count:
		# If there aren't enough pipes already
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
				new_pipe.name = "Pipe " + str(pipes.size())
		else:
			# If a pipe class has not been specified
			printerr("Pipe scene not specified!")
	else:
		# If there are enough pipes already
		var old_pipe: Pipe = pipes[_pipe_index]
		_pipe_index = (_pipe_index + 1) % pipes.size()
		
		old_pipe.change_height(height)
		old_pipe.position.x = _pipe_spawn


# Spawns a pipe at a regular interval
func _on_pipe_creation_timer_timeout() -> void:
	_spawn_pipe(randi() % 700)
