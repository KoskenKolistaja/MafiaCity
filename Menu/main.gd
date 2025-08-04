extends Control



@export var world_scene: PackedScene






func spawn_game_scene():
	var world_instance = world_scene.instantiate()
	add_child(world_instance)
