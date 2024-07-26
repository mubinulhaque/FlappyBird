class_name SaveManager
extends Node

const _SAVE_PATH := "user://scores.save" ## File path of the save file

# Saves a high score to the save file path
func save_high_score(new_score: int) -> void:
	var save_file := FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
	var data := {
		"profiles": ["Mubs"],
		"Mubs_score": new_score,
	}

	# JSON provides a static method to serialized JSON string.
	var json_string := JSON.stringify(data)

	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	save_file.close()


# Loads a high score from the save file path
func load_high_score() -> int:
	var profile := "Mubs" # Placeholder until profiles are fully working
	
	if not FileAccess.file_exists(_SAVE_PATH):
		# If no save file can be found
		printerr("No save file found! Defaulting to 0...")
		return 0 
	
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
			print(
					"JSON Parse Error: ",
					json.get_error_message(),
					" in ",
					json_string,
					" at line ",
					json.get_error_line(),
			)
			continue

		# Get the data from the JSON object
		var node_data: Variant = json.get_data()

		# Now load the profiles and find the high score associated to the
		# current player's profile
		#var profiles: Array[String] = node_data["profiles"]
		var current_high_score: int = node_data[profile + "_score"]
		save_file.close()
		return current_high_score
	
	# This shouldn't be reached, but if it does, return an invalid number
	return -1
