## Class used for the main menu
extends Control

const _SOLO_GAME := preload("res://scenes/solo_level.tscn")

# Menus
@onready var _default_menu: Control = $DefaultMenu
@onready var _play_menu: Control = $PlayMenu


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
	get_tree().change_scene_to_packed(_SOLO_GAME)
