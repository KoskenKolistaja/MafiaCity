extends Node3D

@export var player_scene: PackedScene



func _ready():
	#$MultiplayerSpawner.spawn_path = "/WorldObjects"
	
	if multiplayer.is_server():
		
		await get_tree().create_timer(1).timeout
		print(PlayerData.player_dictionaries)
		
		for item in PlayerData.player_dictionaries:
			add_player(item)
			print(item)
	
	
	



func add_player(player_id):
	var player_instance = player_scene.instantiate()
	player_instance.player_id = player_id
	
	$WorldObjects.add_child(player_instance,true)
