## Class used for the main menu
extends Control

const _SOLO_GAME := preload("res://scenes/solo_level.tscn")
const _BIRD_TEXTURE := preload("res://textures/bird.png")

var _profiles := []
var _from_which_menu := _solo_profile_menu ## Used for returning from the Create Profile menu

# Menus
@onready var _default_menu: Control = $DefaultMenu
@onready var _play_menu: Control = $PlayMenu
@onready var _solo_profile_menu: Control = $SoloProfileMenu
@onready var _create_profile_menu: Control = $CreateProfileMenu
@onready var _options_menu: Control = $OptionsMenu

@onready var _solo_profile_selector: OptionButton = %ProfileSelector
@onready var _profile_name_edit: LineEdit = %NameEdit
@onready var _solo_play_button: Button = $SoloProfileMenu/PlayButton
@onready var _test_audio_player: CharacterAudioPlayer = $OptionsMenu/TestAudioPlayer


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _switch_menu(old_menu: Control, new_menu: Control) -> void:
	old_menu.visible = false
	new_menu.visible = true


func _on_play_button_pressed() -> void:
	_switch_menu(_default_menu, _play_menu)


func _on_play_menu_back_button_pressed() -> void:
	_switch_menu(_play_menu, _default_menu)


func _on_solo_game_pressed() -> void:
	_switch_menu(_play_menu, _solo_profile_menu)
	
	# Get all profiles and add it to the Solo Profile Selector
	if _profiles.is_empty():
		_profiles = SaveManager.get_profiles()
		
		# If no profiles are still found
		if _profiles.is_empty():
			_solo_play_button.disabled = true
		
		for profile: String in _profiles:
			_solo_profile_selector.add_icon_item(_BIRD_TEXTURE, profile)


func _on_solo_profile_back_button_pressed() -> void:
	_switch_menu(_solo_profile_menu, _play_menu)


func _on_solo_game_play_button_pressed() -> void:
	SaveManager.change_solo_profile(
			_solo_profile_selector.get_item_text(
					_solo_profile_selector.get_selected_id()
			)
	)
	
	get_tree().change_scene_to_packed(_SOLO_GAME)


func _on_create_profile_button_pressed(mode: String) -> void:
	match mode:
		"SOLO":
			_switch_menu(_solo_profile_menu, _create_profile_menu)
			_from_which_menu = _solo_profile_menu
		_:
			printerr("Not a valid menu, returning to main menu!")
			_switch_menu(_solo_profile_menu, _default_menu)


func _on_profile_menu_back_button_pressed() -> void:
	_switch_menu(_create_profile_menu, _from_which_menu)


## Creates a new profile using the Profile Name Edit
## Saves all profiles
## And then returns to the previous menu
func _create_profile() -> void:
	var new_profile := _profile_name_edit.text
	_solo_profile_selector.add_icon_item(_BIRD_TEXTURE, new_profile)
	_profiles.append(new_profile)
	SaveManager.add_profile(new_profile)
	
	SaveManager.save_high_score(new_profile, 0)
	
	_on_profile_menu_back_button_pressed()


## Presents the options menu
func _on_options_button_pressed() -> void:
	_switch_menu(_default_menu, _options_menu)


## Returns the player to the default menu
func _on_options_menu_back_button_pressed() -> void:
	_switch_menu(_options_menu, _default_menu)
