extends Control



@export var world_scene: PackedScene


func _ready():
	var args = OS.get_cmdline_args()
	
	if args.has("music"):
		$AudioStreamPlayer.play()



func spawn_game_scene():
	var world_instance = world_scene.instantiate()
	add_child(world_instance)
