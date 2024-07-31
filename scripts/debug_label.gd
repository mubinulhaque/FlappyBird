extends RichTextLabel


func _ready() -> void:
	visible = false


func _process(_delta):
	var debug_dict = {
		"FPS": Engine.get_frames_per_second(),
		"FPS Time": Performance.get_monitor(Performance.TIME_FPS),
		"Object Count": Performance.get_monitor(Performance.OBJECT_COUNT),
		"Node Count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"RAM": str(Performance.get_monitor(Performance.MEMORY_STATIC) / 1000000) + "mb" + " / " + str(Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 1000000) + "mb",
		"Used VRAM (Total)": str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1000000) + "mb",
		"Used VRAM (Textures)": str(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1000000) + "mb",
		"Used VRAM (Buffer)": str(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1000000) + "mb",
	}
	var strin = ""
	for i in debug_dict:
		strin = strin + "\n[color=#53d7a7]" + i + "[/color]: " + str(debug_dict[i]) + ""
	text = strin


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_debug"):
		visible = !visible
