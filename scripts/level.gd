extends Node

@export var pipe: PackedScene

@onready var pipes: Array[Pipe]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_pipe(150)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Spawns a pipe at a specific height
func _spawn_pipe(height: int) -> void:
	if pipe:
		print("Spawning pipe at: ", height)
		var new_object := pipe.instantiate()
		add_child(new_object)
		
		if new_object is Pipe:
			var new_pipe: Pipe = new_object
			new_pipe.change_height(height)
			
			pipes.append(new_pipe)
