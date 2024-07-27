## Class used for the main menu
extends Control

const _SOLO_GAME := preload("res://scenes/solo_level.tscn")
const _BIRD_TEXTURE := preload("res://textures/bird.png")

var _profiles := []

# Menus
@onready var _default_menu: Control = $DefaultMenu
@onready var _play_menu: Control = $PlayMenu
@onready var _solo_profile_menu: Control = $SoloProfileMenu
@onready var _solo_profile_selector: OptionButton = %ProfileSelector


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
		
		for profile in _profiles:
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
