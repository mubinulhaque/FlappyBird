extends Control

signal back_button_pressed ## Emitted when the back button is pressed

const _SETTINGS_VERSION := 0 ## Version of the save file

var _settings_loaded := false ## Has the settings been loaded yet?

@onready var _fps: OptionButton = %FpsOptions
@onready var _fxaa_check: CheckButton = %FxaaCheck
@onready var _monitors: OptionButton = %MonitorOptions
@onready var _msaa: OptionButton = %MsaaOptions
@onready var _resolutions: OptionButton = %ResolutionOptions
@onready var _sfx_volume: HSlider = %SFXSlider
@onready var _test_audio_player: CharacterAudioPlayer = $TestAudioPlayer
@onready var _window: Window = get_tree().root
@onready var _windowed: OptionButton = %WindowedOptions


func _load_settings() -> void:
	if not _settings_loaded:
		# If the settings haven't been loaded yet
		print("Loading settings!")
		
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
			
			var settings := ConfigFile.new()
			var error := settings.load("user://settings.ini")
			
			# Don't bother loading anything if the file hasn't been opened properly
			if error != OK:
				printerr("Error loading settings! " + str(error))
				return
			
			if settings.get_value("", "version") == _SETTINGS_VERSION:
				# Current monitor of the game window
				_window.current_screen = settings.get_value("display", "screen")
				# Fullscreen mode of the game window
				_window.mode = settings.get_value("display", "fullscreen")
				# Resolution of the game window
				_window.size = settings.get_value("display", "resolution")
				# Whether FXAA is enabled
				_window.screen_space_aa = (
						Viewport.SCREEN_SPACE_AA_FXAA if settings.get_value("display", "fxaa")
						else Viewport.SCREEN_SPACE_AA_DISABLED
				)
				# Type of MSAA used
				_window.msaa_2d = settings.get_value("display", "msaa")
				# FPS limit
				Engine.max_fps = settings.get_value("display", "fps")
				# SFX volume
				AudioServer.set_bus_volume_linear(0, settings.get_value("volume", "sfx"))
				
				_update_ui()
			else:
				printerr("The save file is not in the correct version!")
		
		_settings_loaded = true


## Emits a signal for the main menu to be displayed
func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
	_save_settings()


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
			_window.msaa_2d = Viewport.MSAA_DISABLED
		
		1:
			# Multisample Anti-Aliasing 2x
			_window.msaa_2d = Viewport.MSAA_2X
		
		2:
			# Multisample Anti-Aliasing 4x
			_window.msaa_2d = Viewport.MSAA_4X
		
		3:
			# Multisample Anti-Aliasing 8x
			_window.msaa_2d = Viewport.MSAA_8X


## Changes the resolution of the game window
## Note: unsure why, but Godot doesn't change window size accurately
func _on_resolution_options_item_selected(index: int) -> void:
	var new_res := _resolutions.get_item_text(index).split(" x ")
	var new_size := Vector2i(int(new_res[0]), int(new_res[1]))
	_window.size = new_size


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


## Saves settings into a file in the user directory
func _save_settings() -> void:
	# Create/Overwrite a Config File
	var settings := ConfigFile.new()
	
	# Version of save files; useful for moving between game versions
	settings.set_value("", "version", _SETTINGS_VERSION)
	
	# Current screen the game is on
	settings.set_value("display", "screen", _window.current_screen)
	# Fullscreen mode of the game window
	settings.set_value("display", "fullscreen", _window.mode)
	# Resolution of the game window 
	settings.set_value("display", "resolution", _window.size)
	# Whether FXAA is enabled
	settings.set_value(
			"display",
			"fxaa",
			_window.screen_space_aa == Viewport.SCREEN_SPACE_AA_FXAA
	)
	# Type of MSAA used
	settings.set_value("display", "msaa", _window.msaa_2d)
	# FPS limit
	settings.set_value("display", "fps", Engine.max_fps)
	# SFX volume
	settings.set_value("volume", "sfx", AudioServer.get_bus_volume_linear(0))
	
	# Save the settings called settings.ini
	settings.save("user://settings.ini")


## Update the UI to reflect newly loaded settings
func _update_ui() -> void:
	if not _settings_loaded:
		# If the settings haven't been loaded yet
		print("Updating UI!")
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
		
		# Update the user interface to be accurate
		# Current monitor of the game window
		_monitors.selected = _window.current_screen
		# Fullscreen mode of the game window
		_windowed.selected = (
				2 if _window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN
				else 1 if _window.mode == Window.MODE_FULLSCREEN
				else 0
		)
		# Resolution of the game window
		for res_index: int in range(_resolutions.item_count):
			var res_string := _resolutions.get_item_text(res_index).split(" x ")
			var res_vector := Vector2i(int(res_string[0]), int(res_string[1]))
			
			if res_vector == _window.size:
				_resolutions.selected = res_index
		# Whether FXAA is enabled
		_fxaa_check.set_pressed_no_signal(
				_window.screen_space_aa == Viewport.SCREEN_SPACE_AA_FXAA
		)
		# Type of MSAA used
		_msaa.selected = _window.msaa_2d
		# FPS limit
		for fps_index: int in range(_fps.item_count):
			if _fps.get_item_text(fps_index) == str(Engine.max_fps):
				_fps.selected = fps_index
		# SFX volume
		_sfx_volume.set_value_no_signal(AudioServer.get_bus_volume_linear(0))
