# Class used for the level to handle obstacle generation
extends Node

const _PIPE_SPEED := 100 ## Speed at which pipes move
const _PIPE_GAP := 96 ## Height of the gap between vertically adjacent pipes

@export var pipe_scene: PackedScene

var _pipe_spawn := 1500 ## X position where pipes are supposed to spawn
var _max_pipe_count := 3 ## Maximum number of pipes that can be onscreen
var _max_pipe_height := 700 ## Maximum height that a pipe can be at
var _current_bounce := 0 ## Current index of AirBounce
var _current_score := 0 ## Current score of the player
var _current_high_score := 0 ## Current high score of the player

@onready var _pipes: Array[Pipe]
@onready var _pipe_creation_timer: Timer = $PipeCreationTimer
@onready var _score_label: Label = %ScoreNumberLabel
@onready var _audio_player: CharacterAudioPlayer = $CharacterAudioPlayer
@onready var _air_bounces: Array[AirBounce] = [$AirBounce, $AirBounce2]
@onready var _save_manager: SaveManager = $SaveManager
@onready var _high_score_label: Label = %HiScoreNumberLabel


func _ready() -> void:
	var viewport_size := get_window().content_scale_size
	
	# Calculate where pipes spawn
	@warning_ignore("integer_division")
	_pipe_spawn = viewport_size[0] + (_PIPE_GAP / 2)
	
	# Calculate the maximum number of pipes that can be onscreen
	@warning_ignore("integer_division")
	_max_pipe_count = (viewport_size[0] / _PIPE_SPEED) + 1
	
	# Calculate the maximum height that pipes can be at
	_max_pipe_height = viewport_size[1] - _PIPE_GAP
	
	_current_high_score = _save_manager.load_high_score()
	_high_score_label.text = str(_current_high_score)


func _process(delta: float) -> void:
	# Move the pipes to the left
	for pipe in _pipes:
		pipe.position.x -= _PIPE_SPEED * delta
	
	for bounce in _air_bounces:
		if bounce.visible:
			bounce.position.x -= _PIPE_SPEED * delta


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
				new_pipe.gap_entered.connect(_on_player_entered_gap)
				
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
	return (randi() % _max_pipe_height) + (_PIPE_GAP / 2)


# Spawns a pipe at a regular interval
func _on_pipe_not_visible(old_pipe: Pipe) -> void:
	_move_pipe(_get_random_pipe_height(), old_pipe)


# Spawns a pipe after a set amount of time
func _on_pipe_creation_timer_timeout() -> void:
	_spawn_pipe(_get_random_pipe_height())


# Kills a player when they hit a pipe
func _on_player_entered_pipe(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.die()


# Increments a player's score
func _on_player_entered_gap(player: Player) -> void:
	_current_score = player.increment_score()
	_score_label.text = str(_current_score)


# Plays a jump sound
func _on_player_jumped(player_position: Vector2) -> void:
	_audio_player.play_sound(_audio_player.JUMP_SOUND)
	
	var new_bounce := _air_bounces[_current_bounce]
	new_bounce.play(player_position)
	_current_bounce = (_current_bounce + 1) % _air_bounces.size()


# Plays a death sound and, if necessary, saves the player's new high score
func _on_player_died() -> void:
	_audio_player.play_sound(_audio_player.DEATH_SOUND)
	
	if _current_score > _current_high_score:
		_save_manager.save_high_score(_current_score)
