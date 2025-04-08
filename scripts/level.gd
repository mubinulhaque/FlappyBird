# Class used for the level to handle obstacle generation
extends Node

const _INITIAL_PIPE_SPEED := 100 ## Speed at which pipes move
const _PIPE_GAP := 96 ## Height of the gap between vertically adjacent pipes
const _PLAY_ICON := preload("res://textures/ui/play.png")
const _PAUSE_ICON := preload("res://textures/ui/pause.png")

@export var pipe_scene: PackedScene

var _pipe_spawn := 1500 ## X position where pipes are supposed to spawn
var _max_pipe_count := 3 ## Maximum number of pipes that can be onscreen
var _max_pipe_height := 700 ## Maximum height that a pipe can be at
var _current_bounce := 0 ## Current index of AirBounce
var _current_score := 0 ## Current score of the player
var _current_high_score := 0 ## Current high score of the player
var _current_profile := "Player" ## Currently selected profile
var _offscreen_pipe: Pipe = null
var _new_pipe_wait_time := 1.0 ## Time between pipes being generated
var _pipe_speed: float = _INITIAL_PIPE_SPEED ## Initial speed at which pipes move
var _player_alive := true ## If the player is alive

@onready var _air_bounces: Array[AirBounce] = [$AirBounce, $AirBounce2]
@onready var _audio_player: CharacterAudioPlayer = $CharacterAudioPlayer
@onready var _background: ParallaxBackground = $ParallaxBackground
@onready var _high_score_animator: AnimationPlayer = %HighScoreAnimator
@onready var _high_score_label: Label = %HiScoreNumberLabel
@onready var _level_restart_timer: Timer = $LevelRestartTimer
@onready var _options_menu: Control = $PauseScreen/OptionsMenu
@onready var _pause_button: Button = $PauseButton
@onready var _pause_menu: CenterContainer = %PauseMenu
@onready var _pause_screen: ColorRect = $PauseScreen
@onready var _pipe_creation_timer: Timer = $PipeCreationTimer
@onready var _pipes: Array[Pipe]
@onready var _score_label: Label = %ScoreNumberLabel
@onready var _scores: Control = $Scores


func _ready() -> void:
	var viewport_size := get_window().content_scale_size
	
	# Calculate where pipes spawn
	@warning_ignore("integer_division")
	_pipe_spawn = viewport_size[0] + (_PIPE_GAP / 2)
	
	# Calculate the maximum number of pipes that can be onscreen
	@warning_ignore("narrowing_conversion")
	_max_pipe_count = (viewport_size[0] / _pipe_speed) + 1
	
	# Calculate the maximum height that pipes can be at
	_max_pipe_height = viewport_size[1] - _PIPE_GAP
	
	# Calculate the time between pipes being generated
	_new_pipe_wait_time = (
			viewport_size[0] / float(_max_pipe_count - 1)
	) / _pipe_speed
	
	# Get the selected profile
	_current_profile = SaveManager.get_solo_profile()
	
	# Get the high score
	_current_high_score = SaveManager.load_high_score(_current_profile)
	_high_score_label.text = str(_current_high_score)
	
	# Disable stretching the window
	get_window().unresizable = true


func _process(delta: float) -> void:
	# Move the pipes to the left
	for pipe in _pipes:
		pipe.position.x -= _pipe_speed * delta
	
	# Move air bounces to the left
	for bounce in _air_bounces:
		if bounce.visible:
			bounce.position.x -= _pipe_speed * delta
	
	_background.scroll_offset.x -= _pipe_speed * 0.5 * delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		_on_pause_button_pressed()


func _get_random_pipe_height() -> int:
	@warning_ignore("integer_division")
	return (randi() % _max_pipe_height) + (_PIPE_GAP / 2)


## Move a specified pipe
func _move_pipe(height: int, old_pipe: Pipe) -> void:
	pass
	if _pipes.size() >= _max_pipe_count:
		# If there are enough pipes already
		old_pipe.change_height(height)
		old_pipe.position.x = _pipe_spawn
	else:
		printerr("Not enough pipes!")


## Spawns a pipe after a set amount of time
func _on_pipe_creation_timer_timeout() -> void:
	_spawn_pipe(_get_random_pipe_height())
	
	_pipe_creation_timer.wait_time = _new_pipe_wait_time


## Moves an offscreen pipe to the left
func _on_pipe_not_visible(old_pipe: Pipe) -> void:
	_offscreen_pipe = old_pipe


## Increments a player's score
func _on_player_entered_gap(player: Player) -> void:
	_current_score = player.increment_score()
	_score_label.text = str(_current_score)
	
	if _current_score % 20 == 0:
		_pipe_speed *= 1.05
		print("Increasing speed to ", _pipe_speed, "!")


## Kills a player when they hit a pipe
func _on_player_entered_pipe(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.die()


## Plays a jump sound
func _on_player_jumped(player_position: Vector2) -> void:
	_audio_player.play_sound(_audio_player.JUMP_SOUND)
	
	var new_bounce := _air_bounces[_current_bounce]
	new_bounce.play(player_position)
	_current_bounce = (_current_bounce + 1) % _air_bounces.size()


## Quits the game
func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()


## Restarts the level and unpauses the game
func _on_level_restart_timer_timeout() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


## Switches to the Main Menu
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


## Plays the New High Score animation
func _on_new_high_score() -> void:
	_high_score_animator.play("new_high_score")


## Displays the options menu
func _on_options_button_pressed() -> void:
	print("Toggle")
	_options_menu.visible = !_options_menu.visible
	_pause_menu.visible = !_pause_menu.visible
	_scores.visible = !_scores.visible


## Changes the pause button icon and pauses the game
func _on_pause_button_pressed() -> void:
	if _player_alive:
		get_tree().paused = !get_tree().paused
		_pause_screen.visible = get_tree().paused
		
		if get_tree().paused:
			_pause_button.icon = _PLAY_ICON
		else:
			_pause_button.icon = _PAUSE_ICON


## Plays a death sound and, if necessary, saves the player's new high score
func _on_player_died() -> void:
	_player_alive = false
	_audio_player.play_sound(_audio_player.DEATH_SOUND)
	
	if _current_score > _current_high_score:
		SaveManager.save_high_score(_current_profile, _current_score)
		_audio_player.play_sound(_audio_player.CLAP_SOUND)
	
	_level_restart_timer.start()


## Spawns a pipe at a specific height
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
		# Move an offscreen to the right of the screen
		_move_pipe(_get_random_pipe_height(), _offscreen_pipe)
