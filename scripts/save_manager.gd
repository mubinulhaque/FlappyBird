## Class used for saving high scores
extends Node

const _SAVE_PATH := "user://scores.save" ## File path of the save file

var _save_loaded := false
var _solo_profile := ""
var _profiles := {}


# Saves a high score to the save file path
func save_high_score(profile: String, new_score: int) -> void:
	if _profiles.has(profile):
		_profiles[profile] = new_score
		
		var save_file := FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
		var data := {
			"profiles": _profiles.keys(),
		}
		
		# Save each profile
		for profile_name: String in _profiles.keys():
			data[profile_name.to_lower() + "_score"] = _profiles[profile_name.to_lower()]

		# JSON provides a static method to serialized JSON string.
		var json_string := JSON.stringify(data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
		save_file.close()
	elif not _save_loaded:
		printerr("Profiles have not been loaded!")
	else:
		printerr("Profile does not exist! Score will not be saved!")


# Loads a high score from the save file path
func load_high_score(profile: String) -> int:
	if not _save_loaded:
		# If the save file has not been loaded yet
		_load()
	
	if _profiles.has(profile):
		# If the profile exists
		return _profiles[profile]
	else:
		# If the profile does not exist
		return 0


# Returns the names of all profiles
func get_profiles() -> Array:
	if not _save_loaded:
		# If the save file has not been loaded yet
		_load()
	
	if _profiles.is_empty():
		printerr("No profiles found!")
	
	return _profiles.keys()


func _load() -> void:
	if not FileAccess.file_exists(_SAVE_PATH):
		# If no save file can be found
		printerr("No save file found! Defaulting to 0...")
		return
	
	# Load the file line by line and process that dictionary to return
	# the current player's high score
	var save_file := FileAccess.open(_SAVE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string := save_file.get_line()

		# Creates the helper class to interact with JSON
		var json := JSON.new()

		# Check if there is any error while parsing the JSON string
		# Skip in case of failure
		var parse_result := json.parse(json_string)
		if not parse_result == OK:
			printerr(
					"JSON Parse Error: ",
					json.get_error_message(),
					" in ",
					json_string,
					" at line ",
					json.get_error_line(),
			)
			return

		# Get the data from the JSON object
		var node_data: Variant = json.get_data()

		# Now load the profiles and their high scores
		for profile_name: String in node_data["profiles"]:
			_profiles[profile_name] = node_data[profile_name.to_lower() + "_score"]
	
	if save_file.is_open():
		save_file.close()
	
	_save_loaded = true


func change_solo_profile(new_profile: String) -> void:
	if _profiles.has(new_profile):
		_solo_profile = new_profile
	else:
		printerr("Incorrect solo profile selected!")


func get_solo_profile() -> String:
	return _solo_profile


func add_profile(new_name: String) -> void:
	_profiles[new_name] = 0
