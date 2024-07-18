# Class used for the level to handle obstacle generation
extends Node

const PIPE_SPEED := 100 ## Speed at which pipes move
const PIPE_GAP := 96 ## Height of the gap between vertically adjacent pipes

@export var pipe_scene: PackedScene

var _pipe_spawn := 1500 ## X position where pipes are supposed to spawn
var _max_pipe_count := 3 ## Maximum number of pipes that can be onscreen
var _max_pipe_height := 700 ## Maximum height that a pipe can be at

@onready var _pipes: Array[Pipe]
@onready var _pipe_creation_timer: Timer = $PipeCreationTimer


func _ready() -> void:
	var viewport_size := get_window().content_scale_size
	
	# Calculate where pipes spawn
	@warning_ignore("integer_division")
	_pipe_spawn = viewport_size[0] + (PIPE_GAP / 2)
	
	# Calculate the maximum number of pipes that can be onscreen
	@warning_ignore("integer_division")
	_max_pipe_count = (viewport_size[0] / PIPE_SPEED) + 1
	
	# Calculate the maximum height that pipes can be at
	_max_pipe_height = viewport_size[1] - PIPE_GAP


func _process(delta: float) -> void:
	# Move the pipes to the left
	for pipe in _pipes:
		pipe.position.x -= PIPE_SPEED * delta


# Spawns a pipe at a specific height
func _spawn_pipe(height: int) -> void:
	if _pipes.size() < _max_pipe_count:
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
				new_pipe.screen_exited.connect(_on_pipe_not_visible.bind(new_pipe))
				new_pipe.body_entered.connect(_on_player_entered_pipe)
				
				_pipes.append(new_pipe)
				new_pipe.name = "Pipe " + str(_pipes.size())
		else:
			# If a pipe class has not been specified
			printerr("Pipe scene not specified!")
	else:
		# If there are enough pipes already
		_pipe_creation_timer.paused = true


# Move a specified pipe
func _move_pipe(height: int, old_pipe: Pipe) -> void:
	pass
	if _pipes.size() >= _max_pipe_count:
		# If there are enough pipes already
		old_pipe.change_height(height)
		old_pipe.position.x = _pipe_spawn
	else:
		printerr("Not enough pipes!")


func _get_random_pipe_height() -> int:
	@warning_ignore("integer_division")
	return (randi() % _max_pipe_height) + (PIPE_GAP / 2)


# Spawns a pipe at a regular interval
func _on_pipe_not_visible(old_pipe: Pipe) -> void:
	_move_pipe(_get_random_pipe_height(), old_pipe)


# Spawns a pipe after a set amount of time
func _on_pipe_creation_timer_timeout() -> void:
	_spawn_pipe(_get_random_pipe_height())


# Kills a player when they hit a pipe
func _on_player_entered_pipe(body: Node2D):
	if body is Player:
		var player: Player = body
		player.die()
		get_tree().paused = true
