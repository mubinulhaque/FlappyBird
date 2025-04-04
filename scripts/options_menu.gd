extends Control

signal back_button_pressed ## Emitted when the back button is pressed

var _settings_loaded := false ## Has the settings been loaded yet?

@onready var _monitors: OptionButton = %MonitorOptions
@onready var _test_audio_player: CharacterAudioPlayer = $TestAudioPlayer
@onready var _window: Window = get_tree().root


func _load_settings() -> void:
	if not _settings_loaded:
		# If the settings haven't been loaded yet
		print("Loading settings!")
		_settings_loaded = true
		
		# List all monitors the user has
		for i in DisplayServer.get_screen_count():
			# Set the name of monitor to its index and resolution
			var screen_name := (
					"Monitor "
					+ str(i + 1)
					+ " ("
					+ str(DisplayServer.screen_get_size(i)[0])
					+ " x "
					+ str(DisplayServer.screen_get_size(i)[1])
					+ ")"
			)
			
			if DisplayServer.get_primary_screen() == i:
				# If adding a primary monitor
				_monitors.add_item(screen_name + " (Primary)")
			else:
				# If adding a non-primary monitor
				_monitors.add_item(screen_name)


## Emits a signal for the main menu to be displayed
func _on_back_button_pressed() -> void:
	back_button_pressed.emit()


## Changes the maximum FPS to be used
func _on_fps_options_item_selected(index: int) -> void:
	match index:
		0:
			# Unlimited
			Engine.max_fps = 0
		
		1:
			# 30
			Engine.max_fps = 30
		
		2:
			# 40
			Engine.max_fps = 40
		
		3:
			# 60
			Engine.max_fps = 60
		
		4:
			# 72
			Engine.max_fps = 72
		
		5:
			# 120
			Engine.max_fps = 120


## Toggles Fast Approximate Anti-Aliasing
func _on_fxaa_check_toggled(toggled_on: bool) -> void:
	_window.screen_space_aa = (
			Viewport.SCREEN_SPACE_AA_FXAA if toggled_on
			else Viewport.SCREEN_SPACE_AA_DISABLED
	)


## Changes the monitor the game is displayed
func _on_monitor_options_item_selected(index: int) -> void:
	_window.current_screen = index


## Changes the type of MultiSample Anti-Aliasing used
func _on_msaa_options_item_selected(index: int) -> void:
	match index:
		0:
			# Disabled
			_window.msaa_3d = Viewport.MSAA_DISABLED
		
		1:
			# Multisample Anti-Aliasing 2x
			_window.msaa_3d = Viewport.MSAA_2X
		
		2:
			# Multisample Anti-Aliasing 4x
			_window.msaa_3d = Viewport.MSAA_4X
		
		3:
			# Multisample Anti-Aliasing 8x
			_window.msaa_3d = Viewport.MSAA_8X


## Sets the new volume
func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	_test_audio_player.play_sound(_test_audio_player.JUMP_SOUND, false)


## Changes whether the game is in windowed mode, borderless fullscreen or
## exclusive fullscreen
func _on_windowed_options_item_selected(index: int) -> void:
	match index:
		0:
			# Windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			# Borderless Fullscreen
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			# Exclusive Fullscreen
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
