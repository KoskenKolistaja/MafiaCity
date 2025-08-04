extends Control



@export var game_scene: PackedScene






func spawn_game_scene():
	var scene_instance = game_scene.instantiate()
	add_child(scene_instance)
